//
//  SRAppDelegate.swift
//  SwatchesReader
//
//  Created by Viktor Goltvyanytsya on 03.01.2021.
//

import Foundation
import SwiftUI
import UIKit
import os.log


class SRAppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions
                        launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        copySamplePalette()
        return true
    }
    
    func application(_ application: UIApplication, willContinueUserActivityWithType userActivityType: String) -> Bool {
        return true
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        
        let configuration = UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
        
        return configuration
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    private func copySamplePalette() {
        let filemgr = FileManager.default
        let docURL = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let destPath = URL(string:docURL)?.appendingPathComponent("samples")
        
        guard let sourcePath = Bundle.main.path(forResource: "Crayola", ofType: "gpl") else {
            Logger.appLogger.debug("Sample file not found")
            return
        }
        
        guard let newDestPath = destPath, let fullDestPath = NSURL(fileURLWithPath: newDestPath.absoluteString).appendingPathComponent("Crayola.gpl") else { return  }
        
        
        if !filemgr.fileExists(atPath: newDestPath.path) {
            do {
                try filemgr.createDirectory(atPath: newDestPath.path, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(error.localizedDescription);
            }
        }
        else {
            Logger.appLogger.debug("Folder is exist")
        }
        
        if filemgr.fileExists(atPath: fullDestPath.path) {
            Logger.appLogger.debug("File is exist in \(fullDestPath.path)")
        }
        else {
            do {
                try filemgr.copyItem(atPath:  sourcePath, toPath: fullDestPath.path)
            } catch {
                Logger.appLogger.debug("Error: \(error.localizedDescription)")
            }
        }
    }
    
}

extension Logger {
    private static var subsystem = Bundle.main.bundleIdentifier!
    
    static let appLogger = Logger(subsystem: subsystem, category: "appLogger")
    
    public func logDebug(_ log: String) {
        Logger.appLogger.debug("log:\(log)")
    }
}
