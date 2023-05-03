import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import UserNotifications

struct ToDoView: View {
    @State private var favoriteProblems: [Problem] = []
    @State private var allProblems: [Problem] = []

    var body: some View {
        NavigationView {
            List {
                ForEach(favoriteProblems) { problem in
                    NavigationLink(destination: DetailView(url: problem.urlInfo)) {
                        VStack(alignment: .leading) {
                            Text(problem.id + " " + problem.name)
                                .foregroundColor(getColorForDifficulty(problem.difficulty ?? 0))
                                .bold()
                                .padding(.bottom, 0.7)
                            HStack(spacing: 2){
                                Text("Difficulty:")
                                    .foregroundColor(.black)
                                    .font(.system(size: 12))
                                    .bold()
                                Text("\(problem.difficulty ?? 0)")
                                    .font(.system(size: 12))
                                    .foregroundColor(.black.opacity(0.8))
                            }
                            .padding(.bottom, -1.5)
                            HStack(spacing: 2) {
                                ForEach(problem.tags, id: \.self) { tag in
                                    Text(tag)
                                        .minimumScaleFactor(0.3)
                                        .lineLimit(1)
                                        .padding(.horizontal, 4)
                                        .padding(.vertical, 4)
                                        .frame(height: 18)
                                        .background(RoundedRectangle(cornerRadius: 4).fill(Color(hex: "#ecf0f1")))
                                        .foregroundColor(Color(hex: "#2c3e50"))
                                        .bold()
                                }
                            }
                            //                        Text("Tags: \(problem.tags.joined(separator: ", "))")
                            /* Button(action: {
                             scheduleNotification(for: problem)
                             }) {
                             Text("Schedule Notification")
                             .foregroundColor(.white)
                             .padding(.horizontal, 10)
                             .padding(.vertical, 5)
                             .background(Color.blue)
                             .cornerRadius(5)
                             }
                             .padding(.top, 5)*/
                        }
                    }
                }
                .onDelete(perform: deleteFavoriteProblem)
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("To-Do List")
                        .font(Font.custom("BrunoAceSC-Regular", size: 35))
                        .foregroundColor(Color(hex: "#16a085"))
                }
            }
            .onAppear {
                
                fetchFavoriteProblems()
                //requestNotificationPermission()
            }
            
        }
    }
    
    func loadProblems() {
        let urlString = "https://codeforces.com/api/problemset.problems"
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    let decodedResponse = try JSONDecoder().decode(ProblemSetProblemsResponse.self, from: data)
                    DispatchQueue.main.async {
                        allProblems = decodedResponse.result.problems
                        fetchFavoriteProblems()
                    }
                } catch {
                    print("Error decoding JSON: \(error)")
                }
            }
        }
        
        task.resume()
    }
    
    func fetchFavoriteProblems() {
        guard let uid = fetchCurrentUserUID() else {
            print("Error: User not signed in.")
            return
        }
        
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(uid)
        
        userRef.getDocument { document, error in
            if let error = error {
                print("Error fetching favorite problems: \(error)")
            } else {
                if let document = document, document.exists {
                    if let favoriteProblemIds = document.get("favoriteProblems") as? [String] {
                        loadFavoriteProblems(favoriteProblemIds: favoriteProblemIds)
                    } else {
                        print("Error: Favorite problems not found.")
                    }
                } else {
                    print("Error: Document does not exist.")
                }
            }
        }
    }
    func loadFavoriteProblems(favoriteProblemIds: [String]) {
        let urlString = "https://codeforces.com/api/problemset.problems"
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    let decodedResponse = try JSONDecoder().decode(ProblemSetProblemsResponse.self, from: data)
                    DispatchQueue.main.async {
                        allProblems = decodedResponse.result.problems
                        favoriteProblems = allProblems.filter { favoriteProblemIds.contains($0.id) }
                    }
                } catch {
                    print("Error decoding JSON: \(error)")
                }
            }
        }
        
        task.resume()
    }
    
    func deleteFavoriteProblem(at offsets: IndexSet) {
        guard let uid = fetchCurrentUserUID() else {
            print("Error: User not signed in.")
            return
        }
        
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(uid)
        
        for index in offsets {
            let problemId = favoriteProblems[index].id
            userRef.updateData([
                "favoriteProblems": FieldValue.arrayRemove([problemId])
            ]) { error in
                if let error = error {
                    print("Error removing problem from favorites: \(error)")
                } else {
                    favoriteProblems.remove(at: index)
                }
            }
        }
    }
    
    
    func fetchCurrentUserUID() -> String? {
        if let user = Auth.auth().currentUser {
            return user.uid
        }
        return nil
    }
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else if let error = error {
                print("Error requesting notification permission: \(error.localizedDescription)")
            }
        }
    }
    
    func scheduleNotification(for problem: Problem) {
        let content = UNMutableNotificationContent()
        content.title = "Time to solve a problem!"
        content.body = "Try solving problem \(problem.id) - \(problem.name)"
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60, repeats: false)
        
        let request = UNNotificationRequest(identifier: problem.id, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            } else {
                print("Notification scheduled for problem \(problem.id)")
            }
        }
    }
}
