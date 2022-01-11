
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

    /*
    let tlsConfiguration = TLSConfiguration.forClient(minimumTLSVersion: .tlsv11, trustRoots:  .file("path to the ca file, which can be found at https://s3.amazonaws.com/rds-downloads/rds-combined-ca-bundle.pem "))
        let mysqlConfig = try MySQLDatabaseConfig(url: "url to the database", capabilities: .default, characterSet: .utf8mb4_unicode_ci, transport: .customTLS(tlsConfiguration))!
        let mysql = MySQLDatabase(config: mysqlConfig)
     */

    /*
    extension Application {
        static let dbHost = Environment.get("DB_HOST")!
        static let dbUser = Environment.get("DB_USER")!
        static let dbPass = Environment.get("DB_PASS")!
        static let dbName = Environment.get("DB_NAME")!
        static let dbPort = Int(Environment.get("DB_PORT")!)!
        static let dbCert = Environment.get("DB_CERT")
        static let domainUrl = Environment.get("DOMAIN_URL")!
    }

    var tlsConfiguration: TLSConfiguration?
    if let dbCert = Application.dbCert, app.environment == .production {
        tlsConfiguration = try TLSConfiguration.forClient(trustRoots: .certificates([NIOSSLCertificate(bytes: Array(dbCert.utf8), format: .pem)]))
    }

    let config = PostgresConfiguration(hostname: Application.dbHost, port: Application.dbPort, username: Application.dbUser, password: Application.dbPass, database: Application.dbName, tlsConfiguration: tlsConfiguration) app.databases.use(.postgres(configuration: config, maxConnectionsPerEventLoop: 2), as: .psql)
     */

    
    var tls = TLSConfiguration.makeClientConfiguration()
    tls.certificateVerification = .none

    /*
    tls.certificateVerification = .fullVerification
    tls.minimumTLSVersion = .tlsv13
    tls.trustRoots = .file("/path/to/CA_cert_pem_crt_file")
     */

    let dbConfig = MySQLConfiguration(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? 3307, // MySQLConfiguration.ianaPortNumber,
        username: Environment.get("DATABASE_USERNAME") ?? "vapor_username",
        password: Environment.get("DATABASE_PASSWORD") ?? "vapor_password",
        database: Environment.get("DATABASE_NAME") ?? "vapor_database",
        tlsConfiguration: tls)

    app.databases.use(.mysql(configuration: dbConfig, maxConnectionsPerEventLoop: 2), as: .mysql)

    // Create Tables
    app.migrations.add(CreateBook())
    app.migrations.add(CreatePage())
    app.migrations.add(CreateAuthor())
    app.migrations.add(CreateBookAuthorPivot())

    // Create Table Data
    app.migrations.add(CreateBookData())
    app.migrations.add(CreatePageData())
    app.migrations.add(CreateAuthorData())

    // Add logging
    app.logger.logLevel = .debug

    // Automatically run migrations and wait for the result
    try app.autoMigrate().wait()

    // register routes
    try routes(app)
}
