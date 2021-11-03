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
import FluentPostgresDriver
import FluentMySQLDriver
import Vapor

// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    /**
     docker run --name postgres
       -e POSTGRES_DB=vapor_database \
       -e POSTGRES_USER=vapor_username \
       -e POSTGRES_PASSWORD=vapor_password \
       -p 5432:5432 -d postgres
     */
    
    /*
    let dbConfig = PostgresConfiguration(
     hostname: Environment.get("DATABASE_HOST") ?? "localhost",
     port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? PostgresConfiguration.ianaPortNumber,
     username: Environment.get("DATABASE_USERNAME") ?? "vapor_username",
     password: Environment.get("DATABASE_PASSWORD") ?? "vapor_password",
     database: Environment.get("DATABASE_NAME") ?? "vapor_database")
     
     app.databases.use(.postgres(configuration: dbConfig, maxConnectionsPerEventLoop: 1), as: .psql)
     */
    
    /// docker run --name=mysql-server -e MYSQL_USER=vapor_username -e MYSQL_ROOT_PASSWORD=vapor_password -e MYSQL_DATABASE=vapor_database -e MYSQL_PASSWORD=vapor_password  -p 3307:3306 -d mysql
    
    var tls = TLSConfiguration.makeClientConfiguration()
    tls.certificateVerification = .none
    
    let dbConfig = MySQLConfiguration(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? 3307, // MySQLConfiguration.ianaPortNumber,
        username: Environment.get("DATABASE_USERNAME") ?? "vapor_username",
        password: Environment.get("DATABASE_PASSWORD") ?? "vapor_password",
        database: Environment.get("DATABASE_NAME") ?? "vapor_database",
        tlsConfiguration: tls)
    
    app.databases.use(.mysql(configuration: dbConfig, maxConnectionsPerEventLoop: 1), as: .mysql)

    //Create Tables
    app.migrations.add(CreateBook())
    app.migrations.add(CreatePage())
    app.migrations.add(CreateAuthor())
    app.migrations.add(CreateBookAuthorPivot())
    
    //Create Table Data
    app.migrations.add(CreateBookData())
    app.migrations.add(CreatePageData())
    app.migrations.add(CreateAuthorData())

    //Add logging
    app.logger.logLevel = .debug
    
    //Automatically run migrations and wait for the result
    try app.autoMigrate().wait()
    
    // register routes
    try routes(app)
}
