//
//  CreateBookData.swift
//  
//
//  Created by Jawad Hussain Farooqui on 31/10/21.
//
import Fluent
import Vapor

struct CreateBookData: AsyncMigration {
    
    func prepare(on database: Database) async throws {
        
        /*guard let user =  try await User.query(on: database)
            .filter(\.$name == "Admin")
            .first() else { throw Abort(.notFound) }*/
        
        let books: [Book] = [
            .init(title: "Server-side Swift with Vapor", words: 100, type: .nonFiction, price: 59.99),
            .init(title: "Getting started with Vapor", words: 100, type: .nonFiction, price: 0),
            .init(title: "The Adventures of Tom Sawyer", words: 100, type: .fiction, price: 159.99),
            .init(title: "The Adventures of Huckleberry Finn", words: 100, type: .fiction, price: 99.99)
        ]
        
        try await books.create(on: database)
    }
    
    func revert(on database: Database) async throws {
        try await Book.query(on: database).delete()
    }
}

