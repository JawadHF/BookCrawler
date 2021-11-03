//
//  Book.swift
//  
//
//  Created by Jawad Hussain Farooqui on 30/10/21.
//

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
    
    @Field(key: "price")
    var price: Decimal
    
    @OptionalField(key: "discount_price")
    var discountPrice: Decimal?
    
    @Children(for: \.$book)
    var pages: [Page]

    
    @Siblings(
      through: BookAuthorPivot.self,
      from: \.$book,
      to: \.$author)
    var authors: [Author]


    init() { }

    init(id: UUID? = nil, title: String, words: Int, type: BookType = .nonFiction, price: Decimal) {
        self.id = id
        self.title = title
        self.words = words
        self.type = type
        self.price = price
    }
}


enum BookType: String, Content {
    case fiction
    case nonFiction
}
