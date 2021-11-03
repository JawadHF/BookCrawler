//
//  CreateAuthorData.swift
//  
//
//  Created by Jawad Hussain Farooqui on 31/10/21.
//
import Fluent
import Vapor

struct CreateAuthorData: AsyncMigration {
    
    func prepare(on database: Database) async throws {
        
        /*guard let user =  try await User.query(on: database)
            .filter(\.$name == "Admin")
            .first() else { throw Abort(.notFound) }*/
        
        let authors: [Author] = [
            .init(name: "Tim"),
            .init(name: "Tanner"),
            .init(name: "Jonas"),
            .init(name: "Logan"),
           // .init(name: "Jockey", address: "123", city: .bengaluru, userId: user.id!),
            .init(name: "Mark")
        ]
        
        try await authors.create(on: database)
    }
    
    func revert(on database: Database) async throws {
        try await Author.query(on: database).delete()
    }
}

