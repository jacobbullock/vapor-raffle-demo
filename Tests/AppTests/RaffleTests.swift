//
// Created by Jacob Bullock on 2019-01-17.
//

@testable import App
import Vapor
import FluentSQLite
import XCTest

final class RaffleTests: XCTestCase {
    var app: Application!
    var conn: SQLiteConnection!

    override func setUp() {
        app = try! Application.testable()
        conn = try! app.newConnection(to: .sqlite).wait()
    }

    override func tearDown() {
        try? app.runningServer?.close().wait()
    }

    func testRafflesCanBeRetrievedFromAPI() throws {
        let expectedRaffleTitle = "RaffleTitle1"

        let raffle = Raffle(title: expectedRaffleTitle)
        let savedRaffle = try raffle.save(on: conn).wait()
        _ = try Raffle(title: "Other Raffle Title").save(on: conn).wait()

        let responder = try app.make(Responder.self)
        let request = HTTPRequest(method: .GET,
                                  url: URL(string: "/api/raffles")!)

        let wrappedRequest = Request(http: request, using: app)
        let response = try responder
                            .respond(to: wrappedRequest)
                            .wait()

        let data = response.http.body.data
        let raffles = try JSONDecoder().decode([Raffle].self, from: data!)

        XCTAssertEqual(raffles.count, 2)
        XCTAssertEqual(raffles[0].title, expectedRaffleTitle)
        XCTAssertEqual(raffles[0].id, savedRaffle.id)
    }

}
