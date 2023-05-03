import SwiftUI
import EventKit

struct ContestView: View {
    @State private var contests: [Contest] = []
 
    var body: some View {
        NavigationView {
            List(contests) { contest in
                NavigationLink(destination: ContestDetailView(contest: contest)) {
                    Text(contest.name)
                        .bold()
                        .foregroundColor(Color(hex: "#7f8c8d"))
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Contests")
                        .font(Font.custom("BrunoAceSC-Regular", size: 35))
                        .foregroundColor(Color(hex: "#16a085"))
                }
            }
            .onAppear(perform: loadContests)
        }
    }
    
    private func loadContests() {
        let url = URL(string: "https://codeforces.com/api/contest.list")!
        let oneYearInSeconds: TimeInterval = 365 * 24 * 60 * 60
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                    if let result = json?["result"] as? [[String: Any]] {
                        DispatchQueue.main.async {
                            let contests = result.compactMap(Contest.init)
                            let currentDate = Date()
                            self.contests = contests.filter { contest in
                                if let startTime = contest.startTimeSeconds {
                                    let contestDate = Date(timeIntervalSince1970: startTime)
                                    return currentDate.timeIntervalSince(contestDate) <= oneYearInSeconds
                                }
                                return false
                            }
                        }
                    }
                } catch {
                    print("Error decoding JSON: \(error.localizedDescription)")
                }
            } else if let error = error {
                print("Error fetching contests: \(error.localizedDescription)")
            }
        }.resume()
    }
}

struct ContestDetailView: View {
    var contest: Contest
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false

    private let dateTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
    
    private func showAlert(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        showingAlert = true
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Contest ID: \(contest.id)")
                .font(.headline)
                .foregroundColor(Color(hex: "#7f8c8d"))
            Text("Contest Name: \(contest.name)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Color(hex: "#1abc9c"))
            Text("Contest Type: \(contest.type)")
                .font(.body)
            Text("Contest Phase: \(contest.phase)")
                .font(.body)
            if let startTime = contest.startTimeSeconds {
                Text("Start Time: \(dateTimeFormatter.string(from: Date(timeIntervalSince1970: startTime)))")
                    .font(.headline)
            }
            Text("Duration: \(contest.durationSeconds / 3600) hours")
                .font(.headline)
            Spacer()
                .alert(isPresented: $showingAlert) {
                    Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                }
            if contest.phase == "BEFORE" {
                HStack{
                    Spacer()
                    Button(action: addToCalendar) {
                        Text("Add to Calendar")
                            .frame(maxWidth: 150)
                            .font(Font.custom("BrunoAceSC-Regular", size: 20))
                    }
                    .tint(Color(hex: "#1abc9c"))
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    Spacer()
                }
                Spacer()
            }
        }
        .padding()
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack{
                    Image(systemName: "arrowshape.turn.up.backward.fill")
                                    .resizable()
                                    .frame(width: 25, height: 20)
                                    .foregroundColor(Color(hex: "#7f8c8d"))
                                    .padding(.leading, -50)
                    Text("Contest Details")
                        .font(Font.custom("BrunoAceSC-Regular", size: 25))
                        .foregroundColor(Color(hex: "#16a085"))
                }
            }
        }
    }
    private func addToCalendar() {
        let eventStore = EKEventStore()
        eventStore.requestAccess(to: .event) { granted, error in
            if granted && error == nil {
                let event = EKEvent(eventStore: eventStore)
                event.title = contest.name
                event.startDate = Date(timeIntervalSince1970: contest.startTimeSeconds!)
                event.endDate = event.startDate.addingTimeInterval(TimeInterval(contest.durationSeconds))
                event.calendar = eventStore.defaultCalendarForNewEvents
                event.notes = "Contest Type: \(contest.type)\nContest Phase: \(contest.phase)"
                
                do {
                    try eventStore.save(event, span: .thisEvent)
                    DispatchQueue.main.async {
                        showAlert(title: "Success", message: "Contest added to your calendar!")
                    }
                } catch let error as NSError {
                    DispatchQueue.main.async {
                        showAlert(title: "Error", message: "Failed to save the event: \(error.localizedDescription)")
                    }
                }
            } else {
                DispatchQueue.main.async {
                    showAlert(title: "Error", message: "Access to the calendar was not granted.")
                }
            }
        }
    }

}


struct Contest: Identifiable {
    let id: Int
    let name: String
    let type: String
    let phase: String
    let startTimeSeconds: TimeInterval?
    let durationSeconds: Int
    
    init?(json: [String: Any]) {
        guard let id = json["id"] as? Int,
              let name = json["name"] as? String,
              let type = json["type"] as? String,
              let phase = json["phase"] as? String,
              let durationSeconds = json["durationSeconds"] as? Int else {
            return nil
        }
        self.id = id
        self.name = name
        self.type = type
        self.phase = phase
        self.startTimeSeconds = json["startTimeSeconds"] as? TimeInterval
        self.durationSeconds = durationSeconds
    }
}

struct ContestView_Previews: PreviewProvider {
    static var previews: some View {
        ContestView()
    }
}
