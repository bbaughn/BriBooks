//
//  OpenLibraryService.swift
//  BriBooks
//
//  Created by Brian Baughn on 8/11/25.
//

import Foundation

final class OpenLibraryService: BookService {
    private let session: URLSession = .shared

    func search(query: String, page: Int) async throws -> [Book] {
        var comps = URLComponents(string: "https://openlibrary.org/search.json")!
        comps.queryItems = [
            URLQueryItem(name: "q", value: query.isEmpty ? "swift programming" : query),
            URLQueryItem(name: "page", value: String(page))
        ]
        let url = comps.url!
        let (data, response) = try await session.data(from: url)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        let decoded = try JSONDecoder().decode(SearchResponse.self, from: data)
        return decoded.docs.map { $0.toBook() }
    }
}
