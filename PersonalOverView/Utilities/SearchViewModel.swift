//
//  SearchViewModel.swift
//  PersonalOverView
//
//  Created by Jan Hovland on 24/02/2021.
//

import SwiftUI
import Combine

class SearchViewModel: ObservableObject {
    // Input
    @Published var searchText = ""
    
    // Output
    @Published var isSearchValid = false

    private var cancellableSet: Set<AnyCancellable> = []
    
    init() {
        $searchText
            .receive(on: RunLoop.main)
            /// Venter på verdien 2 sekunder etter at jeg er ferdig med å trykke
            /// .debounce(for: .seconds(2), scheduler: RunLoop.main)
            .map { searchText in
                return searchText.count > 0 || searchText.isEmpty
            }
            .assign(to: \.isSearchValid, on: self)
            .store(in: &cancellableSet)
    }
}

