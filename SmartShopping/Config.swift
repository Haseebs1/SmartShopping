//
//  Config.swift
//  SmartShopping
//
//  Created by user279038 on 12/1/25.
//

//this is important file since it contain my database info..

//(SECRET FILE)
import Foundation

struct Config {
    static let appName = "Smart Shopping"
    static let appVersion = "1.0.0"
    static let buildNumber = "1"
    
    // Supabase Configuration
    static let supabaseURL = URL(string: "")!
    static let supabaseKey = ""
    
    // App Settings
    static let defaultCurrency = "USD"
    static let currencySymbol = "$"
    static let defaultQuantity = 1
    static let hapticFeedbackEnabled = true
}
