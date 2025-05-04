import SwiftUI

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isPressed: Bool = false
    
    @State private var isSignUpPressed: Bool = false

    @State private var isReturnToHomePressed: Bool = false
    
    @FocusState private var isEmailFocused: Bool
    
    @FocusState private var isPasswordFocused: Bool

    @State private var navigateToHome: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Image("registerbg1")
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)

                VStack(spacing: 20) {
                    Text("Login")
                        .font(.system(size: 45, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.white, Color.gray]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(color: .black.opacity(0.7), radius: 12, x: 0, y: 6)
                        .padding(.top, 50)
                        .overlay(
                            Text("Login")
                                .font(.system(size: 45, weight: .bold, design: .rounded))
                                .foregroundColor(.black.opacity(0.2))
                                .blur(radius: 4)
                        )

                    Spacer()

                    CustomTextField(
                        text: $email,
                        placeholder: "Email",
                        isSecure: false
                    )
                    .focused($isEmailFocused)

                    CustomTextField(
                        text: $password,
                        placeholder: "Password",
                        isSecure: true
                    )
                    .focused($isPasswordFocused)

                    Button(action: {
                        isPressed = true
                        AuthService.shared.loginUser(email: email, password: password) { result in
                            DispatchQueue.main.async {
                                isPressed = false
                                switch result {
                                case .success(let message):
                                    print(message)
                                    navigateToHome = true
                                case .failure(let error):
                                    print(error.localizedDescription)                                }
                            }
                        }
                    }) {
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
                                        gradient: Gradient(colors: [Color.purple, Color.blue]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .shadow(color: Color.purple.opacity(0.6), radius: 10, x: 0, y: 4)
                        )
                        .foregroundColor(.white)
                        .scaleEffect(isPressed ? 0.95 : 1.0)                        .animation(.easeInOut(duration: 0.2), value: isPressed)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .onLongPressGesture(minimumDuration: 0.1, pressing: { pressing in
                        isPressed = pressing
                    }, perform: {})

                    Spacer()

                    NavigationLink(destination: RegisterView()) {
                        HStack {
                            Image(systemName: "person.badge.plus")
                                .font(.system(size: 18))
                                .foregroundColor(.white)
                            Text("Sign Up")
                                .font(.system(size: 20, weight: .semibold))
                        }
                        .padding()
                        .frame(width: 230, height: 50)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.orange, Color.yellow]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .shadow(color: Color.orange.opacity(0.6), radius: 10, x: 0, y: 4)
                        )
                        .foregroundColor(.white)
                        .scaleEffect(isSignUpPressed ? 0.95 : 1.0)                         .animation(.easeInOut(duration: 0.2), value: isSignUpPressed)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .onLongPressGesture(minimumDuration: 0.1, pressing: { pressing in
                        isSignUpPressed = pressing
                    }, perform: {})

                    NavigationLink(destination: ContentView()) {
                        HStack {
                            Image(systemName: "house.fill")
                                .font(.system(size: 18))
                                .foregroundColor(.white)
                            Text("Return to Home")
                                .font(.system(size: 20, weight: .semibold))
                        }
                        .padding()
                        .frame(width: 230, height: 50)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.black, Color.gray]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .shadow(color: Color.black.opacity(0.6), radius: 10, x: 0, y: 4)
                        )
                        .foregroundColor(.white)
                        .scaleEffect(isReturnToHomePressed ? 0.95 : 1.0)
                        .animation(.easeInOut(duration: 0.2), value: isReturnToHomePressed)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .onLongPressGesture(minimumDuration: 0.1, pressing: { pressing in
                        isReturnToHomePressed = pressing
                    }, perform: {})
                    .padding(.bottom, 30)
                }
                .padding(.horizontal)
            }
            .navigationBarBackButtonHidden(true)
            .navigationDestination(isPresented: $navigateToHome) {
                HomeView()
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
