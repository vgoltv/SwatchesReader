//
//  SRApp.swift
//  SwatchesReader
//
//  Created by Viktor Goltvyanytsya on 11/27/20.
//


import SwiftUI
import Combine
import os.log



@main
struct SRApp: App {
    @StateObject private var appModel = SRAppModel()
    @Environment(\.scenePhase) var scenePhase
    @State var samplesCopied: Bool = SRAppUtils.checkSamples()
    
    var errorView: some View {
        Text("Select File")
            .frame(minWidth: 200, maxWidth: .infinity, minHeight: 200, maxHeight: .infinity)
    }
    
    var body: some Scene {
        
        DocumentGroup(viewing: CPPaletteDocument.self) { file in
            Logger.vlog.logDebugInView("load palette view")
            Group {
                if let url = file.fileURL {// FileDocument
                    let filename = url.deletingPathExtension().lastPathComponent
                    CPPaletteContentView(document: file.document, filename: filename)
                        .environmentObject(appModel)
                        .frame(minWidth: 200, maxWidth: .infinity, minHeight: 200, maxHeight: .infinity)
                }else{
                    errorView
                }
            }
            .onAppear(perform: documentViewAppear)
            .onDisappear(perform: documentViewDisappear)
            .onChange(of: scenePhase) { phase in
                switch phase {
                case .active:
                    Logger.appLogger.debug("active phase")
                case .inactive:
                    Logger.appLogger.debug("inactive phase")
                case .background:
                    Logger.appLogger.debug("background phase")
                @unknown default:
                    Logger.appLogger.debug("Some other phase goes here")
                }
            }

        }
        
    }
    
    private func documentViewAppear() {
        Logger.appLogger.debug("palette view appear")
        
    }
    
    private func documentViewDisappear() {
        Logger.appLogger.debug("palette view disappear")
    }

}


