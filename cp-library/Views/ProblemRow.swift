//
//  ProblemRow.swift
//  cp-library
//
//  Created by OnjoujiToki on 4/18/23.
//

import SwiftUI

struct ProblemRow: View {
    let problem: Problem
    var color: Color
    var body: some View {
        VStack(alignment: .leading) {
            Text(problem.id + " " + problem.name)
                .foregroundColor(color)
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

