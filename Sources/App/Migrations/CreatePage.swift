
import Fluent
import FluentMySQLDriver

struct CreatePage: AsyncMigration {

    func prepare(on database: Database) async throws {
        try await database.schema("pages")
            .id()
            .field("number", .int, .required)
            .field("chapter", .string, .required)
            .field("section", .string)
            .field("content", (database is MySQLDatabase) ? .sql(raw: "TEXT") : .string, .required)
            .field("is_sample", .bool, .required)
            .field("bookId", .uuid, .required, .references("books", "id"))
            .unique(on: "number", "bookId")
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("pages").delete()
    }
}
