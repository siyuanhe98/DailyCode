import SwiftUI
import FirebaseFirestore
import FirebaseAuth


struct Problem: Identifiable, Codable {
    let contestId: Int
    let index: String
    let name: String
    let difficulty: Int?
    let tags: [String]
    
    var id: String {
        return "\(contestId)\(index)"
    }

    var urlInfo: String{
        return "https://codeforces.com/problemset/problem/\(contestId)/\(index)"
    }
    
    enum CodingKeys: String, CodingKey {
        case contestId = "contestId"
        case index = "index"
        case name = "name"
        case difficulty = "rating"
        case tags = "tags"
    }
}



struct ProblemListView: View {
    @State private var allProblems: [Problem] = []
    @State private var displayedProblems: [Problem] = []
    @State private var solvedProblemIds: Set<String> = []
    @State private var favoriteProblemIds: Set<String> = []
    @State private var problems: [Problem] = []
    @State private var showingSearchSheet = false
    @State private var searchTags: Set<String> = Set<String>(["dp"])
    @State private var minDifficulty = 1500
    @State private var maxDifficulty = 2000

    var body: some View {
        NavigationView {
            List {
                ForEach(displayedProblems) { problem in
                    
                    NavigationLink(destination: DetailView(url: problem.urlInfo)) {
                        HStack {
                            Button(action: { toggleFavoriteProblem(problemId: problem.id) }) {
                                Image(systemName: favoriteProblemIds.contains(problem.id) ? "star.fill" : "star")
                                    .foregroundColor(favoriteProblemIds.contains(problem.id) ? .yellow : .gray)
                            }
                            .buttonStyle(PlainButtonStyle())
                            
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
                            }
                        }
                    }
                }
                
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Problems")
                        .font(Font.custom("BrunoAceSC-Regular", size: 35))
                        .foregroundColor(Color(hex: "#16a085"))
                }
            }
            .navigationBarItems(trailing: Button(action: { showingSearchSheet.toggle() }) {
                Image(systemName: "magnifyingglass.circle.fill")
                    .resizable()
                    .frame(width: 35, height: 35)
                    .foregroundColor(Color(hex: "#7f8c8d"))
                
            })
            .sheet(isPresented: $showingSearchSheet) {
                SearchSheet(minDifficulty: $minDifficulty, maxDifficulty: $maxDifficulty, searchTags: $searchTags, onSearch: updateDisplayedProblems)
            }
            
            .onAppear {
                loadProblems()
                if let uid = fetchCurrentUserUID() {
                    fetchUserHandle(uid: uid)
                    fetchFavoriteProblems(uid: uid)
                } else {
                    print("Error: User not signed in.")
                }
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
                        updateDisplayedProblems()
                    }
                } catch {
                    print("Error decoding JSON: \(error)")
                }
            }
        }
        
        task.resume()
    }
    func toggleFavoriteProblem(problemId: String) {
        guard let uid = fetchCurrentUserUID() else {
            print("Error: User not signed in.")
            return
        }
        
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(uid)
        
        if favoriteProblemIds.contains(problemId) {
            userRef.updateData([
                "favoriteProblems": FieldValue.arrayRemove([problemId])
            ]) { error in
                if let error = error {
                    print("Error removing problem from favorites: \(error)")
                } else {
                    favoriteProblemIds.remove(problemId)
                }
            }
        } else {
            userRef.updateData([
                "favoriteProblems": FieldValue.arrayUnion([problemId])
            ]) { error in
                if let error = error {
                    print("Error adding problem to favorites: \(error)")
                } else {
                    favoriteProblemIds.insert(problemId)
                }
            }
        }
    }

    func loadSolvedProblems(userHandle: String) {
        let urlString = "https://codeforces.com/api/user.status?handle=\(userHandle)"

        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    let decodedResponse = try JSONDecoder().decode(UserStatusResponse.self, from: data)
                    DispatchQueue.main.async {
                        solvedProblemIds = Set(decodedResponse.result.filter { $0.verdict == "OK" && $0.problem.contestId != nil }.map { "\($0.problem.contestId!)\($0.problem.index)" })
                        updateDisplayedProblems()
                    }
                } catch {
                    print("Error decoding JSON: \(error)")
                }
            }
        }

        task.resume()
    }


    func updateDisplayedProblems() {
        if searchTags.isEmpty {
            displayedProblems = Array(allProblems.suffix(50)).filter { !solvedProblemIds.contains($0.id) }
        } else {
            displayedProblems = allProblems.filter { problem in
                guard let difficulty = problem.difficulty else {
                    return false
                }
                return searchTags.isSubset(of: Set(problem.tags)) &&
                    difficulty >= minDifficulty &&
                    difficulty <= maxDifficulty &&
                    !solvedProblemIds.contains(problem.id)
            }
            print(solvedProblemIds.count)
        }
    }

    func fetchUserHandle(uid: String) {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(uid)

        userRef.getDocument { document, error in
            if let error = error {
                print("Error fetching user handle: \(error)")
            } else {
                if let document = document, document.exists {
                    if let codeforcesHandle = document.get("codeforcesHandle") as? String {
                        DispatchQueue.main.async {
                            loadSolvedProblems(userHandle: codeforcesHandle)
                        }
                    } else {
                        print("Error: Codeforces handle not found.")
                    }
                } else {
                    print("Error: Document does not exist.")
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
    
    func fetchFavoriteProblems(uid: String) {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(uid)

        userRef.getDocument { document, error in
            if let error = error {
                print("Error fetching favorite problems: \(error)")
            } else {
                if let document = document, document.exists {
                    if let favoriteProblemsArray = document.get("favoriteProblems") as? [String] {
                        DispatchQueue.main.async {
                            favoriteProblemIds = Set(favoriteProblemsArray)
                        }
                    } else {
                        print("Error: Favorite problems not found.")
                    }
                } else {
                    print("Error: Document does not exist.")
                }
            }
        }
    }

}




struct ProblemListView_Previews: PreviewProvider {
    static var previews: some View {
        ProblemListView()
    }
}

struct ProblemSetProblemsResponse: Codable {
    let status: String
    let result: ProblemSetProblemsResult
}

struct ProblemSetProblemsResult: Codable {
    let problems: [Problem]
}

struct UserStatusResponse: Codable {
    let status: String
    let result: [Submission]
}

struct Submission: Codable {
    let id: Int
    let problem: SubmissionProblem
    let verdict: String
}

struct SubmissionProblem: Codable {
    let contestId: Int?
    let index: String
}

struct CustomNavigationBarTitle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(NavigationConfigurator(font: UIFont.systemFont(ofSize: 22, weight: .semibold), textColor: .red))
    }
}

struct NavigationConfigurator: UIViewControllerRepresentable {
    var font: UIFont
    var textColor: UIColor

    func makeUIViewController(context: UIViewControllerRepresentableContext<NavigationConfigurator>) -> UIViewController {
        return UIViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<NavigationConfigurator>) {
        guard let navigationBar = uiViewController.navigationController?.navigationBar else { return }
        navigationBar.titleTextAttributes = [
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.foregroundColor: textColor
        ]
    }
}
