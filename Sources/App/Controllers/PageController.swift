//
//  PageController.swift
//  
//
//  Created by Jawad Hussain Farooqui on 02/11/21.
//

import Fluent
import Vapor
//For Raw SQL
import SQLKit
import FluentSQL
//import MySQLNIO
import FluentMySQLDriver


struct PageController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let pages = routes.grouped("pages")
        pages.get(use: index)
        pages.post(use: create)
        pages.get(":pageId", use: get)
        pages.group(":pageId") { page in
            page.delete(use: delete)
        }
        pages.get("search", use: search)
    }

    func index(req: Request) async throws -> [Page] {
        try await Page.query(on: req.db).all()
    }

    func create(req: Request) async throws -> Page {
        let page = try req.content.decode(Page.self)
        do {
            try await page.create(on: req.db)
        } catch let error as DatabaseError where error.isConstraintFailure {
            throw Abort(.forbidden, reason: "An page with that number already exists or the associated key referenced is incorrect")
        }
        return page
    }
    
    func get(_ req: Request) async throws -> Page {
        guard let page = try await Page.find(req.parameters.get("pageId"), on: req.db) else {
            throw Abort(.notFound)
        }
        return page
    }

    func delete(req: Request) async throws -> HTTPStatus {
        
        guard let pageID = req.parameters.get("pageId", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid pageId")
        }
        guard let page = try await Page.find( pageID, on: req.db) else {
            throw Abort(.notFound)
        }
        try await page.delete(on: req.db)
        return .noContent
    }
    
    
    func search(req: Request) async throws -> [Page] {
        
        guard let searchTerm = req.query[String.self, at: "term"] else {
           throw Abort(.badRequest, reason: "invalid search query")
         }
        
        
        /*
        let matchingPages = try await Page.query(on: req.db)
           .filter(\.$content ~~ searchTerm)    //Uses LIKE %searchTerm% . Is a case insensitive search with MySQL
           .all()
         */
        
        /*
        let query = Planet.query(on: req.db)
        if req.db is SQLDatabase {
            // The underlying database driver is SQL.
            query.filter(.sql(raw: "LOWER(name) = 'earth'"))
        } else {
            // The underlying database driver is _not_ SQL.
        }*/
        
        /*
        let q = "%\(searchTerm)%"
        let sqlString: SQLQueryString = #"concat(contacts.firstName, " ", contacts.lastName) LIKE \#(bind: q)"#
        group.filter(.sql(sqlString))
         */
        
        guard let sqldb = req.db as? SQLDatabase else {
          throw Abort(.internalServerError)
        }
        
        // MARK: Avoid Raw SQL susceptible to SQL Injection
        //let dbQuery = sqldb.raw("SELECT * FROM pages where content LIKE '%\(searchTerm)%'")
        
        // MARK: Use Parameterized Queries for custom SQL to safeguard against SQL Injection
        let table = "pages"
        let searchExpression = "%\(searchTerm)%"
        let query = sqldb.raw("SELECT * FROM \(raw: table) WHERE content LIKE \(bind: searchExpression)")
        let matchingPages = try await query.all(decoding: Page.self).get()
        
        /*
        let query = SQLRaw("select * from pages where content LIKE ")
        SQLBind(searchTerm)
        SQLBind("%" + searchTerm.description + "%") //SQLRaw("\"%" + string.description + "%\"")
         */
        
       
        
        /*
        guard let sqldb = req.db as? MySQLDatabase else {
          throw Abort(.internalServerError)
        }
        let query = Page.query(on: req.db)
        //if req.db is SQLDatabase {
            // The underlying database driver is SQL.
        let matchingPages = try await query.filter(.sql(raw: "content LIKE '%\(searchTerm)%'")).all()
        //}
         */
        
        return matchingPages
    }
}




