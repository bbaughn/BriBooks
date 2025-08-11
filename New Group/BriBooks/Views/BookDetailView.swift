//
//  BookDetailView.swift
//  BriBooks
//
//  Created by Brian Baughn on 8/11/25.
//

import SwiftUI

struct BookDetailView: View {
    let book: Book
    let isFavorite: Bool
    let toggleFavorite: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let url = book.coverURL {
                    AsyncImage(url: url) { image in
                        image.resizable().scaledToFit()
                    } placeholder: {
                        ProgressView()
                    }
                } else {
                    Image(systemName: "book")
                        .resizable().scaledToFit()
                        .frame(height: 160)
                        .foregroundStyle(.secondary)
                }

                Text(book.title)
                    .font(.title2).bold()

                if !book.authors.isEmpty {
                    Text(book.authors.joined(separator: ", "))
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }

                if let year = book.firstPublishYear {
                    Text("First published: \(year)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Button(isFavorite ? "Remove Favorite" : "Add Favorite") {
                    toggleFavorite()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}
