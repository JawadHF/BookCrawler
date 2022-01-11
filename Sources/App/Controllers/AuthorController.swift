
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
