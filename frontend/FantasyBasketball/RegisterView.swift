import SwiftUI

struct RegisterView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isRegisterPressed: Bool = false // Register butonu için
    @State private var isLoginPressed: Bool = false // Login butonu için
    @State private var isHomePressed: Bool = false // Return to Home butonu için
    @FocusState private var isEmailFocused: Bool // Email alanı için FocusState
    @FocusState private var isPasswordFocused: Bool // Password alanı için FocusState
    @State private var isRegistered: Bool = false // Kayıt sonrası yönlendirme için
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Arka Plan Görseli
                Image("registerbg1")
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)

                VStack(spacing: 20) {
                    // Başlık
                    Text("Registration")
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
                            Text("Registration")
                                .font(.system(size: 45, weight: .bold, design: .rounded))
                                .foregroundColor(.black.opacity(0.2))
                                .blur(radius: 4)
                        )

                    Spacer()
                    
                    // Login yönlendirme için NavigationDestination
                    .navigationDestination(isPresented: $isRegistered) {
                        LoginView()
                    }



                    // Email TextField
                    CustomTextField(
                        text: $email,
                        placeholder: "Email",
                        isSecure: false
                    )
                    .focused($isEmailFocused)

                    // Password TextField
                    CustomTextField(
                        text: $password,
                        placeholder: "Password",
                        isSecure: true
                    )
                    .focused($isPasswordFocused)

                    // Register Button
                    Button(action: {
                        isRegisterPressed = true
                        AuthService.shared.registerUser(email: email, password: password) { result in
                            DispatchQueue.main.async {
                                isRegisterPressed = false
                                switch result {
                                case .success(let message):
                                    print(message) // Başarı mesajı
                                    isRegistered = true // Login ekranına yönlendirme
                                case .failure(let error):
                                    print(error.localizedDescription) // Hata mesajını kullanıcıya gösterebilirsiniz.
                                }
                            }
                        }
                    }){
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
                                        gradient: Gradient(colors: [Color.orange, Color.yellow]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .shadow(color: Color.orange.opacity(0.6), radius: 10, x: 0, y: 4)
                        )
                        .foregroundColor(.white)
                        .scaleEffect(isRegisterPressed ? 0.95 : 1.0) // Tıklama efekti
                        .animation(.easeInOut(duration: 0.2), value: isRegisterPressed)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .onLongPressGesture(minimumDuration: 0.1, pressing: { pressing in
                        isRegisterPressed = pressing
                    }, perform: {})

                    Spacer()

                    // Login Link
                    NavigationLink(destination: LoginView()) {
                        HStack {
                            Image(systemName: "key.fill")
                                .font(.system(size: 18))
                                .foregroundColor(.white)
                            Text("Have an account?")
                                .font(.system(size: 20))
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
                        .scaleEffect(isLoginPressed ? 0.95 : 1.0) // Tıklama efekti
                        .animation(.easeInOut(duration: 0.2), value: isLoginPressed)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .onLongPressGesture(minimumDuration: 0.1, pressing: { pressing in
                        isLoginPressed = pressing
                    }, perform: {})

                    // Return to Home Button
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
                                .shadow(color: Color.black.opacity(0.4), radius: 10, x: 0, y: 5)
                        )
                        .foregroundColor(.white)
                        .scaleEffect(isHomePressed ? 0.95 : 1.0) // Tıklama efekti
                        .animation(.easeInOut(duration: 0.2), value: isHomePressed)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .onLongPressGesture(minimumDuration: 0.1, pressing: { pressing in
                        isHomePressed = pressing
                    }, perform: {})
                    .padding(.bottom, 30) // Sayfanın altına yerleşim
                }
                .padding(.horizontal)
            }
            .navigationBarBackButtonHidden(true)
        }
    }
}

struct CustomTextField: View {
    @Binding var text: String
    var placeholder: String
    var isSecure: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            // Placeholder
            Text(placeholder)
                .font(.headline)
                .foregroundColor(.white.opacity(0.8))
                .padding(.leading, 5)

            if isSecure {
                SecureField("", text: $text)
                    .keyboardType(.default) // Şifre için standart klavye düzeni
                    .textInputAutocapitalization(.never) // Büyük harf kullanımını devre dışı bırakır
                    .autocorrectionDisabled() // Otomatik düzeltmeyi kapatır
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.black.opacity(0.6)) // Arka plan rengi
                            .shadow(color: Color.black.opacity(0.2), radius: 6, x: 0, y: 4)
                    )
                    .foregroundColor(.white)
            } else {
                TextField("", text: $text)
                    .keyboardType(.emailAddress) // Email için optimize edilmiş klavye
                    .disableAutocorrection(true) // Otomatik düzeltmeyi kapatır
                    .textInputAutocapitalization(.never) // Büyük harf kullanımını devre dışı bırakır
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.black.opacity(0.6)) // Arka plan rengi
                            .shadow(color: Color.black.opacity(0.2), radius: 6, x: 0, y: 4)
                    )
                    .foregroundColor(.white)
            }
        }
        .padding(.horizontal)
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
    }
}
