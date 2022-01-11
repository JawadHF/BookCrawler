import Fluent
//import FluentSQL
// import MySQLNIO
import FluentMySQLDriver
//import FluentPostgresDriver

struct CreateBook: AsyncMigration {

    func prepare(on database: Database) async throws {

        let bookType = try await database.enum("book_type")
            .case("fiction")
            .case("nonFiction")
            .create()

        let bookForm = try await database.enum("book_form")
            .case("shortStory")
            .case("novel")
            .create()

        try await database.schema("books")
            .id()
            .field("title", .string, .required)
            .field("words", .int, .required)
            .field("type", bookType, .required)
            .field("form", bookForm)
            .field("price", (database is MySQLDatabase) ? .sql(raw: "DECIMAL(7,2)") : .string, .required)
            .field("discount_price", (database is MySQLDatabase) ? .sql(raw: "DECIMAL(7,2)") : .string)
            // .field("price", database is PostgresDatabase ? .sql(raw: "MONEY") : .string, .required)
            // .field("price", .sql(raw: "DECIMAL(7,2)"), .required)
            .unique(on: "title")
            .create()

        /*
        let builder = database.schema("books")
            .id()
            .field("title", .string, .required)
            .field("words", .int, .required)
            .field("type", bookType, .required)
            .field("price", database is MySQLDatabase ? .sql(raw: "DECIMAL(7,2)") : .string, .required)
            .unique(on: "title")
        
        if database is MySQLDatabase {
            // The underlying database driver is MySQL.
            _ = builder.field("price", .sql(raw: "DECIMAL(7,2)"), .required)
        } else if database is MySQLDatabase {
         // The underlying database driver is MySQL.
         _ = builder.field("price", .sql(raw: "DECIMAL(7,2)"), .required)
         }
         else {
            // The underlying database driver is _not_ MySQL.
            _ = builder.field("price", .string, .required)
        }
        try await builder.create()
         */
    }

    func revert(on database: Database) async throws {
        try await database.schema("books").delete()
    }
}
