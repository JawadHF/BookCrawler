
import Fluent
import Vapor

final class Book: Model, Content {
    static let schema = "books"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "title")
    var title: String

    @Field(key: "words")
    var words: Int

    @Enum(key: "type")
    var type: BookType

    @OptionalEnum(key: "form")
    var form: BookForm?

    @Field(key: "price")
    var price: Decimal

    @OptionalField(key: "discount_price")
    var discountPrice: Decimal?

    @Children(for: \Page.$book)
    var pages: [Page]

    @Siblings(
      through: BookAuthorPivot.self,
      from: \BookAuthorPivot.$book,
      to: \BookAuthorPivot.$author)
    var authors: [Author]

    init() { }

    init(id: UUID? = nil, title: String, words: Int, type: BookType = .nonFiction, form: BookForm?, price: Decimal) {
        self.id = id
        self.title = title
        self.words = words
        self.type = type
        self.form = form
        self.price = price
    }
}

enum BookType: String, Content {
    case fiction
    case nonFiction
}

enum BookForm: String, Content {
    case shortStory
    case novel
}
