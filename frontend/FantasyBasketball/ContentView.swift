import SwiftUI

struct ContentView: View {
    @State private var startPoint = UnitPoint(x: 0, y: 0)
    @State private var endPoint = UnitPoint(x: 1, y: 1)

    @State private var isTeamsPressed: Bool = false
    @State private var isPlayersPressed: Bool = false
    @State private var isLoginPressed: Bool = false
    @State private var isRegisterPressed: Bool = false


    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color.orange, Color.black, Color.yellow]),
                    startPoint: startPoint,
                    endPoint: endPoint
                )
                .ignoresSafeArea()
                .onAppear {
                    withAnimation(
                        Animation.easeInOut(duration: 6).repeatForever(autoreverses: true)
                    ) {
                        startPoint = UnitPoint(x: 1, y: 0)
                        endPoint = UnitPoint(x: 0, y: 1)
                    }
                }

                VStack(spacing: 60) { // Logo ve Başlık
                    Spacer(minLength: 10) // 🔥 Üst boşluk verdik ki top aşağı insin

                    Image("homelogo1.2")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 190, height: 190)
                    
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

                    VStack(spacing: 20) {
                        NavigationLink(destination: LoginView()) {
                            HStack {
                                Image(systemName: "key.fill")
                                    .font(.system(size: 18))
                                    .foregroundColor(.white)
                                Text("Login")
                                    .font(.system(size: 20, weight: .semibold))
                            }
                            .padding()
                            .frame(width: 230, height: 50)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color.yellow, Color.orange]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .shadow(color: Color.orange.opacity(0.5), radius: 8, x: 0, y: 3)
                            )
                            .foregroundColor(.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1.5)
                                    .blur(radius: 2)
                            )
                            .scaleEffect(isLoginPressed ? 0.95 : 1.0)
                            .animation(.easeInOut(duration: 0.2), value: isLoginPressed)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .onLongPressGesture(minimumDuration: 0.1, pressing: { pressing in
                            isLoginPressed = pressing
                        }, perform: {})

                
                        NavigationLink(destination: RegisterView()) {
                            HStack {
                                Image(systemName: "person.badge.plus")
                                    .font(.system(size: 18))
                                    .foregroundColor(.white)
                                Text("Register")
                                    .font(.system(size: 20, weight: .semibold))
                            }
                            .padding()
                            .frame(width: 230, height: 50)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color.yellow, Color.orange]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .shadow(color: Color.orange.opacity(0.5), radius: 8, x: 0, y: 3)
                            )
                            .foregroundColor(.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1.5)
                                    .blur(radius: 2)
                            )
                            .scaleEffect(isRegisterPressed ? 0.95 : 1.0)
                            .animation(.easeInOut(duration: 0.2), value: isRegisterPressed)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .onLongPressGesture(minimumDuration: 0.1, pressing: { pressing in
                            isRegisterPressed = pressing
                        }, perform: {})
                    }

                    .padding(.bottom, 60) // 🔥 Butonları iyice aşağıda ve havalı gösterir.
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 50)
            }
            .navigationBarHidden(true)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
