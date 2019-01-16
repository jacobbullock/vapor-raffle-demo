//
//  RaffleEntriesController.swift
//  App
//
//  Created by Jacob Bullock on 1/4/19.
//

import Vapor
import FluentSQLite

struct RaffleEntriesController: RouteCollection {
    func boot(router: Router) throws {
        let rafflesGroup = router.grouped("raffles", Raffle.parameter, "entries")
        rafflesGroup.get("new", use: newHandler)
        
        let route = router.grouped("entries")
        route.post(Entry.self, use: createHandler)
    }
    
    func createHandler(_ req: Request, entry: Entry) throws -> Future<View> {
        return entry.save(on: req).flatMap(to: View.self) { entry in
            guard let _ = entry.id else {
                throw Abort(.internalServerError)
            }
            return Raffle.query(on: req).filter(\.id == entry.raffleID).first().flatMap(to: View.self) { raffle in
                guard let raffle = raffle else {
                    throw Abort(.internalServerError)
                }
                return try req.view().render("entries/success", raffle.context)
            }
        }
    }
    
    func newHandler(_ req: Request) throws -> Future<View> {
        return try req.parameters.next(Raffle.self).flatMap { raffle in
            return try req.view().render("entries/new", raffle.context)
        }
    }
}
