import Foundation

struct Team: Codable, Identifiable {
    let id: Int
    let name: String
    let city: String
    let established_year: Int
    let logo: String? 
    let arena_name: String?
}
