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
import Vapor

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
            .init(title: "The Man Who Knew Too Much", words: 100, type: .fiction, form: .shortStory, price: 99.99),
            .init(title: "Just Lather, That's All", words: 1181, type: .fiction, form: .shortStory, price: 99.99),

        ]

        try await books.create(on: database)
    }

    func revert(on database: Database) async throws {
        try await Book.query(on: database).delete()
    }
}
