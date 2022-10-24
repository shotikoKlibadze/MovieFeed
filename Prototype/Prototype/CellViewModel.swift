//
//  CellViewModel.swift
//  Prototype
//
//  Created by Shotiko Klibadze on 24.10.22.
//

import Foundation

struct CellViewModel {

    let title: String
    let image: String
    let description: String
    
    init(title: String, image: String, description: String) {
        self.title = title
        self.image = image
        self.description = description
    }
    
    static func mockData() -> [CellViewModel] {
        let mockData = [ CellViewModel(title: "Title 1", image: "img001", description: "Very Short decsription for the movie"),
                         CellViewModel(title: "Title 2", image: "img002", description: "Little bit bigger decsription for the movie"),
                         CellViewModel(title: "Title 3", image: "img003", description: "Normal description for the movie so that is will stretch the label some"),
                         CellViewModel(title: "Title 4", image: "img004", description: "Big description for the movie so that is will stretch the label little bit more. Big description for the movie so that is will stretch the label little bit more"),
                         CellViewModel(title: "Title 5", image: "img005", description: "Biggest description for the movie so that is will stretch the label little bit more. Big description for the movie so that is will stretch the label little bit more,Big description for the movie so that is will stretch the label little bit more. Big description for the movie so that is will stretch the label little bit more"),
                         CellViewModel(title: "Title 1", image: "img001", description: "Very Short decsription for the movie"),
                         CellViewModel(title: "Title 2", image: "img002", description: "Little bit bigger decsription for the movie"),
                         CellViewModel(title: "Title 3", image: "img003", description: "Normal description for the movie so that is will stretch the label some"),
                         CellViewModel(title: "Title 4", image: "img004", description: "Big description for the movie so that is will stretch the label little bit more. Big description for the movie so that is will stretch the label little bit more"),
                         CellViewModel(title: "Title 5", image: "img005", description: "Biggest description for the movie so that is will stretch the label little bit more. Big description for the movie so that is will stretch the label little bit more,Big description for the movie so that is will stretch the label little bit more. Big description for the movie so that is will stretch the label little bit more")
        ]
        return mockData
    }
}
