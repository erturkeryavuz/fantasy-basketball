import SwiftUI

struct TeamPlayersView: View {
    let teamId: Int
    @State private var players: [Player] = []
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 10) {
            Text("Team Players")
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
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 120), spacing: 4)], spacing: 4) {
                        ForEach(players) { player in
                            NavigationLink(destination: PlayerDetailView(player: player)) {
                                VStack(spacing: 3) {
                                    if let profilePictureURL = player.profilePicture,
                                       let url = URL(string: profilePictureURL) {
                                        AsyncImage(url: url) { phase in
                                            switch phase {
                                            case .empty:
                                                ProgressView()
                                            case .success(let image):
                                                image
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                                    .frame(width: 40, height: 40)
                                                    .clipShape(Circle())
                                                    .overlay(Circle().stroke(Color.orange, lineWidth: 1))
                                            case .failure:
                                                Image(systemName: "person.circle.fill")
                                                    .resizable()
                                                    .frame(width: 40, height: 40)
                                                    .foregroundColor(.gray)
                                            @unknown default:
                                                EmptyView()
                                            }
                                        }
                                    }

                                    Text(player.name)
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .multilineTextAlignment(.center)
                                        .frame(maxHeight: 30)

                                    Text("OVR: \(Int(player.overallRating))")
                                        .font(.caption2)
                                        .fontWeight(.bold)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(
                                            RoundedRectangle(cornerRadius: 6)
                                                .fill(ratingColor(for: Int(player.overallRating)).opacity(0.15))
                                        )
                                        .foregroundColor(ratingColor(for: Int(player.overallRating)))
                                }
                                .padding()
                                .frame(width: 120, height: 120)
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
            fetchTeamPlayers()
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

    private func fetchTeamPlayers() {
        APIService.shared.fetchPlayers(forTeamId: teamId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    self.players = data
                case .failure(let error):
                    self.errorMessage = "Decoding error: \(error.localizedDescription)"
                }
            }
        }
    }



    private func ratingColor(for rating: Int) -> Color {
        switch rating {
        case 95...99:
            return Color(red: 0.1, green: 0.2, blue: 0.6)
        case 90..<95:
            return Color.pink
        case 85..<90:
            return Color.blue
        case 80..<85:
            return Color.purple
        case 75..<80:
            return Color.red
        default:
            return Color.yellow.opacity(0.7)
        }
    }
}

struct TeamPlayersView_Previews: PreviewProvider {
    static var previews: some View {
        TeamPlayersView(teamId: 1)
    }
}
