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

struct AuthorController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let authors = routes.grouped("authors")
        authors.get(use: index)
        authors.post(use: create)
        authors.get(":authorId", use: get)
        authors.group(":authorId") { author in
            author.delete(use: delete)
        }
    }

    func index(req: Request) async throws -> [Author] {
        try await Author.query(on: req.db).all()
    }

    func create(req: Request) async throws -> Author {
        let author = try req.content.decode(Author.self)
        do {
            try await author.create(on: req.db)
        } catch let error as DatabaseError where error.isConstraintFailure {
            throw Abort(.forbidden, reason: "An author with that name already exists or the associated key referenced is incorrect")
        }
        return author
    }
    
    func get(_ req: Request) async throws -> Author {
        guard let author = try await Author.find(req.parameters.get("authorId"), on: req.db) else {
            throw Abort(.notFound)
        }
        return author
    }

    func delete(req: Request) async throws -> HTTPStatus {
        
        guard let authorID = req.parameters.get("authorId", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid authorId")
        }
        
        guard let author = try await Author.find( authorID, on: req.db) else {
            throw Abort(.notFound)
        }
        
        try await author.delete(on: req.db)
            
        return .noContent
    }
}


