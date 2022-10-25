//
//  FeedViewControllerTests.swift
//  MovieFeedTests
//
//  Created by Shotiko Klibadze on 25.10.22.
//

import XCTest
import MovieFeed

class FeedViewController: UITableViewController {
    
    private var loader: FeedLoader?
    
    convenience init(loader: FeedLoader) {
        self.init()
        self.loader = loader
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
        refreshControl?.beginRefreshing()
        
       load()
    }
    
    @objc private func load() {
        loader?.load(completion: { [weak self] _ in
            self?.refreshControl?.endRefreshing()
        })
    }
}

final class FeedViewControllerTests: XCTestCase {
    
    func test_viewDidLoad_LoadsFeed() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(loader.loadCallCount, 1)
    }
    
    func test_PullToRefresh_LoadsFeed() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        sut.refreshControl?.allTargets.forEach({ target in
            sut.refreshControl?.actions(forTarget: target, forControlEvent: .valueChanged)?.forEach({ selctorString in
                (target as NSObject).perform(Selector(selctorString))
            })
        })
        
        XCTAssertEqual(loader.loadCallCount, 2)
    }
    
    
    func test_viewDidLoad_ShowsLoadingIndicator() {
        let (sut, _) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(sut.refreshControl?.isRefreshing, true)
    }
    
    func test_viewDidLoad_hidesLoadingIndicatorAfterTheFeedIsLoaded() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoading()
        
        XCTAssertEqual(sut.refreshControl?.isRefreshing, false)
    }
    
    //MARK: -Helpers-
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: FeedViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = FeedViewController(loader: loader)
        trackForMemoryLeacks(isntance: sut)
        trackForMemoryLeacks(isntance: loader)
        return (sut, loader)
    }
    
    class LoaderSpy: FeedLoader {
        
        var completions = [(FeedLoader.Result) -> Void]()
       
        var loadCallCount: Int {
            return completions.count
        }
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            completions.append(completion)
        }
        
        func completeFeedLoading() {
            completions[0](.success([]))
        }
    }
}
