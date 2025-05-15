import SwiftUI

struct TeamsView: View {
    @State private var teams: [Team] = []
    @State private var errorMessage: String?

    var body: some View {
        NavigationView {
            VStack(spacing: 10) {
                Text("Teams")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color.primary)
                    .padding(.top, 8)
                    .frame(maxWidth: .infinity, alignment: .center)

                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                } else {
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 120), spacing: 6)], spacing: 6) {
                            ForEach(teams) { team in
                                NavigationLink(destination: TeamPlayersView(teamId: team.id)) {
                                    VStack(spacing: 6) {
                                        if let logoURL = team.logo, let url = URL(string: logoURL) {
                                            AsyncImage(url: url) { phase in
                                                switch phase {
                                                case .empty:
                                                    ProgressView()
                                                case .success(let image):
                                                    image
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fit)
                                                        .frame(width: 50, height: 50)
                                                case .failure:
                                                    Image(systemName: "photo")
                                                        .resizable()
                                                        .frame(width: 50, height: 50)
                                                        .foregroundColor(.gray)
                                                @unknown default:
                                                    EmptyView()
                                                }
                                            }
                                        }

                                        Text(team.name)
                                            .font(.caption)
                                            .fontWeight(.semibold)
                                            .multilineTextAlignment(.center)
                                            .frame(maxHeight: 30)

                                        Text(team.city)
                                            .font(.caption2)
                                            .foregroundColor(.white)

                                        Text("Since \(team.establishedYear)")
                                            .font(.caption2)
                                            .foregroundColor(.white.opacity(0.7))
                                    }
                                    .padding()
                                    .frame(width: 170, height: 120)
                                    .background(Color.gray.opacity(0.6))
                                    .cornerRadius(12)
                                    .shadow(color: .black.opacity(0.5), radius: 3, x: 0, y: 1)
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .onAppear {
                print("📌 Token at Launch = \(UserDefaults.standard.string(forKey: "userToken") ?? "YOK")")

                fetchTeams()
            }
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color(.systemGray2), Color.orange.opacity(0.65)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
        }
    }

    private func fetchTeams() {
        APIService.shared.fetchTeams { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let teams):
                    self.teams = teams
                case .failure(let error):
                    self.errorMessage = "Failed to load teams: \(error.localizedDescription)"
                }
            }
        }
    }
}

struct TeamsView_Previews: PreviewProvider {
    static var previews: some View {
        TeamsView()
    }
}
