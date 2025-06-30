//
//  PageLoader.swift
//  BookCrawler
//
//  Created by Jawad Farooqui on 30/06/25.
//

import Vapor

class PageLoader {
    typealias Handler = (Result<Page, Error>) -> Void

    private let cache = Cache<Page.IDValue, Page>()

    func loadPage(req: Request, withID id: Page.IDValue) async throws -> Page {
        if let cached = cache[id] {
            return cached
        }
        
        guard let page = try await Page.find(id, on: req.db) else {
            throw Abort(.notFound)
        }
        return page
    }
}
