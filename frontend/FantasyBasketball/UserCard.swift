import Foundation

struct UserCard: Identifiable, Decodable {
    var id: UUID = UUID()  // API'den id gelmediği için local UUID oluşturuyoruz
    let playerName: String
    let overallRating: Int
    let acquiredAt: String
    let rarity: String

    var formattedDate: String {
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: acquiredAt) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .medium
            displayFormatter.timeStyle = .short
            return displayFormatter.string(from: date)
        }
        return acquiredAt
    }

    // 🔥 Backend alan isimleri farklı olduğu için mapping yapıyoruz!
    enum CodingKeys: String, CodingKey {
        case playerName = "player_name"
        case overallRating = "overall_rating"
        case acquiredAt = "acquired_at"
        case rarity = "rarity"
    }
}
