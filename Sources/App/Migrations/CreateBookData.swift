
import Fluent

struct CreateBookData: AsyncMigration {

    func prepare(on database: Database) async throws {

        let books: [Book] = [
            .init(title: "Server-side Swift with Vapor", words: 100, type: .nonFiction, form: nil, price: 59.99),
            .init(title: "Getting started with Vapor", words: 100, type: .nonFiction, form: nil, price: 0),
            .init(title: "The Adventures of Tom Sawyer", words: 100, type: .fiction, form: .novel, price: 159.99),
            .init(title: "The Adventures of Huckleberry Finn", words: 100, type: .fiction, form: .novel, price: 99.99),
            .init(title: "Moby Dick", words: 100, type: .fiction, form: .novel, price: 99.99),
            .init(title: "War and Peace", words: 100, type: .fiction, form: .novel, price: 99.99),
            .init(title: "Great Expectations", words: 100, type: .fiction, form: .novel, price: 99.99),
            .init(title: "To Kill a Mockingbird", words: 100, type: .fiction, form: .novel, price: 99.99),
            .init(title: "Gulliver's Travels", words: 100, type: .fiction, form: .novel, price: 99.99),
            .init(title: "David Copperfield", words: 100, type: .fiction, form: .novel, price: 99.99),
            .init(title: "The Necklace", words: 1134, type: .fiction, form: .shortStory, price: 99.99),
            //.init(title: "The Man Who Knew Too Much", words: 100, type: .fiction, form: .shortStory, price: 99.99),
            .init(title: "Just Lather, That's All", words: 1181, type: .fiction, form: .shortStory, price: 99.99),

        ]

        try await books.create(on: database)
    }

    func revert(on database: Database) async throws {
        try await Book.query(on: database).delete()
    }
}
