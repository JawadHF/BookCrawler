
import Fluent
import Vapor

struct CreateAuthorData: AsyncMigration {

    func prepare(on database: Database) async throws {

        let authors: [Author] = [
            .init(name: "Tim Condon"),
            .init(name: "Tanner Nelson"),
            .init(name: "Jonas"),
            .init(name: "Logan"),
            .init(name: "Mark Twain"),
            .init(name: "Herman Melville"),
            .init(name: "Leo Tolstoy"),
            .init(name: "Charles Dickens"),
            .init(name: "Harper Lee"),
            .init(name: "Jonathan Swift"),
            .init(name: "Guy de Maupassant"),
            .init(name: "Alexander Baron"),
            .init(name: "Hernando Tellez")

        ]

        try await authors.create(on: database)
    }

    func revert(on database: Database) async throws {
        try await Author.query(on: database).delete()
    }
}
