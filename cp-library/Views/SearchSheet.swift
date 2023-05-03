import SwiftUI

struct SearchSheet: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var minDifficulty: Int
    @Binding var maxDifficulty: Int
    @Binding var searchTags: Set<String>
    let onSearch: () -> Void
    let availableTags: [String] = ["dp", "graphs", "math", "greedy", "implementation", "brute force", "2-sat","binary search","bitmasks","chinese remainder theorm","combinatorics","constructive algorithms","dfs and similiar","divide and conquer", "dsu","expression parsing","fft","flows","games","graph matchings","hashing","interactive","matrices","meet-in-the-middle","number theory","probabilities","schedules","shortest paths","string suffix structures","strings", "data structures", "sortings", "ternary search", "trees", "two pointers"]

    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "#1abc9c")
                    .edgesIgnoringSafeArea(.all)
                VStack {
                    VStack{
                        VStack {
                            Text("Difficulty Range")
                                .padding(.top, 10)
                                .foregroundColor(Color(hex: "#2c3e50"))
                                .font(Font.custom("BrunoAceSC-Regular", size: 15))
                            Picker("Minimum Difficulty", selection: $minDifficulty) {
                                ForEach(Array(stride(from: 1000, to: 3000, by: 100)), id: \.self) { difficulty in
                                    Text("\(difficulty)").tag(difficulty)
                                }
                            }
                            Picker("Maximum Difficulty", selection: $maxDifficulty) {
                                ForEach(Array(stride(from: 1000, to: 3000, by: 100)), id: \.self) { difficulty in
                                    Text("\(difficulty)").tag(difficulty)
                                }
                            }
                        }
                        Divider()
                        VStack(alignment: .leading) {
                            Text("Tags")
                                .padding(.top, -10)
                                .foregroundColor(Color(hex: "#2c3e50"))
                                .font(Font.custom("BrunoAceSC-Regular", size: 15))
                            let columns = [GridItem(.adaptive(minimum: 150), spacing: 16)]
                            ScrollView {
                                LazyVGrid(columns: columns, spacing: 16) {
                                    ForEach(availableTags, id: \.self) { tag in
                                        Button(action: {
                                            if searchTags.contains(tag) {
                                                searchTags.remove(tag)
                                            } else {
                                                searchTags.insert(tag)
                                            }
                                        }) {
                                            HStack {
                                                Text(tag)
                                                    .lineLimit(1)
                                                    .minimumScaleFactor(0.5)
                                                Spacer()
                                                if searchTags.contains(tag) {
                                                    Image(systemName: "checkmark")
                                                }
                                            }
                                            .frame(height: 20)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(RoundedRectangle(cornerRadius: 8).stroke(Color(hex: "#E0E0E0"), lineWidth: 1))
                                        }
                                    }
                                }
                            }
                        }
                        .padding()
                        Spacer()
                    }
                    .background(Color(.white))
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    
                }
                .padding()
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text("Filters")
                            .font(Font.custom("BrunoAceSC-Regular", size: 35))
                            .foregroundColor(Color(.white))
                    }
                }
                .navigationBarItems(trailing: Button(action: {
                    onSearch()
                    presentationMode.wrappedValue.dismiss()
                    
                }) {
                    Image(systemName: "checkmark.circle.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(Color(hex: "#34495e"))
                    
                })
            }
        }
        .accentColor(Color(hex: "#7f8c8d"))
    }
}

struct SearchSheet_Previews: PreviewProvider {
    @State static var minDifficulty = 1500
    @State static var maxDifficulty = 2000
    @State static var searchTags: Set<String> = Set<String>(["dp"])

    static var previews: some View {
        SearchSheet(minDifficulty: $minDifficulty, maxDifficulty: $maxDifficulty, searchTags: $searchTags, onSearch: {})
    }
}
