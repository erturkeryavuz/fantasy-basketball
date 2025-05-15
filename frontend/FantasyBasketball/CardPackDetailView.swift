import SwiftUI


struct CardPackDetailView: View {
    let pack: CardPack
    @Environment(\.dismiss) var dismiss

    @State private var isOpening = false
    @State private var showCard = false
    @State private var isBuyPressed = false
    @State private var isBackPressed = false
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    @State private var openedPlayer: OpenedPlayer? = nil
    @State private var newCredits: Int? = nil

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: pack.imageName)
                .resizable()
                .scaledToFit()
                .frame(width: isOpening ? 150 : 100, height: isOpening ? 150 : 100)
                .rotationEffect(.degrees(isOpening ? 360 : 0))
                .foregroundColor(.orange)
                .animation(.easeInOut(duration: 1.0), value: isOpening)

            Text(pack.name)
                .font(.largeTitle)
                .fontWeight(.bold)

            Text(pack.description)
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Text("\u{1F4B0} \(pack.price) Coins")
                .font(.title2)
                .foregroundColor(.orange)

            if let updatedCredits = newCredits {
                Text("\u{1F504} Updated Coins: \(updatedCredits)")
                    .font(.subheadline)
                    .foregroundColor(.green)
            }

            Spacer()

            if let errorMessage = errorMessage {
                Text("\u{274C} \(errorMessage)")
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.bottom, 5)
            }

            if showCard, let player = openedPlayer {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.yellow)
                    .frame(width: 200, height: 300)
                    .overlay(
                        VStack(spacing: 10) {
                            Text("\u{1F389} You Got:")
                                .font(.headline)
                            Text(player.name)
                                .font(.title2)
                                .fontWeight(.bold)
                            Text("Rarity: \(player.rarity)")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .foregroundColor(.black)
                    )
                    .transition(.scale)
            }



            Button(action: {
                isLoading = true
                errorMessage = nil

                APIService.shared.openCardPack(pack: pack) { result in
                    DispatchQueue.main.async {
                        isLoading = false
                        switch result {
                        case .success(let response):
                            self.openedPlayer = response.player  // ✅ burası artık Player oluyor
                            self.newCredits = response.new_credits
                            withAnimation {
                                isOpening = true
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                                withAnimation(.spring()) {
                                    showCard = true
                                }
                            }

                        case .failure(let error):
                            self.errorMessage = error.localizedDescription
                        }
                    }
                }

            }) {
                Text(showCard ? "Card Opened!" : "Buy & Open")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(width: 230, height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.orange, Color.red]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1.5)
                            .blur(radius: 2)
                    )
                    .scaleEffect(isBuyPressed ? 0.95 : 1.0)
                    .animation(.easeInOut(duration: 0.2), value: isBuyPressed)
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(showCard || isLoading)
            .onLongPressGesture(minimumDuration: 0.1, pressing: { pressing in
                isBuyPressed = pressing
            }, perform: {})

            Button(action: {
                dismiss()
            }) {
                HStack {
                    Image(systemName: "arrowshape.turn.up.backward.fill")
                    Text("Back")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(width: 230, height: 50)
                .background(Color.orange)
                .cornerRadius(12)
                .scaleEffect(isBackPressed ? 0.95 : 1.0)
                .animation(.easeInOut(duration: 0.2), value: isBackPressed)
            }
            .buttonStyle(PlainButtonStyle())
            .onLongPressGesture(minimumDuration: 0.1, pressing: { pressing in
                isBackPressed = pressing
            }, perform: {})

            Spacer(minLength: 20)
        }
        .padding()
        .navigationBarBackButtonHidden(true)
    }
}

struct CardPackDetailView_Previews: PreviewProvider {
    static var previews: some View {
        CardPackDetailView(pack: samplePacks[0])
    }
}
