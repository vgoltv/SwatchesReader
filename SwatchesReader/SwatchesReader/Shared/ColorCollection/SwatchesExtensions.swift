//
//  SwatchesExtensions.swift
//  SwatchesReader
//
//  Created by Viktor Goltvyanytsya on 10/26/20.
//  Copyright © 2020 Viktor Goltvyanytsya. All rights reserved.
//

import Foundation
import SwiftUI
import os.log


extension Logger {
    private static var subsystem = Bundle.main.bundleIdentifier!

    static let vlog = Logger(subsystem: subsystem, category: "vlog")
    
    public func logDebugInView(_ log: String) -> EmptyView {
        Logger.vlog.debug("log:\(log)")
        return EmptyView()
    }
    
    public func logDebugSimple(_ log: String) {
        Logger.vlog.debug("log:\(log)")
    }
}

extension URL {
    var typeIdentifier: String? { (try? resourceValues(forKeys: [.typeIdentifierKey]))?.typeIdentifier }
    var localizedName: String? { (try? resourceValues(forKeys: [.localizedNameKey]))?.localizedName }
}

extension View {
     public func addBorder<S>(_ content: S, width: CGFloat = 1, cornerRadius: CGFloat) -> some View where S : ShapeStyle {
         let roundedRect = RoundedRectangle(cornerRadius: cornerRadius)
         return clipShape(roundedRect)
              .overlay(roundedRect.strokeBorder(content, lineWidth: width))
     }
 }

extension String {
    enum SearchDirection {
        case first, last
    }
    func characterIndex(of character: Character, direction: String.SearchDirection) -> Int? {
        let fn = direction == .first ? firstIndex : lastIndex
        if let stringIndex: String.Index = fn(character) {
            let index: Int = distance(from: startIndex, to: stringIndex)
            return index
        }  else {
            return nil
        }
    }
}

extension String {
    subscript(_ range: CountableRange<Int>) -> String {
        let start = index(startIndex, offsetBy: max(0, range.lowerBound))
        let end = index(start, offsetBy: min(self.count - range.lowerBound,
                                             range.upperBound - range.lowerBound))
        return String(self[start..<end])
    }

    subscript(_ range: CountablePartialRangeFrom<Int>) -> String {
        let start = index(startIndex, offsetBy: max(0, range.lowerBound))
         return String(self[start...])
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
