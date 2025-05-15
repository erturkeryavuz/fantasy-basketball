import SwiftUI

struct PlayersView: View {
    @State private var players: [Player] = []
    @State private var errorMessage: String?

    @State private var selectedPosition: String = "All"
    @State private var selectedCountry: String = "All"
    @State private var selectedTeam: String = "All"
    @State private var minimumRating: Int = 0

    var allPositions: [String] {
        let set = Set(players.map { $0.position })
        return ["All"] + set.sorted()
    }

    var allCountries: [String] {
        let set = Set(players.map { $0.nationality })
        return ["All"] + set.sorted()
    }

    var allTeams: [String] {
        let set = Set(players.map { $0.teamName })
        return ["All"] + set.sorted()
    }

    var filteredPlayers: [Player] {
        players.filter { player in
            (selectedPosition == "All" || player.position == selectedPosition) &&
            (selectedCountry == "All" || player.nationality == selectedCountry) &&
            (selectedTeam == "All" || player.teamName == selectedTeam) &&
            Int(player.overallRating) >= minimumRating
        }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 10) {
                Text("Players")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color.primary)
                    .padding(.top, 8)
                    .frame(maxWidth: .infinity, alignment: .center)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        Label {
                            Picker("Position", selection: $selectedPosition) {
                                ForEach(allPositions, id: \.self) { Text($0) }
                            }
                        } icon: {
                            Image(systemName: "figure.walk").foregroundColor(.orange)
                        }

                        Label {
                            Picker("Country", selection: $selectedCountry) {
                                ForEach(allCountries, id: \.self) { Text($0) }
                            }
                        } icon: {
                            Image(systemName: "globe").foregroundColor(.orange)
                        }

                        Label {
                            Picker("Team", selection: $selectedTeam) {
                                ForEach(allTeams, id: \.self) { Text($0) }
                            }
                        } icon: {
                            Image(systemName: "sportscourt").foregroundColor(.orange)
                        }

                        HStack(spacing: 6) {
                            Image(systemName: "star.fill").foregroundColor(.orange)
                            Text("\(minimumRating)")
                            Slider(value: Binding(get: {
                                Double(minimumRating)
                            }, set: { newValue in
                                minimumRating = Int(newValue)
                            }), in: 0...99, step: 1)
                                .frame(width: 100)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(10)
                .background(.ultraThinMaterial)
                .cornerRadius(16)
                .shadow(color: .gray.opacity(0.7), radius: 5, x: 0, y: 2)

                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                } else {
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 4)], spacing: 4) {
                            ForEach(filteredPlayers) { player in
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


                                        Text(player.teamName)
                                            .font(.caption2)
                                            .foregroundColor(.white)
                                            .multilineTextAlignment(.center)
                                            .lineLimit(1)

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
                print("👀 PlayersView açıldı, fetchPlayers() çağrılacak")
                APIService.shared.fetchPlayers { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let data):
                            print("✅ Oyuncular geldi: \(data.count) adet")
                            self.players = data
                        case .failure(let error):
                            print("❌ Hata oluştu: \(error.localizedDescription)")
                            self.errorMessage = "Error loading players: \(error.localizedDescription)"
                        }
                    }
                }
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

    func ratingColor(for rating: Int) -> Color {
        switch rating {
        case 95...99:
            return Color(red: 0.1, green: 0.2, blue: 0.6)
        case 90..<95:
            return Color(red: 0.9, green: 0.1, blue: 0.9)
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


struct PlayersView_Previews: PreviewProvider {
    static var previews: some View {
        PlayersView()
    }
}
