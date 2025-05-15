import Foundation
import SwiftUI

class AuthService {
    static let shared = AuthService()
    private let baseURL = "http://127.0.0.1:8000/api/"
    
    // Token Login (DRF token authentication)
    func loginWithToken(username: String, password: String, completion: @escaping (Result<String, Error>) -> Void) {
        
        
        guard let url = URL(string: "\(baseURL)token-login/") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: String] = ["username": username, "password": password]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            completion(.failure(error))
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                let error = NSError(domain: "TokenLogin", code: 0, userInfo: nil)
                completion(.failure(error))
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: String],
                   let token = json["token"] {
                    UserDefaults.standard.set(token, forKey: "userToken")
                    print("📦 TOKEN:", token)
                    completion(.success("Token login successful"))
                } else {
                    let error = NSError(domain: "TokenLogin", code: 401, userInfo: [NSLocalizedDescriptionKey: "Invalid credentials"])
                    completion(.failure(error))
                }
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }


    func registerUser(username: String, email: String, password: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)register/") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: String] = [
            "username": username,
            "email": email,
            "password": password
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            completion(.failure(error))
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
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
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: String],
                   let message = json["message"] {
                    completion(.success(message))
                } else if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: String],
                          let error = json["error"] {
                    completion(.failure(NSError(domain: error, code: 400, userInfo: nil)))
                }
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }


    // Logout User
    func logout() {
            UserDefaults.standard.removeObject(forKey: "userToken")
            UserDefaults.standard.removeObject(forKey: "loggedInUsername")
        }


    
}

