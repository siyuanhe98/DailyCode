import SwiftUI
import FirebaseAuth

struct RegisterView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @Binding var isRegistering: Bool
    @EnvironmentObject var userManager: UserManager
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    var body: some View {
        VStack {
            Image("logo")
                .resizable()
                .scaledToFit()
                .frame(height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white, lineWidth: 5)
                
                )
            VStack{
                TextField("Email", text: $email)
                    .padding()
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                    .disableAutocorrection(true)
                Divider().padding(.top, -5)
                
                SecureField("Password", text: $password)
                    .padding()
                    .textContentType(.oneTimeCode)
                Divider().padding(.top, -5)
                SecureField("Confirm Password", text: $confirmPassword)
                    .padding()
                    .textContentType(.oneTimeCode)
                Divider().padding(.top, -5)
                Button(action: {
                    if password != confirmPassword{
                        alertMessage = "Two password not match, please input again!"
                        showAlert = true
                    } else {
                        userManager.register(email: email, password: password) { errorMsg in
                            if errorMsg != "" {
                                alertMessage = errorMsg
                                showAlert = true
                                print("test \(errorMsg)")
                            } else{
                                isRegistering = false
                            }
                        }
                    }
                }) {
                    Text("Create Account")
                        .frame(maxWidth: 200)
                        .font(Font.custom("BrunoAceSC-Regular", size: 20))
                }
                .tint(Color(hex: "#16a085"))
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .padding(.top, 10)
            }
            Spacer()
        }
        .padding()
        .navigationBarTitle("Register", displayMode: .inline)
        .alert(isPresented: $showAlert) {
                    Alert(title: Text("Error"),
                          message: Text(alertMessage),
                          dismissButton: .default(Text("OK")))
        }
    }
}



struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            RegisterView(isRegistering: .constant(true))
                .environmentObject(UserManager())
        }
    }
}
