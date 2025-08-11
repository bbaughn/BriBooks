//
//  BookService.swift
//  BriBooks
//
//  Created by Brian Baughn on 8/11/25.
//

import Foundation

protocol BookService {
    func search(query: String, page: Int) async throws -> [Book]
}
