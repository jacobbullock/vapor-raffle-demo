//
//  RafflesController.swift
//  App
//
//  Created by Jacob Bullock on 1/4/19.
//

import Vapor
import FluentSQLite

struct RafflesController: RouteCollection {
    func boot(router: Router) throws {
        let route = router.grouped("raffles")
        route.post(Raffle.self, use: createHandler)
        route.get(Raffle.parameter, use: showHandler)
        route.get("new", use: newHandler)
        route.get(use: indexHandler)
        
        route.get(Raffle.parameter, "run", use: runHandler)
        route.get(Raffle.parameter, "winners", use: winnersHandler)
        route.get(Raffle.parameter, "clear_winners", use: clearWinnersHandler)
        route.get(Raffle.parameter, "select_winner", use: selectWinnerHandler)
    }

    func indexHandler(_ req: Request) -> Future<[Raffle]> {
        return Raffle.query(on: req).all()
    }
    
    func createHandler(_ req: Request, raffle: Raffle) throws -> Future<Response> {
        return raffle.save(on: req).map(to: Response.self) { raffle in
            guard let id = raffle.id else {
                throw Abort(.internalServerError)
            }
            return req.redirect(to: "/raffles/\(id)")
        }
    }

    func newHandler(_ req: Request) throws -> Future<View> {
        return try req.view().render("raffles/new")
    }
    
    func showHandler(_ req: Request) throws -> Future<View> {
        return try req.parameters.next(Raffle.self).flatMap(to: View.self) { raffle in
            return try raffle.entries.query(on: req).all().flatMap(to: View.self) { entries in
                var context = raffle.context
                context.entries = entries
                return try req.view().render("raffles/show", context)
            }
        }
    }
    
    func runHandler(_ req: Request) throws -> Future<View> {
        return try req.parameters.next(Raffle.self).flatMap(to: View.self) { raffle in
            return Entry.query(on: req).filter(\.raffleID == raffle.id!).all().flatMap(to: View.self) { entries in
                var context = raffle.context
                context.entries = entries
                return try req.view().render("raffles/run", context)
            }
        }
    }
    
    func selectWinnerHandler(_ req: Request) throws -> Future<Entry> {
        return try req.parameters.next(Raffle.self).flatMap(to: Entry.self) { raffle in
            return try raffle.eligibleEntries(req).flatMap(to: Entry.self) { entries in
                guard let entry = entries.randomElement() else {
                    throw Abort(.internalServerError)
                }
                entry.drawnAt = Date()
                return entry.save(on: req)
            }
        }
    }
    
    func winnersHandler(_ req: Request) throws -> Future<[Entry]> {
        return try req.parameters.next(Raffle.self).flatMap(to: [Entry].self) { raffle in
            return try raffle.draws(req)
        }
    }
    
    func clearWinnersHandler(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(Raffle.self).flatMap(to: HTTPStatus.self) { raffle in
            var results: [Future<Entry>] = []
            return try raffle.draws(req).flatMap(to: HTTPStatus.self) { entries in
                for entry in entries {
                    entry.drawnAt = nil
                    results.append(entry.save(on: req))
                }
                return results.flatten(on: req).transform(to: HTTPStatus.noContent)
            }
        }
    }
    
}
