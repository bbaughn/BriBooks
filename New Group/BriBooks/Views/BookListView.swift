//
//  BookListView.swift
//  BriBooks
//
//  Created by Brian Baughn on 8/11/25.
//

import SwiftUI

struct BookListView: View {
    @StateObject private var vm: BookListViewModel

    init(service: BookService) {
        _vm = StateObject(wrappedValue: BookListViewModel(service: service))
    }

    var body: some View {
        NavigationStack {
            Group {
                switch vm.state {
                case .idle, .loading where vm.books.isEmpty:
                    ProgressView("Loading…").frame(maxWidth: .infinity, maxHeight: .infinity)
                case .empty:
                    ContentUnavailableView("No results", systemImage: "book")
                case .error(let msg) where vm.books.isEmpty:
                    VStack(spacing: 8) {
                        Text("Something went wrong").bold()
                        Text(msg).font(.caption).foregroundStyle(.secondary)
                        Button("Retry") { Task { await vm.refresh() } }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                default:
                    List {
                        ForEach(vm.books) { book in
                            NavigationLink(value: book.id) {
                                BookRow(book: book, isFavorite: vm.isFavorite(book.id)) {
                                    vm.toggleFavorite(book.id)
                                }
                            }
                            .task {
                                await vm.loadMoreIfNeeded(current: book)
                            }
                        }

                        if case .loading = vm.state, !vm.books.isEmpty {
                            HStack { Spacer(); ProgressView(); Spacer() }
                        }
                    }
                }
            }
            .navigationTitle("BookBrowser")
            .searchable(text: $vm.query)
            .onSubmit(of: .search) { Task { await vm.refresh() } }
            .refreshable { await vm.refresh() }
            .task { await vm.firstLoad() }
            .navigationDestination(for: String.self) { id in
                if let book = vm.books.first(where: { $0.id == id }) {
                    BookDetailView(book: book,
                                   isFavorite: vm.isFavorite(book.id),
                                   toggleFavorite: { vm.toggleFavorite(book.id) })
                } else {
                    Text("Not found")
                }
            }
        }
    }
}
