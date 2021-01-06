//
//  Swatch.swift
//  SwatchesReader
//
//  Created by Viktor Goltvyanytsya on 11/27/20.
//

import Foundation
import SwiftUI
import os.log



public struct Swatch: Codable, Equatable {
    
    private var colorName: String
    private var color: UIColor
    
    init(colorName: String, color: UIColor) {
        self.colorName = colorName
        self.color = color
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        colorName = try container.decode(String.self, forKey: .colorName)
        color = try container.decode(RGBColor.self, forKey: .color).uiColor
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(colorName, forKey: .colorName)
        try container.encode(RGBColor(uiColor: color), forKey: .color)
    }
    
    public func hexString() -> String  {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        if r <= 0 && r >= 1 && g <= 0 && g >= 1 && b <= 0 && b >= 1
        {
            let error = UIColorInputError.unableToOutputHexStringForWideDisplayColor
            Logger.vlog.error("\(error.localizedDescription)")
            
            return String(format: "#%02X%02X%02X", 0,0,0)
        }
        
        return String(format: "#%02X%02X%02X", Int(round(r * 255)),
                      Int(round(g * 255)), Int(round(b * 255)))
    }
    
    public func baseColorName() -> String {
        return self.colorName
    }
    
    public func baseColor() -> Color {
        return Color(self.color)
    }
    
    public func baseUIColor() -> UIColor {
        return self.color
    }
    
    public func baseColorString() -> String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        return String(format: "R:%i G:%i B:%i", Int(round(r * 255)),
                      Int(round(g * 255)), Int(round(b * 255)))
    }
    
    enum CodingKeys: String, CodingKey {
        case colorName = "color_name"
        case color = "color"
    }
    
}

extension Swatch: CustomStringConvertible {
    public var description: String {
        return """
        --- --- ---
        Color name: \(colorName)
        Hex string: \(hexString())
        --- --- ---
        """
    }
}

struct RGBColor : Codable {
    var red : CGFloat = 0.0, green: CGFloat = 0.0, blue: CGFloat = 0.0, alpha: CGFloat = 0.0
    
    var uiColor : UIColor {
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    init(uiColor : UIColor) {
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    }
}

public enum UIColorInputError: Error {
    
    case unableToOutputHexStringForWideDisplayColor
}

extension UIColorInputError: LocalizedError {
    
    public var errorDescription: String? {
        switch self {
        case .unableToOutputHexStringForWideDisplayColor:
            return "Unable to output hex string for wide display color"
        }
    }
}
