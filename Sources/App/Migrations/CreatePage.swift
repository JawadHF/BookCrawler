//
//  CreatePage.swift
//  
//
//  Created by Jawad Hussain Farooqui on 01/11/21.
//

import Fluent

struct CreatePage: AsyncMigration {
    
    func prepare(on database: Database) async throws {
        try await database.schema("pages")
            .id()
            .field("number", .int, .required)
            .field("chapter", .string, .required)
            .field("section", .string)
            .field("content", .string, .required)
            .field("is_sample", .bool, .required)
            .field("bookId", .uuid, .required, .references("books", "id"))
            .unique(on: "number")
            .unique(on: "chapter", "section")
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("pages").delete()
    }
}


