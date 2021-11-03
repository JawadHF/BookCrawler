//
//  CreateBookAuthorPivot.swift
//  
//
//  Created by Jawad Hussain Farooqui on 31/10/21.
//

import Fluent

struct CreateBookAuthorPivot: AsyncMigration {
    
  func prepare(on database: Database) async throws {
    try await database.schema("book-author-pivot")
      .id()
      .field("book_id", .uuid, .required,
        .references("books", "id", onDelete: .cascade))
      .field("author_id", .uuid, .required,
        .references("authors", "id", onDelete: .cascade))
      .field("words", .int, .required)
      .create()
  }
  
  func revert(on database: Database) async throws {
    try await database.schema("book-author-pivot").delete()
  }
}

