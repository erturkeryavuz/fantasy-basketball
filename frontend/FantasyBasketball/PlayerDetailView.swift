import SwiftUI
import UIKit

struct BlurView: UIViewRepresentable {
    var style: UIBlurEffect.Style

    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: style))
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}



struct PlayerDetailView: View {
    let player: Player
    @State private var isFlipped = false
    @State private var animateShine = false

    var body: some View {
        ZStack {
            backgroundGradient(for: playerRarity)
            .ignoresSafeArea()
            .overlay(
                BlurView(style: .systemMaterial)
                    .ignoresSafeArea()
            )


            ZStack {
                if isFlipped {
                    backCardView
                        .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                } else {
                    frontCardView
                }
            }
            .frame(width: 320, height: 480)
            .background(
                ZStack {
                    backgroundGradient(for: playerRarity)

                    if playerRarity == .DarkBlueDiamond || playerRarity == .pinkDiamond || playerRarity == .diamond {
                        shineOverlay
                    }
                    glowingBorder(for: playerRarity)
                }
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.blue.opacity(0.2), Color.yellow.opacity(0.4)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 3
                        )
                        .shadow(color: Color.yellow.opacity(0.5), radius: 10, x: 0, y: 0)
                )
            )
            .cornerRadius(20)
            .shadow(radius: 10)
            .rotation3DEffect(
                .degrees(isFlipped ? 180 : 0),
                axis: (x: 0, y: 1, z: 0)
            )
            .animation(.easeInOut(duration: 0.8), value: isFlipped)
            .onTapGesture {
                isFlipped.toggle()
            }
        }
        .navigationTitle(player.name)
        .navigationBarTitleDisplayMode(.inline)
    }

    var playerRarity: Rarity {
        let rating = player.overallRating
        switch rating {
        case 95...99: return .DarkBlueDiamond
        case 90..<95: return .pinkDiamond
        case 85..<90: return .diamond
        case 80..<85: return .amethyst
        case 75..<80: return .ruby
        default: return .gold
        }
    }
    



    private func glowingBorder(for rarity: Rarity) -> some View {
        RoundedRectangle(cornerRadius: 20)
            .strokeBorder(borderGradient(for: rarity), lineWidth: 4)
            .blur(radius: 4)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(borderGradient(for: rarity), lineWidth: 2)
                    .blendMode(.overlay)
                    .opacity(0.7)
            )
    }

    private func borderGradient(for rarity: Rarity) -> LinearGradient {
        switch rarity {
        case .DarkBlueDiamond:
            return LinearGradient(colors: [Color.blue, Color.white], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .pinkDiamond:
            return LinearGradient(colors: [Color.pink, Color.white], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .diamond:
            return LinearGradient(colors: [Color.cyan, Color.white], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .amethyst:
            return LinearGradient(colors: [Color.purple, Color.blue], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .ruby:
            return LinearGradient(colors: [Color.red, Color.orange], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .gold:
            return LinearGradient(colors: [Color.yellow, Color.orange], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }

    func rarityTitle(for rarity: Rarity) -> String {
        switch rarity {
        case .DarkBlueDiamond: return "Dark Blue Diamond 💠"
        case .pinkDiamond: return "Pink Diamond 💎"
        case .diamond: return "Diamond 🔷"
        case .amethyst: return "Amethyst 🟪"
        case .ruby: return "Ruby 🛑"
        case .gold: return "Gold ⭐️"
        }
    }

    private var frontCardView: some View {
        VStack(spacing: 15) {
            HStack(spacing: 8) {
                Text(rarityTitle(for: playerRarity))
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.white.opacity(0.9), Color.gray.opacity(0.7)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(color: .white.opacity(0.8), radius: 2, x: 0, y: 1)

            }
            .padding(.horizontal, 18)
            .padding(.vertical, 12)
            .background(
                BlurView(style: .systemThinMaterialLight)
                    .clipShape(RoundedRectangle(cornerRadius: 22))
                    .overlay(
                        RoundedRectangle(cornerRadius: 22)
                            .stroke(LinearGradient(colors: [Color.white.opacity(0.5), Color.gray.opacity(0.4)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1.5)
                            .shadow(color: Color.white.opacity(0.6), radius: 5)
                    )
            )
            .shadow(color: Color.white.opacity(0.2), radius: 10, x: 0, y: 0)
            .padding(.top, 8)


            if let profilePictureURL = player.profilePicture,
               let url = URL(string: profilePictureURL) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty: ProgressView()
                    case .success(let image):
                        image.resizable()
                            .scaledToFill()
                            .frame(width: 150, height: 150)
                            .clipShape(Circle())
                    case .failure:
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 150, height: 150)
                            .foregroundColor(.gray)
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .foregroundColor(.gray)
            }

            Text(player.name)
                .font(.title2)
                .fontWeight(.bold)

            Text(player.teamName)
                .font(.headline)
                .foregroundColor(.secondary)

            Text("Position: \(player.position)")
                .font(.subheadline)

            Text("Overall: \(player.overallRating)")
                .font(.title3)
                .foregroundColor(.blue)



                .font(.title3)
                .foregroundColor(.blue)
        }
        .padding()
    }

    private var backCardView: some View {
        VStack(spacing: 8) {
            Text("Best Skill")
                .font(.headline)
                .padding(.bottom, 8)

            Text(player.bestSkill.replacingOccurrences(of: "_", with: " ").capitalized)
                .font(.subheadline)



            Spacer().frame(height: 10)

            VStack(alignment: .leading, spacing: 5) {
                Text("Experience: \(player.experienceYears) years")
                Text("Nationality: \(player.nationality)")
                Text("Age: \(player.age)")
                Text("Height: \(player.height)")
                Text("Weight: \(player.weight)")
            }
            .font(.footnote)
            .padding(.top, 10)
        }
        .padding()
    }

    func backgroundGradient(for rarity: Rarity) -> LinearGradient {
        switch rarity {
        case .DarkBlueDiamond:
            return LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.9), Color.black]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .pinkDiamond:
            return LinearGradient(
                gradient: Gradient(colors: [Color.pink, Color.purple]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .diamond:
            return LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.7), Color.cyan]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .amethyst:
            return LinearGradient(
                gradient: Gradient(colors: [Color.purple, Color.blue]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .ruby:
            return LinearGradient(
                gradient: Gradient(colors: [Color.red.opacity(0.9), Color.black]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .gold:
            return LinearGradient(
                gradient: Gradient(colors: [Color.yellow, Color.orange]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    private var shineOverlay: some View {
        LinearGradient(
            gradient: Gradient(colors: [Color.yellow.opacity(0.3), Color.clear, Color.yellow.opacity(0.3)]),
            startPoint: animateShine ? .topLeading : .bottomTrailing,
            endPoint: animateShine ? .bottomTrailing : .topLeading
        )
        .blendMode(.screen)
        .animation(Animation.linear(duration: 7).repeatForever(autoreverses: true), value: animateShine)
        .onAppear {
            animateShine.toggle()
        }
    }
}

struct PlayerDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let examplePlayer = Player(
            id: 1,
            name: "Stephen Curry",
            team: 1,
            teamName: "Golden State Warriors",
            position: "Guard",
            age: 36,
            height: 188,
            weight: 84,
            profilePicture: "https://cdn.nba.com/headshots/nba/latest/1040x760/201939.png",
            bio: "Chef Curry",
            experienceYears: 14,
            nationality: "USA",
            overallRating: 97,
            bestSkill: "three_point_shooting",
            rarity: "DarkBlueDiamond"

        )
        PlayerDetailView(player: examplePlayer)
    }
}
