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
                FeatureCell(image: "eye", title: "QuickLook", subtitle: "Improved QuickLook extension", color: .green)
                
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


