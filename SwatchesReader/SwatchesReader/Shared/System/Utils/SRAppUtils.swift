//
//  SRAppUtils.swift
//  SwatchesReader
//
//  Created by Viktor Goltvyanytsya on 09.01.2021.
//

import Foundation


import SwiftUI
import os.log





struct SRAppUtils  {
    
    public static func checkSamples() ->Bool {
        
        let filemgr = FileManager.default
        let docURL = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let destPath = URL(string:docURL)?.appendingPathComponent("samples")
        
        guard let sourcePath = Bundle.main.path(forResource: "Crayola", ofType: "gpl") else {
            Logger.appLogger.debug("Sample file not found")
            return false
        }
        
        guard let newDestPath = destPath, let fullDestPath = NSURL(fileURLWithPath: newDestPath.absoluteString).appendingPathComponent("Crayola.gpl") else { return false  }
        
        
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
            Logger.appLogger.debug("File is exist")
            return false
        }
        else {
            do {
                try filemgr.copyItem(atPath:  sourcePath, toPath: fullDestPath.path)
            } catch {
                Logger.appLogger.debug("Error: \(error.localizedDescription)")
                return false
            }
        }
        
        return true
    }

}
