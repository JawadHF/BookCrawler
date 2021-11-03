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


