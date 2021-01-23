//
//  CPSwatch.swift
//  SwatchesReader
//
//  Created by Viktor Goltvyanytsya on 11/27/20.
//

import Foundation
import SwiftUI
import os.log



public struct CPSwatch: Identifiable, Codable, Equatable {
    
    public var id = UUID()
    
    public static var emptySwatch: CPSwatch =
        CPSwatch(colorName:"", color:UIColor.systemGray)
    
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
        return color.hex
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

extension CPSwatch: CustomStringConvertible {
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
