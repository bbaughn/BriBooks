//
//  BookRowView.swift
//  BriBooks
//
//  Created by Brian Baughn on 8/11/25.
//

import SwiftUI

struct BookRow: View {
    let book: Book
    let isFavorite: Bool
    let onToggleFavorite: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: book.coverURL) { phase in
                switch phase {
                case .empty: ProgressView()
                case .success(let image): image.resizable().scaledToFill()
                case .failure: Image(systemName: "book")
                @unknown default: EmptyView()
                }
            }
            .frame(width: 52, height: 72)
            .clipShape(RoundedRectangle(cornerRadius: 6))

            VStack(alignment: .leading, spacing: 4) {
                Text(book.title)
                    .font(.headline)
                    .lineLimit(2)
                if !book.authors.isEmpty {
                    Text(book.authors.joined(separator: ", "))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            Spacer()
            Button {
                onToggleFavorite()
            } label: {
                Image(systemName: isFavorite ? "heart.fill" : "heart")
                    .imageScale(.large)
            }
            .buttonStyle(.borderless)
        }
        .contentShape(Rectangle())
    }
}
