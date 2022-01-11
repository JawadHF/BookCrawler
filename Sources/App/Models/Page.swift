import Fluent
import Vapor

final class Page: Model, Content {
    static let schema = "pages"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "number")
    var number: Int

    @Field(key: "chapter")
    var chapter: String

    @OptionalField(key: "section")
    var section: String?

    @Field(key: "content")
    var content: String

    @Field(key: "is_sample")
    var isSample: Bool

    @Parent(key: "bookId")
    var book: Book

    init() { }

    init(id: UUID? = nil, number: Int, chapter: String, section: String?, content: String, isSample: Bool, bookId: Book.IDValue) {
        self.id = id
        self.number = number
        self.chapter = chapter
        self.section = section
        self.content = content
        self.isSample = isSample
        self.$book.id = bookId
    }
}
