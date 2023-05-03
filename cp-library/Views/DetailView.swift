//
//  DetailView.swift
//  cp-library
//
//  Created by Siyuan He on 4/27/23.
//

import SwiftUI

struct DetailView: View {
    
    let url: String?
    
    var body: some View {
        VStack{
            WebView(urlString: url)
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack{
                    Image(systemName: "arrowshape.turn.up.backward.fill")
                                    .resizable()
                                    .frame(width: 25, height: 20)
                                    .foregroundColor(Color(hex: "#7f8c8d"))
                                    .padding(.leading, -50)
                    Text("Problem Details")
                        .font(Font.custom("BrunoAceSC-Regular", size: 25))
                        .foregroundColor(Color(hex: "#16a085"))
                }
            }
        }
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView(url: "https://www.google.com")
    }
}
