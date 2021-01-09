//
//  SRSwatchesScene.swift
//  SwatchesReader
//
//  Created by Viktor Goltvyanytsya on 08.01.2021.
//









import SwiftUI
import Combine
import os.log


struct SRSwatchesScene: Scene {
    
    @Environment(\.scenePhase) var scenePhase

    var body: some Scene {
        
        DocumentGroup(viewing: SwatchesDocument.self) { file in
            Logger.vlog.logDebugInView("load collection view")
            Group {
                if let url = file.fileURL {
                    let filename = url.deletingPathExtension().lastPathComponent
                    SwatchesContentView(document: file.$document, filename: filename)
                        .frame(minWidth: 200, maxWidth: .infinity, minHeight: 200, maxHeight: .infinity)
                }else{
                    ErrorView()
                        .frame(minWidth: 200, maxWidth: .infinity, minHeight: 200, maxHeight: .infinity)
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
        Logger.appLogger.debug("appear")
    }
    
    private func documentViewDisappear() {
        Logger.appLogger.debug("disappear")
    }
    
}

struct ErrorView: View {
    var body: some View {
        Text("Select File")
    }
}
