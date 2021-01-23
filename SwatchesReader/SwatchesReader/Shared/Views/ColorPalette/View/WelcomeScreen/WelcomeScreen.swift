//
//  WelcomeScreen.swift
//  ColorPalette
//
//  Created by Viktor Goltvyanytsya on 11/27/20.
//

import SwiftUI

struct WelcomeScreen: View {
    @Binding var showWelcomeScreen: Bool
    
    @State var appName: String = ""
    @State var appVersion: String = ""
    
    var body: some View {
        VStack {
            Spacer()
            Text("\(appName)")
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 48)
            Text("\(appVersion)")
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 48)
            Spacer()
            
            VStack(spacing: 24) {
                FeatureCell(image: "app", title: "App icon", subtitle: "Changed app's icon, now background color of it is white", color: .green)
                FeatureCell(image: "eyedropper.full", title: "Picker", subtitle: "Added system's ColorPicker", color: .blue)
                FeatureCell(image: "doc.on.clipboard.fill", title: "Color Models", subtitle: "Added ability to copy color values in a different models - as a CMYK, HSV, HSL, Lab or White", color: .gray)
                
            }
            .padding(.leading)
            
            Spacer()
            Spacer()
            
            Button(action: { self.showWelcomeScreen = false }) {
                HStack {
                    Spacer()
                    Text("Continue")
                        .font(.headline)
                        .foregroundColor(.white)
                    Spacer()
                }
            }
            .frame(height: 50)
            .background(Color.blue)
            .cornerRadius(15)
        }
        .padding()
    }
}


