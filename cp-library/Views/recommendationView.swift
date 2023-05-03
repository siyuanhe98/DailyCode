import SwiftUI

struct recommendationView: View {
    @EnvironmentObject var userManager: UserManager
    @State private var userRating: Int = 0
    @State private var easyProblems: [Problem] = []
    @State private var mediumProblems: [Problem] = []
    @State private var hardProblems: [Problem] = []

    var body: some View {
        NavigationView {
            List {
                Section(header:
                            HStack{
                                Image(systemName: "circlebadge")
                                .resizable()
                                .frame(width: 18, height: 18)
                                .foregroundColor(Color(hex: "#7f8c8d"))
                            Text("Easy")
                                .foregroundColor(Color(hex: "#7f8c8d"))
                                .font(.headline)
                            }) {
                        ForEach(easyProblems) { problem in
                            NavigationLink(destination: DetailView(url: problem.urlInfo)) {
                                ProblemRow(problem: problem, color: getColorForDifficulty(problem.difficulty ?? 0))
                            }
                        }
                    }
                
                Section(header:
                            HStack{
                                Image(systemName: "circle.grid.2x1")
                                    .resizable()
                                    .frame(width: 18, height: 10)
                                    .foregroundColor(Color(hex: "#7f8c8d"))
                            Text("Medium")
                                .foregroundColor(Color(hex: "#7f8c8d"))
                                .font(.headline)
                            }) {
                    ForEach(mediumProblems) { problem in
                        NavigationLink(destination: DetailView(url: problem.urlInfo)) {
                            ProblemRow(problem: problem, color: getColorForDifficulty(problem.difficulty ?? 0))
                        }
                    }

                }
                
                Section(header:
                            HStack{
                                Image(systemName: "circle.grid.2x2")
                                    .resizable()
                                    .frame(width: 18, height: 18)
                                    .foregroundColor(Color(hex: "#7f8c8d"))
                                Text("Hard")
                                    .foregroundColor(Color(hex: "#7f8c8d"))
                                    .font(.headline)
                                }) {
                    ForEach(hardProblems) { problem in
                        NavigationLink(destination: DetailView(url: problem.urlInfo)) {
                            ProblemRow(problem: problem, color: getColorForDifficulty(problem.difficulty ?? 0))
                        }
                    }
                }
            }
            .listStyle(GroupedListStyle())
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("For You")
                        .font(Font.custom("BrunoAceSC-Regular", size: 35))
                        .foregroundColor(Color(hex: "#16a085"))
                }
            }
            .onAppear {
                userManager.fetchCodeforcesHandle { handle in
                    if let handle = handle {
                        userManager.fetchCodeforcesProfile(handle: handle) { result in
                            switch result {
                            case .success(let data):
                                if let resultArray = data["result"] as? [[String: Any]], let userProfile = resultArray.first {
                                    userRating = userProfile["rating"] as? Int ?? 0
                                    fetchProblems()
                                }
                            case .failure(let error):
                                print("Error fetching user rating: \(error.localizedDescription)")
                            }
                        }
                    }
                }
            }

        }
    }
    
    private func fetchProblems() {
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
                        let allProblems = decodedResponse.result.problems
                        print(allProblems.count)
                        print(userRating)
                        easyProblems = Array(allProblems.filter { problem in
                            guard let difficulty = problem.difficulty else { return false }
                            return difficulty >= userRating - 300 && difficulty <= userRating - 200
                        }
                        .shuffled()
                        .prefix(3))
                        
                        mediumProblems = Array(allProblems.filter { problem in
                            guard let difficulty = problem.difficulty else { return false }
                            return difficulty >= userRating - 100 && difficulty <= userRating + 100
                        }
                        .shuffled()
                        .prefix(3))
                        
                        hardProblems = Array(allProblems.filter { problem in
                            guard let difficulty = problem.difficulty else { return false }
                            return difficulty >= userRating + 200 && difficulty <= userRating + 300
                        }
                        .shuffled()
                        .prefix(3))
                    }
                } catch {
                    print("Error decoding JSON: \(error)")
                }
            }
        }
        
        task.resume()
    }
}

struct RecommendationView_Previews: PreviewProvider {
    static var previews: some View {
        recommendationView()
            .environmentObject(UserManager())
    }
}


