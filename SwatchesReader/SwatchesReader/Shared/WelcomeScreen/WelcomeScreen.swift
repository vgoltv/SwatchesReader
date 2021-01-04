//
//  WelcomeScreen.swift
//  SwatchesReader
//
//  Created by Viktor Goltvyanytsya on 11/27/20.
//

import SwiftUI

struct WelcomeScreen: View {
    @Binding var showWelcomeScreen: Bool
    
    @State var appName = ""
    @State var appVersion = ""
    
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
                FeatureCell(image: "list.bullet.rectangle", title: "Color Swatches", subtitle: "Read GIMP color palettes *.gpl", color: .green)
                
                FeatureCell(image: "square.grid.2x2", title: "Thumbnails", subtitle: "Includes fast thumbnails extension for the Files app", color: .blue)
                
                FeatureCell(image: "eye", title: "QuickLook", subtitle: "QuickLook extension to display fast preview of the palette on Files app", color: .red)
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


