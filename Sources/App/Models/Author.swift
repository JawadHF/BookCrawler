//
//  Author.swift
//  
//
//  Created by Jawad Hussain Farooqui on 30/10/21.
//

import Fluent
import Vapor

final class Author: Model, Content {
    static let schema = "authors"
    
    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String
    
    @Siblings(
      through: BookAuthorPivot.self,
      from: \.$author,
      to: \.$book)
    var books: [Book]


    init() { }

    init(id: UUID? = nil, name: String) {
        self.id = id
        self.name = name
    }
}

