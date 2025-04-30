import SwiftUI

struct CustomAnimatedTextField: View {
    @Binding var text: String
    var placeholder: String
    var systemImageName: String
    var isSecure: Bool = false
    
    var body: some View {
        HStack {
            Image(systemName: systemImageName)
                .foregroundColor(text.isEmpty ? .white : .blue)
                .scaleEffect(text.isEmpty ? 1.0 : 1.2)
                .animation(.easeInOut(duration: 0.3), value: text)
            
            if isSecure {
                SecureField(placeholder, text: $text)
                    .foregroundColor(.white)
            } else {
                TextField(placeholder, text: $text)
                    .foregroundColor(.white)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.black.opacity(text.isEmpty ? 0.5 : 0.7))
                .shadow(color: text.isEmpty ? .clear : .blue.opacity(0.5), radius: 10, x: 0, y: 5)
        )
        .animation(.easeInOut(duration: 0.3), value: text)
        .padding(.horizontal)
    }
}
