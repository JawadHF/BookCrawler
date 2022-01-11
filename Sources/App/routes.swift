import Fluent
import Vapor

func routes(_ app: Application) throws {

    try app.register(collection: BookController())
    try app.register(collection: PageController())
    try app.register(collection: AuthorController())
}
