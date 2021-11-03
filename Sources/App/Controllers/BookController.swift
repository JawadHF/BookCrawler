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
import Foundation

struct BookController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let books = routes.grouped("books")
        books.get(use: index)
        books.get("titles", use: titles)
        books.get("count", use: count)
        books.put("discount", use: applyDiscount)
        books.post(use: create)
        books.get(":bookId", use: get)
        books.group(":bookId") { book in
            book.delete(use: delete)
        }
        
        books.get("samples", use: getSamplePages)
        books.post(":bookId", "authors", ":authorId", use: authorContribution)
    }
    
    func index(req: Request) async throws -> [Book] {
        try await Book.query(on: req.db).all()
    }
    
    /// Reducing memory and network bandwidth
    func titles(req: Request) async throws -> [String] {
        let books = try await Book.query(on: req.db)
            .field(\.$title)    // MARK: Reduce data fetched to save on memory and bandwidth usage
            .sort(\.$title)
            .all()
        
        let bookTitles = books.map { $0.title } //Attempting to fetch any other properties will result in an error
        return bookTitles
    }
    
    /// Preferring DB calculations
    func count(req: Request) async throws -> Int {
        //try await Book.query(on: req.db).all().count
        
        //  MARK: Save on Memory, Network and improve performance
        try await Book.query(on: req.db).count()
    }
    
    /// Discount all fiction books to $10
    func applyDiscount(req: Request) async throws -> HTTPStatus {
        
        guard let discountPrice = req.query[Decimal.self, at: "price"], discountPrice > 0 else {
            throw Abort(.badRequest, reason: "Invalid discount price")
        }
        
        /*
         // Fetch books from DB
        let booksToBeDiscounted = try await Book.query(on: req.db)
            .filter(\.$type == .fiction)
            .filter(\.$price > discountPrice)
            .all()
        
         // Update each matching book with discounted price
        for book in booksToBeDiscounted {
            book.discountPrice = discountPrice
            try await book.update(on: req.db)
        }
         */
        
        //  MARK: Perform read and update on the DB and save on Memory + Network and improve performance
        try await Book.query(on: req.db)
            .set(\.$discountPrice, to: discountPrice)
            .filter(\.$type == .fiction)
            .filter(\.$price > discountPrice)
            .update()
        
        return .ok
    }
    
    
    
    /// Returning better error messages by handling expected errors
    func create(req: Request) async throws -> Book {
        let book = try req.content.decode(Book.self)
        do {
            try await book.create(on: req.db)
            // MARK: Handling DB Errors
        } catch let error as DatabaseError where error.isConstraintFailure {
            throw Abort(.forbidden, reason: "A book with that name already exists or the associated key referenced is incorrect")
        }
        return book
    }
    
    func get(_ req: Request) async throws -> Book {
        guard let book = try await Book.find(req.parameters.get("bookId"), on: req.db) else {
            throw Abort(.notFound)
        }
        return book
    }
    
    func delete(req: Request) async throws -> HTTPStatus {
        
        guard let bookID = req.parameters.get("bookId", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid bookId")
        }
        guard let book = try await Book.find( bookID, on: req.db) else {
            throw Abort(.notFound)
        }
        try await book.delete(on: req.db)
        
        return .noContent
    }
    
    /// Using Database Joins to improve performance
    func getSamplePages(_ req: Request) async throws -> [BookWithPages] {

        guard let selectedPrice = req.query[Decimal.self, at: "price"] else {
            throw Abort(.badRequest, reason: "Invalid price")
        }
        
        var bookWithPages: [BookWithPages] = []

        // MARK: N+1 Select issue
        /*
        let books = try await Book.query(on: req.db)
            .filter(\.$price < selectedPrice)
            .all()
            
        for book in books {
            let pages = try await book.$pages.get(on: req.db)
               //.filter(\Page.$isSample)
                //.all()
            let samplePages = pages.filter{$0.isSample}
            if !samplePages.isEmpty {
                bookWithPages.append(BookWithPages(title: book.title, pages: samplePages))
            }
        }
         */
         
        // MARK: Avoiding N+1 selects using eager loading
        /*
        let books = try await Book.query(on: req.db)
            .filter(\.$price < selectedPrice)
            .with(\.$pages)    //The pages child objects are eagerly loaded here
            //.filter(\.$pages.$isSample == true )    //Can't be done as with() issues a completely separate query after the first one to retrieve the additional results. It doesn't perform a join or honor any filter conditions applied to the original query.
            .all()
         
         for book in books {
             let samplePages = book.pages.filter{$0.isSample}
             if !samplePages.isEmpty {
                 bookWithPages.append(BookWithPages(title: book.title, pages: samplePages))
             }
         }
         */
        
        // MARK: Avoiding N+1 selects using joins
        
        let pages = try await Page.query(on: req.db)
            .filter(\.$isSample == true )
            .join(Book.self, on: \Page.$book.$id == \Book.$id)
            .filter(Book.self, \.$price < selectedPrice)
            .all()
        
        let groupByBook = try Dictionary(grouping: pages) { page -> String in
            let book = try page.joined(Book.self)
            return book.$title.wrappedValue
        }
        
        for book in groupByBook {
            bookWithPages.append(BookWithPages(title: book.key, pages: book.value))
        }
        
        return bookWithPages
    }
    
    /// Siblings with additional property
    func authorContribution(req: Request) async throws -> HTTPStatus {
        
        guard let totalWordContribution = req.query[Int.self, at: "words"] else {
            throw Abort(.badRequest, reason: "Invalid word contribution number")
        }
        guard let bookId = req.parameters.get("bookId", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid bookId")
        }
        guard let authorId = req.parameters.get("authorId", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid authorId")
        }
        
        // FIXME: Use async eventloop
        //let transaction = try await req.db.transaction
        try await req.db.transaction { transaction in
        
        // MARK: Additional Sibling Properties with eager loading using Swift
        /*
        guard let book = try await Book.query(on: transaction)
                .filter(\.$id == bookId)
                .with(\.$authors)
                .with(\.$authors.$pivots)
                .first() else {
                    throw Abort(.notFound, reason: "Book with Id was not found")
                }
        
        guard let author = try await Author.find(authorId, on: transaction) else {
            throw Abort(.notFound, reason: "Author with Id was not found")
        }
        
        var bookAuthors = book.$authors.pivots
        var isNewAuthor = true
        
        for bookAuthor in bookAuthors {
            if bookAuthor.$author.id == author.id { //using bookAuthor.author.id without $ on the author will not work and throw error from Siblings -> fatalError("Siblings relation not eager loaded, use $ prefix to access: \(name)")
                isNewAuthor = false
                bookAuthor.words = totalWordContribution
                try await bookAuthor.save(on: transaction)
            }
        }
        
        if isNewAuthor {
            let newAuthor = try BookAuthorPivot( book: book, author: author, words: totalWordContribution)
            bookAuthors.append(newAuthor)
            try await newAuthor.save(on: transaction)
        }
        
        /*
         Use expanded version below
         let updatedBookWordCount = bookAuthors.map({$0.words}).reduce(0, +)
         */
         let bookAuthorWords = book.$authors.pivots
            .map { bookAuthor in
                bookAuthor.words
            }
        let updatedBookWordCount = bookAuthorWords.reduce(0, +)
        */
        
        // MARK: Additional Sibling Properties Using Database
         guard let book = try await Book.query(on: transaction)
                 .filter(\.$id == bookId)
                 .first() else {
                     throw Abort(.notFound, reason: "Book with Id was not found")
                 }
         
         guard let author = try await Author.find(authorId, on: transaction) else {
             throw Abort(.notFound, reason: "Author with Id was not found")
         }
         
        //Check if author already exists in the pivot and update existing word count if it exists else create it
        let isAlreadyAuthor = try await book.$authors.isAttached(to: author, on: transaction)
        
        if isAlreadyAuthor {
            guard let bookAuthorPivot = try await BookAuthorPivot.query(on: transaction)
                    .filter(\.$book.$id == bookId)
                    .filter(\.$author.$id == authorId)
                    .first() else {
                        throw Abort(.notFound)
                    }
            /// add additional requested quantity if it already exists instead of updating with new value
            bookAuthorPivot.words = totalWordContribution
            try await bookAuthorPivot.save(on: transaction)
        }
        else {
            try await book.$authors.attach(author, method: .ifNotExists, on: transaction) { pivot in
                pivot.words = totalWordContribution
            }
        }
        
        ///Get updated count
        //Does not work on PostgreSQL due to result returning Double instead of Int causing a conversion error: https://github.com/vapor/fluent-kit/issues/379
        // FIXME: Replace aggregate
        guard let updatedBookWordCount = try await BookAuthorPivot.query(on: transaction)
                .filter(\.$book.$id == bookId)
                .sum(\.$words) else {
                    throw Abort(.notFound, reason: "Unable to retreive updated word count")
                }
        
        ///Common code
        book.words = updatedBookWordCount
        try await book.save(on: transaction)
        }
        return .ok
    }
    
    
    struct BookWithPages: Content {
      let title: String
      let pages: [Page]
    }

}



