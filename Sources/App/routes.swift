import Vapor
import Leaf

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    router.get { req in
        return "Vapor Raffle"
    }

    try router.register(collection: API.RafflesController())
    try router.register(collection: RafflesController())
    try router.register(collection: RaffleEntriesController())
}
