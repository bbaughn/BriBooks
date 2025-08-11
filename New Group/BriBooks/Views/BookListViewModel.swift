//
//  BookListViewModel.swift
//  BriBooks
//
//  Created by Brian Baughn on 8/11/25.
//

import Foundation
import SwiftUI

@MainActor
final class BookListViewModel: ObservableObject {
    enum State : Equatable { case idle, loading, loaded, empty, error(String) }

    @Published private(set) var books: [Book] = []
    @Published private(set) var state: State = .idle
    @Published var query: String = ""

    private let service: BookService
    private var page = 1
    private var canLoadMore = true

    // Persist favorites as a Set of ids
    @AppStorage("favoriteBookIDs") private var favoriteIDsData: Data = Data()
    @Published private(set) var favoriteIDs: Set<String> = []

    init(service: BookService) {
        self.service = service
        self.favoriteIDs = (try? JSONDecoder().decode(Set<String>.self, from: favoriteIDsData)) ?? []
    }

    func firstLoad() async {
        guard state == State.idle else { return }
        await refresh()
    }

    func refresh() async {
        page = 1
        canLoadMore = true
        books = []
        state = .loading
        await fetch(reset: true)
    }

    func loadMoreIfNeeded(current item: Book) async {
        guard canLoadMore, state != .loading else { return }
        let thresholdIndex = books.index(books.endIndex, offsetBy: -5)
        if let idx = books.firstIndex(where: { $0.id == item.id }), idx >= thresholdIndex {
            state = .loading
            await fetch(reset: false)
        }
    }

    private func fetch(reset: Bool) async {
        do {
            let new = try await service.search(query: query, page: page)
            if reset && new.isEmpty {
                state = .empty
                return
            }
            books += new
            canLoadMore = !new.isEmpty
            state = .loaded
            if !new.isEmpty { page += 1 }
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    // MARK: - Favorites
    func isFavorite(_ id: String) -> Bool { favoriteIDs.contains(id) }

    func toggleFavorite(_ id: String) {
        if favoriteIDs.contains(id) { favoriteIDs.remove(id) } else { favoriteIDs.insert(id) }
        favoriteIDsData = (try? JSONEncoder().encode(favoriteIDs)) ?? Data()
        objectWillChange.send()
    }
}
