
import Fluent

struct CreateAuthor: AsyncMigration {

    func prepare(on database: Database) async throws {
        try await database.schema("authors")
            .id()
            .field("name", .string, .required)
            .unique(on: "name")
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("authors").delete()
    }
}
