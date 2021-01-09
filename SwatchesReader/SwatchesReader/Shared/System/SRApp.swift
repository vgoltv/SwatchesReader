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
    
    @UIApplicationDelegateAdaptor(SRAppDelegate.self) var appDelegate
    
    var body: some Scene {
        SRSwatchesScene()
    }

}
