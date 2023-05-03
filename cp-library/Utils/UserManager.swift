import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

class UserManager: ObservableObject {
    @Published var isLoggedIn = false
    private(set) var user: User?
    private var db = Firestore.firestore()
    init() {
        setUserFromUserDefaults()
        Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            if let user = user {
                self?.user = user
                self?.isLoggedIn = true
            } else {
                self?.user = nil
                self?.isLoggedIn = false
            }
        }
    }


    func register(email: String, password: String, completion: @escaping (String) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                let errorMsg = error.localizedDescription ?? "Unknown error"
                completion(errorMsg)
                return
            }

            if let firebaseUser = result?.user {
                self?.isLoggedIn = true
                self?.user = firebaseUser
                
                UserDefaults.standard.set(firebaseUser.uid, forKey: "user_id") // Add this line
                let newUser = [
                    "uid": firebaseUser.uid,
                    "email": email,
                    "codeforcesHandle": "",
                    "favoriteProblems": []
                ]
                self?.db.collection("users").document(firebaseUser.uid).setData(newUser) { error in
                    if let error = error {
                        print("Error adding user to Firestore: \(error.localizedDescription)")
                    } else {
                        print("User added to Firestore")
                    }
                }
            } else {
                print("Unknown error occurred during registration")
            }
            completion("")
        }
    }



//    func login(email: String, password: String) {
//        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
//            if let user = result?.user {
//                self?.isLoggedIn = true
//                self?.user = user
//                UserDefaults.standard.set(user.uid, forKey: "user_id")
//                print("User logged in: \(user.uid)")
//            } else {
//                print("Error: \(error?.localizedDescription ?? "Unknown error")")
//                errorMsg = error!.localizedDescription ?? "Unknown error"
//            }
//        }
//    }

    func login(email: String, password: String, completion: @escaping (String) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            if let user = result?.user {
                self?.isLoggedIn = true
                self?.user = user
                UserDefaults.standard.set(user.uid, forKey: "user_id")
                print("User logged in: \(user.uid)")
                completion("")
            } else {
                let errorMsg = error!.localizedDescription ?? "Unknown error"
                completion(errorMsg)
            }
        }
    }


    func logout() {
        do {
            try Auth.auth().signOut()
            isLoggedIn = false
            user = nil
        } catch let error {
            print("Error signing out: \(error.localizedDescription)")
        }
    }

    func addSolvedProblem(problemId: String, completion: @escaping (Bool) -> Void) {
        guard let userId = user?.uid else {
            completion(false)
            return
        }

        let solvedProblemRef = db.collection("users").document(userId).collection("solvedProblems").document(problemId)
        solvedProblemRef.setData(["solved": true]) { error in
            if let error = error {
                print("Error adding solved problem: \(error.localizedDescription)")
                completion(false)
            } else {
                completion(true)
            }
        }
    }

    func checkIfProblemSolved(problemId: String, completion: @escaping (Bool) -> Void) {
        guard let userId = user?.uid else {
            completion(false)
            return
        }

        let solvedProblemRef = db.collection("users").document(userId).collection("solvedProblems").document(problemId)
        solvedProblemRef.getDocument { document, error in
            if let document = document, document.exists {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    func updateCodeforcesHandle(handle: String, completion: @escaping (Bool) -> Void) {
        print("Updating Codeforces handle: \(handle)")
        guard let userId = user?.uid else {
            print("User ID not found")
            completion(false)
            return
        }

        let userRef = db.collection("users").document(userId)
        userRef.updateData(["codeforcesHandle": handle]) { error in
            if let error = error {
                print("Error updating Codeforces handle: \(error.localizedDescription)")
                completion(false)
            } else {
                print("Codeforces handle updated successfully")
                           
                completion(true)
            }
        }
    }

    func fetchCodeforcesHandle(completion: @escaping (String?) -> Void) {
        guard let userId = user?.uid else {
            completion(nil)
            return
        }

        let userRef = db.collection("users").document(userId)
        userRef.getDocument { document, error in
            if let document = document, let handle = document.get("codeforcesHandle") as? String {
                completion(handle)
            } else {
                completion(nil)
            }
        }
    }

    func fetchCodeforcesProfile(handle: String, completion: @escaping (Result<[String: Any], Error>) -> Void) {
        let url = URL(string: "https://codeforces.com/api/user.info?handles=\(handle)")!

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "com.example.app", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                }
                return
            }
            //print(data)
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                DispatchQueue.main.async {
                    completion(.success(json ?? [:]))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }

        task.resume()
    }
    
    func setUserFromUserDefaults() {
        if let userEmail = UserDefaults.standard.string(forKey: "user_email") {
            Auth.auth().signIn(withEmail: userEmail, password: "") { [weak self] result, error in
                if let user = result?.user {
                    self?.isLoggedIn = true
                    self?.user = user
                } else {
                    print("Error: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        }
    }


}
