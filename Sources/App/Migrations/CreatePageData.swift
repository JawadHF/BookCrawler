//
//  CreatePageData.swift
//  
//
//  Created by Jawad Hussain Farooqui on 01/11/21.
//

import Fluent
import Vapor

struct CreatePageData: AsyncMigration {
    
    func prepare(on database: Database) async throws {
        
        guard let book =  try await Book.query(on: database)
            .filter(\.$title == "Server-side Swift with Vapor")
            .first() else { throw Abort(.notFound) }
        
        let pages: [Page] = [
            .init(number: 1, chapter: "Introduction", section: "Introduction", content: "lorem ipsum", isSample: true, bookId: try book.requireID()),
            .init(number: 2, chapter: "Getting Started", section: "Download materials", content: "Links to download projects contains بسم", isSample: false, bookId: try book.requireID()),
            .init(number: 3, chapter: "Main Body", section: "Main", content: "lorem ipsum", isSample: false, bookId: try book.requireID()),
            .init(number: 4, chapter: "Where to go from here", section: nil, content: "Reference Books contains بِسْمِ", isSample: true, bookId: try book.requireID())
        ]
        
        try await pages.create(on: database)
    }
    
    func revert(on database: Database) async throws {
        try await Page.query(on: database).delete()
    }
}


