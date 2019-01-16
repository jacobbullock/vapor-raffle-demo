//
//  Entry.swift
//  App
//
//  Created by Jacob Bullock on 1/4/19.
//

import Vapor
import FluentSQLite

final class Entry: Content {
    static var name: String = "entries"
    
    var id: Int?
    var firstName: String
    var lastName: String
    var raffleID: Raffle.ID
    var drawnAt: Date?
    
    init(id: Int? = nil, firstName: String, lastName: String, raffleID: Raffle.ID) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.raffleID = raffleID
    }
}

extension Entry {
    var raffle: Parent<Entry, Raffle> {
        return parent(\.raffleID)
    }
}

extension Entry: SQLiteModel { }
extension Entry: Migration { }
extension Entry: Parameter { }
