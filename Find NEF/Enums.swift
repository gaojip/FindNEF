//
//  Enums.swift
//  Find NEF
//
//  Created by 高继鹏 on 6/14/25.
//

import Foundation

enum FileSelectionMode: String, CaseIterable, Identifiable {
    case allInFolder
    case manualInput

    var id: String { self.rawValue }

    var label: String {
        switch self {
        case .allInFolder: return "All Files in Folder"
        case .manualInput: return "Manual Input"
        }
    }
}
