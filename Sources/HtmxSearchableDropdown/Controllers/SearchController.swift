import Leaf
import Vapor

struct SearchContext: Encodable {
    let users: [User]
    let searchTerm: String
    let tooShort: Bool
}

struct SearchController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        routes.get("", use: index)
        routes.get("search", use: search)
    }

    func index(req: Request) async throws -> View {
        return try await req.view.render("index")
    }

    func search(req: Request) async throws -> View {
        // Get search query
        let searchTerm = try req.query.get(String.self, at: "q")

        // Check if search term is less than 3 characters
        if searchTerm.count < 3 {
            let context = SearchContext(users: [], searchTerm: searchTerm, tooShort: true)
            return try await req.view.render("partials/dropdown-results", context)
        }

        // Sample data - in real app, this would come from database
        let allUsers = [
            User(id: 1, name: "Isaac Newton", email: "newton@math.com"),
            User(id: 2, name: "Leonhard Euler", email: "euler@math.com"),
            User(id: 3, name: "Carl Friedrich Gauss", email: "gauss@math.com"),
            User(id: 4, name: "Alan Turing", email: "turing@math.com"),
            User(id: 5, name: "Emmy Noether", email: "noether@math.com"),
            User(id: 6, name: "Pythagoras", email: "pythagoras@math.com"),
            User(id: 7, name: "Euclid", email: "euclid@math.com"),
            User(id: 8, name: "Archimedes", email: "archimedes@math.com"),
            User(id: 9, name: "Bernhard Riemann", email: "riemann@math.com"),
            User(id: 10, name: "Pierre de Fermat", email: "fermat@math.com"),
            User(id: 11, name: "Sophie Germain", email: "germain@math.com"),
            User(id: 12, name: "Ada Lovelace", email: "lovelace@math.com"),
            User(id: 13, name: "David Hilbert", email: "hilbert@math.com"),
            User(id: 14, name: "Henri Poincaré", email: "poincare@math.com"),
            User(id: 15, name: "John von Neumann", email: "neumann@math.com"),
        ]

        // Filter users based on search term
        let filteredUsers =
            searchTerm.isEmpty
            ? allUsers
            : allUsers.filter { user in
                user.name.lowercased().contains(searchTerm.lowercased())
                    || user.email.lowercased().contains(searchTerm.lowercased())
            }

        // Return partial view with filtered results
        let context = SearchContext(users: filteredUsers, searchTerm: searchTerm, tooShort: false)
        return try await req.view.render("partials/dropdown-results", context)
    }
}
