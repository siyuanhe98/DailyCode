import SwiftUI
import FirebaseAuth


struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isRegistering = false
    @EnvironmentObject var userManager: UserManager
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @FocusState private var isEmailFieldFocused: Bool
    @FocusState private var isPasswordFieldFocused: Bool
    @ObservedObject private var keyboardResponder = KeyboardResponder()
    
    init() {
            _email = State(initialValue: "")
            _password = State(initialValue: "")
    }
    
    var body: some View {
        if userManager.isLoggedIn {
           
            VStack {
                Text("Welcome!")
                    .font(.largeTitle)
                
                NavigationLink(destination: CodeforcesProfileView()) {
                    Text("Go to Codeforces Profile")
                        .foregroundColor(.white)
                        .padding(.horizontal, 30)
                        .padding(.vertical, 12)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                
                Button(action: {
                    userManager.logout()
                }) {
                    Text("Logout")
                        .foregroundColor(.white)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 12)
                        .background(Color.red)
                        .cornerRadius(8)
                }
                .padding()
            }
        } else {
            VStack{
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white, lineWidth: 5)
                        
                    )
                TextField("Email", text: $email)
                    .padding()
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                    .disableAutocorrection(true)
                Divider().padding(.top, -5)
                SecureField("Password", text: $password)
                    .padding()
                    .textContentType(.oneTimeCode)
                Divider().padding(.top, -5).padding(.bottom, 30)
                VStack {
                    Button(action: {
                        if email.isEmpty || password.isEmpty {
                            alertMessage = "Please enter your email and password!"
                            showAlert = true
                        } else {
                            userManager.login(email: email, password: password) { errorMsg in
                                if errorMsg != "" {
                                    alertMessage = errorMsg
                                    showAlert = true
                                }
                            }
                        }
                    }) {
                        Text("Login")
                            .frame(maxWidth: 150)
                            .font(Font.custom("BrunoAceSC-Regular", size: 20))
                    }
                    .tint(Color(hex: "#1abc9c"))
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    
                    Button(action: {
                        isRegistering.toggle()
                    }) {
                        Text("Register")
                            .frame(maxWidth: 150)
                            .font(Font.custom("BrunoAceSC-Regular", size: 20))
                    }
                    .sheet(isPresented: $isRegistering) {
                        RegisterView(isRegistering: $isRegistering)
                            .environmentObject(userManager)
                    }
                    .tint(Color(hex: "#16a085"))
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .padding(.top, 8)
                }.padding(.bottom, keyboardResponder.currentHeight)
                    .animation(.easeOut(duration: 0.25), value: keyboardResponder.currentHeight)
                    .alert(isPresented: $showAlert) {
                        Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("Try it again")))
                    }
                Spacer()
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView().environmentObject(UserManager())
    }
}
