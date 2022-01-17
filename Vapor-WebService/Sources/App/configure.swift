import Fluent
import FluentPostgresDriver
import Vapor
import APNS

// configures your application
public func configure(_ app: Application) throws {

	// check we have the database url
	if let urlString = Environment.get("DATABASE_URL"),
	   var postgresConfig = PostgresConfiguration(url: urlString) {

		var tlsConfiguration = TLSConfiguration.makeClientConfiguration()
		tlsConfiguration.certificateVerification = .none
		postgresConfig.tlsConfiguration = tlsConfiguration

		app.databases.use(.postgres(configuration: postgresConfig), as: .psql)

	} else {

		// running docker locally
		app.databases.use(.postgres(
			hostname: Environment.get("DATABASE_HOST") ?? "localhost",
			port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? PostgresConfiguration.ianaPortNumber,
			username: Environment.get("DATABASE_USERNAME") ?? "vapor_username",
			password: Environment.get("DATABASE_PASSWORD") ?? "vapor_password",
			database: Environment.get("DATABASE_NAME") ?? "vapor_database"
		), as: .psql)

	}

	app.migrations.add(CreateToken())

	if app.environment == .development {
		try app.autoMigrate().wait()
	}

	if app.environment != .production {
		app.http.server.configuration.hostname = "0.0.0.0"
	}

	let apnsEnvironment: APNSwiftConfiguration.Environment
	apnsEnvironment = app.environment == .production ? .production : .sandbox

	let auth: APNSwiftConfiguration.AuthenticationMethod = try .jwt(
		key: .private(pem: Environment.get("AUTH") ?? APNSKeys.esdsa.rawValue),
		keyIdentifier: "XXXXXXXXXX",
		teamIdentifier: "XXXXXXXXXX"
	)

	app.apns.configuration = .init(
		authenticationMethod: auth,
		topic: "ltd.domain.PushNotificationsTest",
		environment: apnsEnvironment
	)

	try routes(app)
}


enum APNSKeys: String {
case esdsa = """
-----BEGIN PRIVATE KEY-----
-----END PRIVATE KEY-----
"""
}
