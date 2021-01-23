//
//  CPPaletteModel.swift
//  ColorPalette
//
//  Created by Viktor Goltvyanytsya on 08.01.2021.
//

import SwiftUI
import Foundation
import os.log





@propertyWrapper
struct CPUserDefault<T> {
    var key: String
    var initialValue: T
    var wrappedValue: T {
        set { UserDefaults.standard.set(newValue, forKey: key) }
        get { UserDefaults.standard.object(forKey: key) as? T ?? initialValue }
    }
}

enum CPUserPreferences {
    @CPUserDefault(key: "view_swatches", initialValue: 0) static var swatchesMode: Int
}

class CPPaletteModel: ObservableObject {
    
    @Published var viewSwatchesOption: Int {
        didSet {
            CPUserPreferences.swatchesMode = self.viewSwatchesOption
        }
    }
    
    @Published var selectedCellIndexPath: IndexPath {
        didSet {// onSelectedItemAtIndexPath
            self.pickerColor = Color.red
        }
    }
    
    @Published var pickerColor: Color {
        didSet {
            
        }
    }
    
    init( ) {

        self.viewSwatchesOption = CPUserPreferences.swatchesMode
        
        self.selectedCellIndexPath = IndexPath(row: -1, section: -1)
        self.pickerColor = Color.gray
        
    }
    
    public var selectedCellUndefined: Bool {
        let ns: Bool = (selectedCellIndexPath.row<0 || selectedCellIndexPath.section<0)
        return ns
    }
    
}

