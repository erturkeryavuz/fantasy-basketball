import SwiftUI

struct HomeView: View {
    @State private var startPoint = UnitPoint(x: 0, y: 0)
    @State private var endPoint = UnitPoint(x: 1, y: 1)
    @State private var isTeamsPressed: Bool = false
    @State private var isPlayersPressed: Bool = false
    @State private var isLogoutPressed: Bool = false // Logout butonu animasyonu
    @State private var navigateToLogin: Bool = false // Logout sonrası yönlendirme
 
    @AppStorage("loggedInUsername") private var username: String = ""

    @State private var isMarketplacePressed: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Animasyonlu Gradyan Arka Plan
                LinearGradient(
                    gradient: Gradient(colors: [Color.orange, Color.black, Color.yellow]),
                    startPoint: startPoint,
                    endPoint: endPoint
                )
                .ignoresSafeArea()
                .onAppear {
                    if let token = UserDefaults.standard.string(forKey: "userToken") {
                        print("🔑 Aktif Token:", token)
                    } else {
                        print("❌ Token Yok")
                    }

                    print("📧 User logged in as: \(username)")

                    withAnimation(
                        Animation.easeInOut(duration: 6).repeatForever(autoreverses: true)
                    ) {
                        startPoint = UnitPoint(x: 1, y: 0)
                        endPoint = UnitPoint(x: 0, y: 1)
                    }
                }


                

                VStack(spacing: 20) {
                    // Kullanıcı Bilgisi
                    HStack {
                        Text("Welcome, \(username.isEmpty ? "Guest" : username)")

                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(10)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.black.opacity(0.5))
                            )
                            .padding(.leading)
                            .offset(y: 35)
                        Spacer()
                    }

                    Spacer()

                    Image("homelogo1.2")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 190, height: 190)
                        .padding(.top, 30)

                    Text("Fantasy Basketball")
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
                            Text("Fantasy Basketball")
                                .font(.system(size: 41, weight: .bold, design: .rounded))
                                .foregroundColor(.black.opacity(0.2))
                                .blur(radius: 4)
                        )

                    Spacer()

                    // Üst Butonlar: View Teams & View Players
                    VStack(spacing: 20) {
                        // View Teams Button
                        NavigationLink(destination: TeamsView()) {
                            HStack {
                                Image(systemName: "sportscourt")
                                    .font(.system(size: 18))
                                    .foregroundColor(.white)
                                Text("View Teams")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.white)
                            }
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
                                    .shadow(color: Color.orange.opacity(0.6), radius: 8, x: 0, y: 3)
                            )
                            .scaleEffect(isTeamsPressed ? 0.95 : 1.0) // Tıklama efekti
                            .animation(.easeInOut(duration: 0.2), value: isTeamsPressed)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .onLongPressGesture(minimumDuration: 0.1, pressing: { pressing in
                            isTeamsPressed = pressing
                        }, perform: {})

                        // View Players Button
                        NavigationLink(destination: PlayersView()) {
                            HStack {
                                Image(systemName: "person.3.fill")
                                    .font(.system(size: 18))
                                    .foregroundColor(.white)
                                Text("View Players")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.white)
                            }
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
                                    .shadow(color: Color.orange.opacity(0.6), radius: 8, x: 0, y: 3)
                            )
                            .scaleEffect(isPlayersPressed ? 0.95 : 1.0) // Tıklama efekti
                            .animation(.easeInOut(duration: 0.2), value: isPlayersPressed)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .onLongPressGesture(minimumDuration: 0.1, pressing: { pressing in
                            isPlayersPressed = pressing
                        }, perform: {})
                    }
                    // Marketplace Button
                    NavigationLink(destination: MarketplaceView()) {
                        HStack {
                            Image(systemName: "cart.fill")
                                .font(.system(size: 18))
                                .foregroundColor(.white)
                            Text("Marketplace")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        .padding()
                        .frame(width: 230, height: 50)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.pink, Color.orange]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .shadow(color: Color.pink.opacity(0.6), radius: 8, x: 0, y: 3)
                        )
                        .scaleEffect(isMarketplacePressed ? 0.95 : 1.0)
                        .animation(.easeInOut(duration: 0.2), value: isMarketplacePressed)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .onLongPressGesture(minimumDuration: 0.1, pressing: { pressing in
                        isMarketplacePressed = pressing
                    }, perform: {})

                    // Cards Button
                    NavigationLink(destination: MyCardsView()) {
                        HStack {
                            Image(systemName: "rectangle.stack.fill")
                                .font(.system(size: 18))
                                .foregroundColor(.white)
                            Text("My Cards")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        .padding()
                        .frame(width: 230, height: 50)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.purple, Color.indigo]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .shadow(color: Color.purple.opacity(0.5), radius: 8, x: 0, y: 3)
                        )
                        .scaleEffect(1.0)
                    }
                    .buttonStyle(PlainButtonStyle())
                    Spacer()

                    // Logout Button (Animasyonlu)
                    Button(action: {
                        isLogoutPressed = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            isLogoutPressed = false
                            AuthService.shared.logout()
                            navigateToLogin = true
                        }
                    }) {
                        HStack {
                            Image(systemName: "arrow.backward.circle.fill")
                                .font(.system(size: 18))
                                .foregroundColor(.white)
                            Text("Logout")
                                .font(.headline)
                                .foregroundColor(.white) // Yazı rengi beyaz olarak bırakıldı
                        }
                        .padding()
                        .frame(width: 230, height: 50)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.red, Color.black]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .shadow(color: Color.orange.opacity(0.6), radius: 5, x: 0, y: 3)
                        )
                        .scaleEffect(isLogoutPressed ? 0.95 : 1.0) // Logout butonu için tıklama efekti
                        .animation(.easeInOut(duration: 0.2), value: isLogoutPressed)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .onLongPressGesture(minimumDuration: 0.1, pressing: { pressing in
                        isLogoutPressed = pressing
                    }, perform: {})
                    .padding(.bottom, 50)
                }
                .padding(.horizontal, 20)
                .navigationDestination(isPresented: $navigateToLogin) {
                    ContentView()
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
