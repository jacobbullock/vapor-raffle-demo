//
// Created by Jacob Bullock on 2019-01-17.
//

import App
import Vapor
import FluentSQLite

extension Application {
    static func testable(envArgs: [String]? = nil) throws -> Application {
        var config = Config.default()
        var services = Services.default()
        var env = Environment.testing

        if let environmentArgs = envArgs {
            env.arguments = environmentArgs
        }

        try App.configure(&config, &env, &services)
        let app = try Application(config: config,
                                  environment: env,
                                  services: services)
        try App.boot(app)

        return app
    }
}