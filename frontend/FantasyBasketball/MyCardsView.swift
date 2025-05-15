import SwiftUI

struct MyCardsView: View {
    @State private var myCards: [UserCard] = []
    @State private var isLoading = true

    var body: some View {
        NavigationStack {
          
            VStack(spacing: 0) {
             
                Text("My Cards")
                    .font(.system(size: 41, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.yellow, Color.orange, Color.red]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: Color.orange.opacity(0.8), radius: 10, x: 0, y: 5)
                    .overlay(
                        Text("My Cards")
                            .font(.system(size: 41, weight: .bold, design: .rounded))
                            .foregroundColor(.black.opacity(0.2))
                            .blur(radius: 4)
                    )
                   
                    .padding(.top)
                    
                    .padding(.bottom, 10)

             
                if isLoading {
                    ProgressView("Loading your cards...")
                        .padding()
                    Spacer() 
                } else if myCards.isEmpty {
                    Text("You have no cards.")
                        .foregroundColor(.gray)
                        .padding()
                    Spacer()
                } else {
                    
                    List(myCards) { card in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(card.playerName)
                                .font(.headline)

                            Text("\(card.overallRating) OVR")
                                .font(.subheadline)
                                .foregroundColor(.orange)

                            Text("Acquired: \(card.formattedDate)")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 6)
                    }
                   
                }
            }
           
            .onAppear {
                APIService.shared.fetchMyCards { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let cards):
                            self.myCards = cards
                        case .failure(let error):
                            if let decodingError = error as? DecodingError {
                                print("❌ JSON Decode Hatası:", decodingError)
                            } else {
                                print("❌ Error fetching cards:", error.localizedDescription)
                            }
                        }
                        self.isLoading = false
                    }
                }
            }
        }
    }
}

struct MyCardsView_Previews: PreviewProvider {
    static var previews: some View {
        MyCardsView()
    }
}
