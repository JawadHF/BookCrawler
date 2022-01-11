
import Fluent
import Vapor

struct CreatePageData: AsyncMigration {

    func prepare(on database: Database) async throws {

        guard let book1 =  try await Book.query(on: database)
            .filter(\.$title == "Server-side Swift with Vapor")
            .first() else { throw Abort(.notFound) }

        guard let book2 =  try await Book.query(on: database)
            .filter(\.$title == "Getting started with Vapor")
            .first() else { throw Abort(.notFound) }

        let pages: [Page] = [
            .init(number: 1, chapter: "Introduction", section: "Introduction", content: "lorem ipsum", isSample: true, bookId: try book1.requireID()),
            .init(number: 2, chapter: "Getting Started", section: "Download materials", content: "Links to download projects contains", isSample: false, bookId: try book1.requireID()),
            .init(number: 3, chapter: "Main Body", section: "Main", content: "lorem ipsum", isSample: false, bookId: try book1.requireID()),
            .init(number: 4, chapter: "Where to go from here", section: nil, content: "Reference Books contains", isSample: true, bookId: try book1.requireID()),
            .init(number: 1, chapter: "Introduction", section: "Introduction", content: "lorem ipsum", isSample: true, bookId: try book2.requireID()),
            .init(number: 2, chapter: "Getting Started", section: "Download materials", content: "Links to download projects contains", isSample: false, bookId: try book2.requireID()),
            .init(number: 3, chapter: "Main Body", section: "Main", content: "lorem ipsum", isSample: false, bookId: try book2.requireID()),
            .init(number: 4, chapter: "Where to go from here", section: nil, content: "Reference Books contains", isSample: true, bookId: try book2.requireID())
        ]

        try await pages.create(on: database)
    }

    func revert(on database: Database) async throws {
        try await Page.query(on: database).delete()
    }
}
