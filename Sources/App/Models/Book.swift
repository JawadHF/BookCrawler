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
