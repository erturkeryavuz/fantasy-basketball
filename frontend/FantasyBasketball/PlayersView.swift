import SwiftUI

struct PlayersView: View {
    @State private var players: [Player] = []
    @State private var errorMessage: String?

    var body: some View {
        NavigationView {
            VStack {
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                } else {
                    List(players) { player in
                        NavigationLink(destination: PlayerDetailView(player: player)) {
                            HStack {
                                if let profilePictureURL = player.profilePicture, let url = URL(string: profilePictureURL) {
                                    AsyncImage(url: url) { phase in
                                        switch phase {
                                        case .empty:
                                            ProgressView()
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 50, height: 50)
                                                .clipShape(Circle())
                                        case .failure:
                                            Image(systemName: "person.circle.fill")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 50, height: 50)
                                                .foregroundColor(.gray)
                                        @unknown default:
                                            EmptyView()
                                        }
                                    }
                                } else {
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 50, height: 50)
                                        .foregroundColor(.gray)
                                }

                                VStack(alignment: .leading) {
                                    Text(player.name)
                                        .font(.headline)
                                    Text("Team: \(player.teamName)")
                                        .font(.subheadline)

                                    Text("Position: \(player.position), Age: \(player.age)")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                    Text(String(format: "Overall Rating: %.1f", player.overallRating))

                                        .font(.footnote)
                                        .foregroundColor(.blue)
                                }
                            }
                            .padding(.vertical, 5)
                        }
                    }
                    .navigationTitle("Players")
                }
            }
            .onAppear {
                fetchPlayers()
            }
        }
    }

    private func fetchPlayers() {
        guard let url = URL(string: "http://127.0.0.1:8000/api/players/") else {
            errorMessage = "Invalid URL"
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    errorMessage = "Failed to load players: \(error.localizedDescription)"
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    errorMessage = "No data received from server"
                }
                return
            }

            do {
                let decodedPlayers = try JSONDecoder().decode([Player].self, from: data)
                DispatchQueue.main.async {
                    players = decodedPlayers
                }
            } catch {
                DispatchQueue.main.async {
                    errorMessage = "Failed to decode players: \(error.localizedDescription)"
                    print("Decoding error:", error)
                }
            }
        }.resume()
    }
}

struct PlayersView_Previews: PreviewProvider {
    static var previews: some View {
        PlayersView()
    }
}

