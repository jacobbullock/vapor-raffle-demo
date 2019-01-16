//
//  Raffle.swift
//  App
//
//  Created by Jacob Bullock on 1/4/19.
//

import Vapor
import FluentSQLite

struct RaffleContext: Encodable {
    var id: Int
    var title: String = ""
    var entries: [Entry] = []
}

final class Raffle: Content {
    static var name: String = "raffles"
    
    var id: Int?
    var title: String
    
    init(id: Int? = nil, title: String) {
        self.id = id
        self.title = title
    }
}

extension Raffle {
    var entries: Children<Raffle, Entry> {
        return children(\.raffleID)
    }

    func draws(_ conn: DatabaseConnectable) throws -> Future<[Entry]> {
        return try entries.query(on: conn).filter(\.drawnAt != nil).all()
    }
    
    func eligibleEntries(_ conn: DatabaseConnectable) throws -> Future<[Entry]> {
        return try entries.query(on: conn).filter(\.drawnAt == nil).all()
    }

    var context: RaffleContext {
        return RaffleContext(id: self.id!, title: self.title, entries: [])
    }
}

extension Raffle: SQLiteModel { }
extension Raffle: Migration { }
extension Raffle: Parameter { }
