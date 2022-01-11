
import Fluent
import Foundation

final class BookAuthorPivot: Model {
    static let schema = "book-author-pivot"

    @ID
    var id: UUID?

    @Parent(key: "book_id")
    var book: Book

    @Parent(key: "author_id")
    var author: Author

    @Field(key: "words")
    var words: Int

    init() {}

    init(
        id: UUID? = nil,
        book: Book,
        author: Author,
        words: Int
    ) throws {
        self.id = id
        self.$book.id = try book.requireID()
        self.$author.id = try author.requireID()
        self.words = words
    }
}
