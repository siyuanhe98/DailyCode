//
//  InfoView.swift
//  cp-library
//
//  Created by Siyuan He on 4/26/23.
//

import SwiftUI

struct InfoView: View {
    let text1: String
    let text2: String
    let imageName: String
    var body: some View {
        RoundedRectangle(cornerRadius: 25)
            .fill(Color.white)
            .frame(height: 40)
            .overlay(HStack {
                Image(systemName: imageName)
                    .foregroundColor(Color(hex: "#2ecc71"))
                Text(text1)
                //This line below is required if you want the app to display correctly in dark mode.
                    //In dark mode all Text is automatically rendered as white.
                    //So we've created a custom color in the assets folder called Infor Color and used it here.
                    .foregroundColor(Color(hex: "#7f8c8d"))
                    .bold()
                Text(text2)
                    .foregroundColor(Color(hex: "#bdc3c7"))
            })
            .padding(.horizontal, 30) 
    }
}


struct InfoView_Previews: PreviewProvider {
    static var previews: some View {
        InfoView(text1: "Hello", text2: "hi", imageName: "phone.fill")
            .previewLayout(.sizeThatFits)
    }
}
