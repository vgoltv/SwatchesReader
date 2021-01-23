//
//  SRAppExtensions.swift
//  SwatchesReader
//
//  Created by Viktor Goltvyanytsya on 09.01.2021.
//

import Foundation
import SwiftUI
import os.log

private struct CurrencyFormatterKey: EnvironmentKey {
    static var defaultValue: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = .current
        formatter.numberStyle = .currency
        return formatter
    }()
}

// MARK: - NumberFormatter

private struct NumberFormatterKey: EnvironmentKey {
    static var defaultValue = NumberFormatter()
}

extension EnvironmentValues {
    var currencyFormatter: NumberFormatter {
        get { self[CurrencyFormatterKey.self] }
        set { self[CurrencyFormatterKey.self] = newValue }
    }
    
    var numberFormatter: NumberFormatter {
        get { self[NumberFormatterKey.self] }
        set { self[NumberFormatterKey.self] = newValue }
    }
}

extension Logger {
    private static var subsystem = Bundle.main.bundleIdentifier!
    
    static let appLogger = Logger(subsystem: subsystem, category: "appLogger")
    
    public func logDebug(_ log: String) {
        Logger.appLogger.debug("log:\(log)")
    }
}
