import Foundation

struct Book: Identifiable, Equatable {
    let id: String          // use `key` from API, e.g. "/works/OL12345W"
    let title: String
    let authors: [String]
    let coverID: Int?
    let firstPublishYear: Int?

    var coverURL: URL? {
        guard let coverID else { return nil }
        // Sizes: S, M, L – pick M
        return URL(string: "https://covers.openlibrary.org/b/id/\(coverID)-M.jpg")
    }
}

struct SearchResponse: Decodable {
    let docs: [BookDoc]
}

struct BookDoc: Decodable {
    let key: String
    let title: String
    let author_name: [String]?
    let cover_i: Int?
    let first_publish_year: Int?

    func toBook() -> Book {
        Book(
            id: key,
            title: title,
            authors: author_name ?? [],
            coverID: cover_i,
            firstPublishYear: first_publish_year
        )
    }
}
