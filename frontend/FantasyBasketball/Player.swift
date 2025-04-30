struct Player: Codable, Identifiable {
    let id: Int
    let name: String
    let team: Int
    let teamName: String
    let position: String
    let age: Int
    let height: Int
    let weight: Int
    let profilePicture: String?
    let bio: String
    let experienceYears: Int
    let nationality: String
    let overallRating: Int
    let bestSkill: String

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case team
        case teamName = "team_name"
        case position
        case age
        case height
        case weight
        case profilePicture = "profile_picture"
        case bio
        case experienceYears = "experience_years"
        case nationality
        case overallRating = "overall_rating"
        case bestSkill = "best_skill"
    }
}
