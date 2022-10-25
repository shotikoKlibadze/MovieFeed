//
//  FeedViewControllerTests.swift
//  MovieFeedTests
//
//  Created by Shotiko Klibadze on 25.10.22.
//

import XCTest
import MovieFeed
import MovieFeediOS

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
    
    func test_loadFeedCompletion_rendersSuccessfullyTheFeed() {
        let item = makeFeedItem(description: "descriptiobn", title: "title", id: 1)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(sut.numberOfRenderedFeedItemViews(), 0)
        
        loader.completeFeedLoading(with: [item], at: 0)
        XCTAssertEqual(sut.numberOfRenderedFeedItemViews(), 1)
        
        let view = sut.feedItemView(at: 0) as? FeedItemCell
        
        XCTAssertNotNil(view)
        XCTAssertEqual(view?.descriptionText, item.description)
        XCTAssertEqual(view?.titleText, item.title)
    }
    
    //MARK: -Helpers-
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: FeedViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = FeedUIComposer.feedComposedWith(feedLoader: loader, imageLoader: loader)
        trackForMemoryLeacks(isntance: sut)
        trackForMemoryLeacks(isntance: loader)
        return (sut, loader)
    }
    
    private func makeFeedItem(description: String, title: String, url: String = "www.anyurl.com", id: Int) -> FeedItem {
        return FeedItem(id: id, description: description, title: title, imageURL: url)
    }
    
    class LoaderSpy: FeedLoader, FeedItemImageDataLoader {
        
        
       
        var completions = [(FeedLoader.Result) -> Void]()
       
        var loadCallCount: Int {
            return completions.count
        }
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            completions.append(completion)
        }
        
        func completeFeedLoading(with items: [FeedItem] = [], at index: Int = 0) {
            completions[index](.success(items))
        }
        
        var loadedImageURLs = [URL]()
        var canceledImageURLs = [URL]()
        
        private struct TaskSpy: FeedItemImageDataLoaderTask {
            let canceCallBack: () -> Void
            func cancel() {
                canceCallBack()
            }
        }
        
        func loadImageData(from url: URL, completion: @escaping (Result<Data, Error>) -> Void) -> FeedItemImageDataLoaderTask {
            loadedImageURLs.append(url)
            return TaskSpy { [weak self] in
                self?.canceledImageURLs.append(url)
            }
        }
    }
}

private extension FeedViewController {
    func numberOfRenderedFeedItemViews() -> Int {
        return tableView.numberOfRows(inSection: feedItemsSection)
    }
    
    func feedItemView(at row: Int) -> UITableViewCell? {
        let ds = tableView.dataSource
        let index = IndexPath(row: row, section: feedItemsSection)
        return ds?.tableView(tableView, cellForRowAt: index)
    }
    
    private var feedItemsSection: Int {
        return 0
    }

}

private extension FeedItemCell {
    var titleText: String? {
        return titleLabel.text
    }
    
    var descriptionText: String? {
        return descriptionLabel.text
    }
}
