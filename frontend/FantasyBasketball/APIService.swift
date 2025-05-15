import Foundation

struct CardOpenResponse: Decodable {
    let message: String?
    let player: OpenedPlayer?
    let new_credits: Int?
}


struct LoginResponse: Decodable {
    let message: String?
    let username: String
    let email: String
    let token: String
}

class APIService {
    static let shared = APIService()
    private let baseURL = "http://127.0.0.1:8000/api/"
    
    
    struct UserProfile: Decodable {
        let username: String
        let credits: Int
    }

    func fetchUserProfile(completion: @escaping (Result<UserProfile, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)profile/") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        if let token = UserDefaults.standard.string(forKey: "userToken") {
            request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")
        }

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(error)); return
            }
            guard let data = data else {
                let error = NSError(domain: "APIService", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data"])
                completion(.failure(error)); return
            }
            do {
                let result = try JSONDecoder().decode(UserProfile.self, from: data)
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    private func authorizedRequest(url: URL, method: String = "GET", body: [String: Any]? = nil) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = UserDefaults.standard.string(forKey: "userToken") {
            request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")
        }

        if let body = body {
            request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        }

        return request
    }

    
    private func performGET<T: Decodable>(endpoint: String, completion: @escaping (Result<T, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)\(endpoint)") else { return }

        let request = authorizedRequest(url: url)

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(error)); return
            }
            guard let data = data else {
                let error = NSError(domain: "APIService", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])
                completion(.failure(error)); return
            }
            do {
                let result = try JSONDecoder().decode(T.self, from: data)
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    
    func fetchTeams(completion: @escaping (Result<[Team], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)teams/") else { return }
        let request = authorizedRequest(url: url)

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(error)); return
            }
            guard let data = data else {
                let error = NSError(domain: "APIService", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])
                completion(.failure(error)); return
            }
            do {
                let result = try JSONDecoder().decode([Team].self, from: data)
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    func fetchPlayers(forTeamId teamId: Int, completion: @escaping (Result<[Player], Error>) -> Void) {
        let urlString = "\(baseURL)players/?team=\(teamId)"
        guard let url = URL(string: urlString) else { return }

        let request = authorizedRequest(url: url)
        print("📤 TeamPlayersView için istek: \(url.absoluteString)")

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(error)); return
            }
            guard let data = data else {
                let error = NSError(domain: "APIService", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data"])
                completion(.failure(error)); return
            }
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let players = try decoder.decode([Player].self, from: data)
                completion(.success(players))
            } catch {
                print("❌ TeamPlayersView decode hatası: \(error.localizedDescription)")
                if let rawJson = String(data: data, encoding: .utf8) {
                    print("🧾 Gelen JSON:\n\(rawJson)")
                }
                completion(.failure(error))
            }
        }.resume()
    }
    func fetchPlayers(completion: @escaping (Result<[Player], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)players/") else { return }
        let request = authorizedRequest(url: url)
        print("📤 Fetching ALL players with token:", request.value(forHTTPHeaderField: "Authorization") ?? "No token")

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(error)); return
            }
            guard let data = data else {
                let error = NSError(domain: "APIService", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])
                completion(.failure(error)); return
            }
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let result = try decoder.decode([Player].self, from: data)
                completion(.success(result))
            } catch {
                print("❌ Decode error: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }.resume()
    }

    func fetchMyCards(completion: @escaping (Result<[UserCard], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)my-cards/") else { return }
        
        let request = authorizedRequest(url: url)

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(error)); return
            }
            guard let data = data else {
                let error = NSError(domain: "APIService", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])
                completion(.failure(error)); return
            }
            do {
                let result = try JSONDecoder().decode([UserCard].self, from: data)
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    
    func openCardPack(pack: CardPack, completion: @escaping (Result<CardOpenResponse, Error>) -> Void) {
        
        guard let url = URL(string: "\(baseURL)open-pack/") else { return }
        
        let body = ["pack_name": pack.name]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        // 🛠️ ÖNCE token'ı ekle:
        if let token = UserDefaults.standard.string(forKey: "userToken") {
            request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")
        }

        // ✅ SONRA debug print yap:
        print("📦 Gönderilen Body:", body)
        print("📤 Authorization Header:", request.value(forHTTPHeaderField: "Authorization") ?? "none")

        // Gövde ekle
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            completion(.failure(error)); return
        }

        
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(error)); return
            }
            guard let data = data else {
                let error = NSError(domain: "APIService", code: -2, userInfo: [NSLocalizedDescriptionKey: "No data from server"])
                completion(.failure(error)); return
            }
            do {
                let result = try JSONDecoder().decode(CardOpenResponse.self, from: data)
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    func login(email: String, password: String, completion: @escaping (Result<LoginResponse, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)token-login/") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = ["username": email, "password": password]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                let error = NSError(domain: "APIService", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])
                completion(.failure(error))
                return
            }

            do {
                let result = try JSONDecoder().decode(LoginResponse.self, from: data)

                // 📦 BURASI: Token ve Username kayıt ediliyor!
                UserDefaults.standard.set(result.token, forKey: "userToken")
                UserDefaults.standard.set(result.username, forKey: "loggedInUsername")

                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

}
