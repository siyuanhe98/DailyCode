import SwiftUI
import FirebaseFirestore

struct CodeforcesProfileView: View {
    @State private var handle = ""
    @State private var profileData: [String: Any]?
    @State private var errorMessage = ""
    @EnvironmentObject var userManager: UserManager
    
    var body: some View {
        ZStack {
            Color(hex: "#1abc9c")
                .edgesIgnoringSafeArea(.all)
            VStack {
                if let profileData = profileData {
                    Text("\(profileData["handle"] as? String ?? "")")
                        .font(Font.custom("Pacifico-Regular", size: 30))
                        .bold()
                        .foregroundColor(.white)
                    AsyncImage(url: URL(string: profileData["avatar"] as! String)) { phase in
                        switch phase {
                        case .empty:
                            // Placeholder while the image is being downloaded
                            ProgressView()
                        case .success(let image):
                            // The loaded image
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 120.0, height: 120.0)
                                .clipShape(Circle())
                                .overlay(
                                    Circle().stroke(Color(.systemGray6), lineWidth: 0.5)
                                )
                                .padding(.bottom, 10)
                        case .failure:
                            // Display an error message or a placeholder image in case of failure
                            Text("Failed to load logo image")
                        @unknown default:
                            fatalError()
                        }
                    }
                }
                HStack{
                    TextField("Codeforces Handle", text: $handle)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                        .disableAutocorrection(true)
                        .foregroundColor(Color(.systemGray6))
                    Button(action: {
                        updateUserHandle()
                    }) {
                        Text("Update Handle")
                            .font(Font.custom("BrunoAceSC-Regular", size: 12))
                        
                    }.tint(Color(hex: "#2c3e50"))
                }
                .padding(.horizontal, 5)
                Divider()
                    .padding(.top, -5)
                if let profileData = profileData {
                    VStack{
                        HStack{
                            Image(systemName: "number.circle.fill")
                                .foregroundColor(Color(hex: "#2c3e50"))
                            Text("Contribution: ")
                                .foregroundColor(Color(hex: "#7f8c8d"))
                                .bold()
                            Text("\(profileData["problemSolved"] as? Int ?? 0)")
                                .foregroundColor(Color(hex: "#bdc3c7"))
                        }
                        .frame(height: 35)
                        .padding(.top, 10)
                        Divider()
                        HStack{
                            Image(systemName: "star.leadinghalf.filled")
                                .foregroundColor(Color(hex: "#2c3e50"))
                            Text("Current Rating: ")
                                .foregroundColor(Color(hex: "#7f8c8d"))
                                .bold()
                            Text("\(profileData["currentRating"] as? Int ?? 0)")
                                .foregroundColor(Color(hex: "#bdc3c7"))
                        }
                        .frame(height: 35)
                        Divider()
                        HStack{
                            Image(systemName: "star.circle.fill")
                                .foregroundColor(Color(hex: "#2c3e50"))
                            Text("Max Rating: ")
                                .foregroundColor(Color(hex: "#7f8c8d"))
                                .bold()
                            Text("\(profileData["maxRating"] as? Int ?? 0)")
                                .foregroundColor(Color(hex: "#bdc3c7"))
                        }
                        .frame(height: 35)
                        .padding(.bottom, 10)
                    }
                    .frame(width: 320)
                    .background(Color(.white))
                    .cornerRadius(15)
                    .padding(.top, 10)
                }
                //                if !errorMessage.isEmpty {
                //                    Text(errorMessage)
                //                        .foregroundColor(.red)
                //                        .padding(.top, 20)
                //                }
            }
            .padding()
            .onAppear {
                fetchUserHandle()
            }
        }
    }
    private func fetchUserHandle() {
        userManager.fetchCodeforcesHandle { fetchedHandle in
            if let fetchedHandle = fetchedHandle {
                handle = fetchedHandle
                fetchProfileData(for: fetchedHandle)
            }
        }
    }
    
    private func updateUserHandle() {
        print("Updating handle to: \(handle)")
        userManager.updateCodeforcesHandle(handle: handle) { success in
            if success {
                fetchProfileData(for: handle)
            } else {
                errorMessage = "Failed to update Codeforces handle"
            }
        }
    }
    
    private func fetchProfileData(for handle: String) {
        print("Fetching profile data for handle: \(handle)")
        userManager.fetchCodeforcesProfile(handle: handle) { result in
            switch result {
            case .success(let data):
                if let resultArray = data["result"] as? [[String: Any]], let userProfile = resultArray.first {
                    let currentRating = userProfile["rating"] as? Int ?? 0
                    let maxRating = userProfile["maxRating"] as? Int ?? 0
                    let problemSolved = userProfile["contribution"] as? Int ?? 0
                    let avatar = userProfile["avatar"] as? String ?? "https://msrealtors.org/wp-content/uploads/2018/11/no-user-image.gif"
                    let handle = userProfile["handle"] as? String ?? ""
                    profileData = [
                        "currentRating": currentRating,
                        "maxRating": maxRating,
                        "problemSolved": problemSolved,
                        "avatar": avatar,
                        "handle": handle
                    ]
                    errorMessage = ""
                } else {
                    errorMessage = "Failed to fetch Codeforces profile data"
                }
            case .failure(let error):
                errorMessage = error.localizedDescription
            }
        }
    }
}

struct CodeforcesProfileView_Previews: PreviewProvider {
    static var previews: some View {
        CodeforcesProfileView().environmentObject(UserManager())
    }
}
