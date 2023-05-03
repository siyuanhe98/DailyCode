//
//  WebsiteView.swift
//  cp-library
//
//  Created by Siyuan He on 4/28/23.
//

import SwiftUI

struct WebsiteView: View {
    var body: some View {
        VStack{
            WebView(urlString: "https://codeforces.com/")
        }
//        .toolbar {
//            ToolbarItem(placement: .principal) {
//                HStack{
//                    Image(systemName: "arrowshape.turn.up.backward.fill")
//                                    .resizable()
//                                    .frame(width: 25, height: 20)
//                                    .foregroundColor(Color(hex: "#7f8c8d"))
//                                    .padding(.leading, -200)
////                    Text("Problem Details")
////                        .font(Font.custom("BrunoAceSC-Regular", size: 25))
////                        .foregroundColor(Color(hex: "#16a085"))
//                }
//            }
//        }
    }
}

struct WebsiteView_Previews: PreviewProvider {
    static var previews: some View {
        WebsiteView()
    }
}
