//
//  RafflesController.swift
//  App
//
//  Created by Jacob Bullock on 1/14/19.
//

import Vapor
import FluentSQLite

struct API {
    struct RafflesController: RouteCollection {
        func boot(router: Router) throws {
            let route = router.grouped("api", "raffles")
            route.post(Raffle.self, use: createHandler)
            route.get(use: indexHandler)
        }
        
        func createHandler(_ req: Request, raffle: Raffle) throws -> Future<Raffle> {
            return raffle.save(on: req)
        }
        
        func indexHandler(_ req: Request) -> Future<[Raffle]> {
            return Raffle.query(on: req).all()
        }
    }
}
