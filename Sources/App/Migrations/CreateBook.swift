/// Copyright (c) 2021 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.
import Fluent
import FluentSQL
// import MySQLNIO
import FluentMySQLDriver
import FluentPostgresDriver

struct CreateBook: AsyncMigration {

    func prepare(on database: Database) async throws {

        let bookType = try await database.enum("book_type")
            .case("fiction")
            .case("nonFiction")
            .create()

        try await database.schema("books")
            .id()
            .field("title", .string, .required)
            .field("words", .int, .required)
            .field("type", bookType, .required)
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
