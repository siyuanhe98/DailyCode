//
//  LightSwitchView.swift
//  cp-library
//
//  Created by Siyuan He on 4/28/23.
//

import SwiftUI

struct LightSwitchView: View {
    
    // MARK:- variables
    let appWidth = UIScreen.main.bounds.width
    let appHeight = UIScreen.main.bounds.height
    let animationDuration: TimeInterval = 0.35
    
    @State var xScale: CGFloat = 2
    @State var yScale: CGFloat = 0.4
    @State var yOffset: CGFloat = UIScreen.main.bounds.height * 0.8
    
    @State var isOff: Bool = true
    
    // MARK:- views
    var body: some View {
        ZStack {
            Color(hex: "#1abc9c")
            Circle()
                .fill(Color(hex: "#16a085"))
                .scaleEffect(CGSize(width: xScale, height: yScale))
                .offset(y: yOffset)
            
            ZStack {
                Capsule(style: .continuous)
                    .foregroundColor(.gray)
                    .frame(width: 52, height: appHeight * 0.25 + 6)
                    .opacity(0.275)
                    .offset(x: appWidth / 2 - 48, y: 16)
                
                ZStack {
                    Capsule()
                        .frame(width: 3, height: self.isOff ? appHeight * 0.41 : appHeight * 0.625)
                        .foregroundColor(.white)
                    
                    Circle()
                        .fill(Color.white)
                        .overlay(
                            Group {
                                if !isOff {
                                    Image(systemName: "chevron.up")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 25, height: 25)
                                        .foregroundColor(Color(hex: "#7f8c8d"))
                                } else {
                                    Image(systemName: "chevron.down")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 25, height: 25)
                                        .foregroundColor(Color(hex: "#7f8c8d"))
                                }
                            }
                        )
                        .frame(width: 42, height: 42)
                        .offset(y: self.isOff ? appHeight * 0.225: appHeight * 0.25 + 42)
                        .onTapGesture {
                            toggleAllLights()
                        }
                        
                }.offset(x: appWidth / 2 - 48, y: -appHeight / 2)
                .frame(height: 0, alignment: .top)
            }
            .animation(Animation.spring(dampingFraction: 0.65).speed(1.25))
            
            VStack {
                if !isOff{
                    Text("Contributor 2")
                        .font(Font.custom("BrunoAceSC-Regular", size: 30))
                        .foregroundColor(.white)
                        .padding(.bottom, 30)
                    VStack {
                        Image("profile2")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 100.0, height: 100.0)
                            .clipShape(Circle())
                            .overlay(
                                Circle().stroke(Color(.systemGray6), lineWidth: 0.5)
                        )
                        Text("OnjoujiToki")
                            .font(Font.custom("Pacifico-Regular", size: 25))
                            .bold()
                            .foregroundColor(.white)
                            .padding(.top, -10)
                            .padding(.bottom, 1)
                        InfoAboutView(text: "GitHub Profile", imageName: "person.crop.square.filled.and.at.rectangle", infoUrl: "https://github.com/OnjoujiToki")
                        InfoEmailView(imageName: "envelope.fill", email: "zhang.zhihao1@northeastern.edu")
                    }
                }else{
                    Text("Contributor 1")
                        .font(Font.custom("BrunoAceSC-Regular", size: 30))
                        .foregroundColor(.white)
                        .padding(.bottom, 30)
                    VStack {
                        Image("profile1")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 100.0, height: 100.0)
                            .clipShape(Circle())
                            .overlay(
                                Circle().stroke(Color(.systemGray6), lineWidth: 0.5)
                        )
                        Text("Siyuan He")
                            .font(Font.custom("Pacifico-Regular", size: 25))
                            .bold()
                            .foregroundColor(.white)
                            .padding(.top, -10)
                            .padding(.bottom, 1)
                        InfoAboutView(text: "GitHub Profile", imageName: "person.crop.square.filled.and.at.rectangle", infoUrl: "https://github.com/siyuanhe98")
                        InfoEmailView(imageName: "envelope.fill", email: "he.siyua@northeastern.edu")
                    }
                }
            }
            .padding(.bottom, 100)
            
        }.edgesIgnoringSafeArea(.all)
    }
    
    // MARK:- functions
    func toggleAllLights() {
        if (isOff) {
            withAnimation(Animation.easeIn(duration: animationDuration)) {
                xScale = 4
                yScale = 4
                yOffset = 0
            }
        } else {
            withAnimation(Animation.easeOut(duration: animationDuration * 0.75)) {
                yScale = 0.4
                xScale = 2
                yOffset = UIScreen.main.bounds.height * 0.8
            }
        }
        isOff.toggle()
    }
}

struct LightSwitchView_Previews: PreviewProvider {
    static var previews: some View {
        LightSwitchView()
    }
}

struct InfoEmailView: View {
    let imageName: String
    let email: String
    var body: some View {
        RoundedRectangle(cornerRadius: 25)
            .fill(Color.white)
            .frame(height: 50)
            .overlay(HStack {
                Image(systemName: imageName)
                    .foregroundColor(Color(hex: "#2c3e50"))
                Link("Email me", destination: URL(string: "mailto:\(email)")!)
                //This line below is required if you want the app to display correctly in dark mode.
                    //In dark mode all Text is automatically rendered as white.
                    //So we've created a custom color in the assets folder called Infor Color and used it here.
                    .foregroundColor(Color(hex: "#7f8c8d"))
            }
//            .padding(.leading, -37)
            )
            .padding(.horizontal, 110)
    }
}

struct InfoAboutView: View {
    let text: String
    let imageName: String
    let infoUrl: String
    var body: some View {
        RoundedRectangle(cornerRadius: 25)
            .fill(Color.white)
            .frame(height: 50)
            .overlay(HStack {
                Image(systemName: imageName)
                    .foregroundColor(Color(hex: "#2c3e50"))
                Text(text)
                    .onTapGesture {
                        UIApplication.shared.open(URL(string: infoUrl)!)
                    }
                //This line below is required if you want the app to display correctly in dark mode.
                    //In dark mode all Text is automatically rendered as white.
                    //So we've created a custom color in the assets folder called Infor Color and used it here.
                    .foregroundColor(Color(hex: "#7f8c8d"))
            })
            .padding(.horizontal, 110)
    }
}

