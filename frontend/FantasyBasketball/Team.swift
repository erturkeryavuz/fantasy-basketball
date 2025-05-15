import SwiftUI


struct Team: Identifiable, Codable {
    let id: Int
    let name: String
    let city: String
    let logo: String?
    let establishedYear: Int

    enum CodingKeys: String, CodingKey {
        case id, name, city, logo
        case establishedYear = "established_year"
    }
}
