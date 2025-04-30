import Foundation

class APIService {
    static let shared = APIService()
    private let baseURL = "http://127.0.0.1:8000/api/"
    
    // Takımları çekmek için bir fonksiyon
    func fetchTeams(completion: @escaping (Result<[Team], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)teams/") else { return }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                let error = NSError(domain: "DataError", code: 0, userInfo: nil)
                completion(.failure(error))
                return
            }
            
            do {
                let teams = try JSONDecoder().decode([Team].self, from: data)
                completion(.success(teams))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    func fetchPlayers(completion: @escaping (Result<[Player], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/players/") else { return }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                let error = NSError(domain: "DataError", code: 0, userInfo: nil)
                completion(.failure(error))
                return
            }
            
            do {
                let players = try JSONDecoder().decode([Player].self, from: data)
                completion(.success(players))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }

}
