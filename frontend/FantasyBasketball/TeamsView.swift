import SwiftUI

struct TeamsView: View {
    @State private var teams: [Team] = []
    @State private var errorMessage: String?

    var body: some View {
        VStack {
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            } else {
                List(teams) { team in
                    HStack {
                        // Logo Gösterimi
                        if let logoURL = team.logo, let url = URL(string: logoURL) {
                            AsyncImage(url: url) { image in
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 50, height: 50)
                                    .cornerRadius(5)
                            } placeholder: {
                                ProgressView()
                            }
                        } else {
                            Image(systemName: "photo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                                .foregroundColor(.gray)
                        }

                        // Metin Gösterimi
                        VStack(alignment: .leading) {
                            Text(team.name)
                                .font(.headline)
                            Text(team.city)
                                .font(.subheadline)
                            Text("Established: \(team.established_year)")
                                .font(.footnote)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.vertical, 5)
                }
                .navigationTitle("Teams")
            }
        }
        .onAppear {
            fetchTeams()
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
