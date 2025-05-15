import SwiftUI

// ✅ Backend'den gelen profil yapısına uygun struct
struct UserProfile: Decodable {
    let username: String
    let credits: Int
}

struct CardPack: Identifiable {
    let id = UUID()
    let name: String
    let price: Int
    let description: String
    let imageName: String
}

let samplePacks = [
    CardPack(name: "Gold Pack", price: 500, description: "1 card – %2 Ruby", imageName: "sparkles"),
    CardPack(name: "Amethyst Pack", price: 800, description: "1 card – %2 Amethyst", imageName: "hexagon"),
    CardPack(name: "Diamond Pack", price: 1000, description: "1 card – %2 Diamond", imageName: "diamond")
]

struct MarketplaceView: View {
    let packs = samplePacks
    @State private var userCoins: Int = 0
    @State private var isBackPressed: Bool = false
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 10) {
                HStack {
                    Text("PackMarket")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Spacer()

                    Label("\(userCoins)", systemImage: "creditcard.fill")
                        .padding(8)
                        .background(Color.orange.opacity(0.2))
                        .cornerRadius(10)
                }
                .padding()

                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 120), spacing: 12)], spacing: 12) {
                        ForEach(packs) { pack in
                            NavigationLink(destination: CardPackDetailView(pack: pack)) {
                                VStack(spacing: 10) {
                                    Image(systemName: pack.imageName)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 50)
                                        .foregroundColor(.orange)

                                    Text(pack.name)
                                        .font(.headline)

                                    Text(pack.description)
                                        .font(.caption)
                                        .multilineTextAlignment(.center)

                                    Text("💰 \(pack.price) Coins")
                                        .font(.subheadline)
                                        .foregroundColor(.orange)
                                }
                                .padding()
                                .frame(width: 160, height: 200)
                                .background(.ultraThinMaterial)
                                .cornerRadius(12)
                                .shadow(radius: 4)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding()
                }

                Button(action: {
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: "arrowshape.turn.up.backward.fill")
                        Text("Back to Main Page")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.orange)
                    .cornerRadius(12)
                    .padding(.horizontal)
                    .scaleEffect(isBackPressed ? 0.95 : 1.0)
                    .animation(.easeInOut(duration: 0.2), value: isBackPressed)
                }
                .buttonStyle(PlainButtonStyle())
                .onLongPressGesture(minimumDuration: 0.1, pressing: { pressing in
                    isBackPressed = pressing
                }, perform: {})
            }
            .navigationBarBackButtonHidden(true)
            .onAppear {
                fetchCredits()
            }
        }
    }

    // ✅ API çağrısı ile kredileri güncelle
    func fetchCredits() {
        guard let url = URL(string: "http://127.0.0.1:8000/api/profile/") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        if let token = UserDefaults.standard.string(forKey: "userToken") {
            request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")
        }

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let data = data {
                do {
                    let profile = try JSONDecoder().decode(UserProfile.self, from: data)
                    DispatchQueue.main.async {
                        self.userCoins = profile.credits
                    }
                } catch {
                    print("❌ Decoding error:", error)
                }
            } else if let error = error {
                print("❌ Network error:", error)
            }
        }.resume()
    }
}

struct MarketplaceView_Previews: PreviewProvider {
    static var previews: some View {
        MarketplaceView()
    }
}
