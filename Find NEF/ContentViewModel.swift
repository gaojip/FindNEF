//
//  ContentViewModel.swift
//  Find NEF
//
//  Created by 高继鹏 on 6/14/25.
//

import Foundation
import SwiftUI

class ContentViewModel: ObservableObject {
    @Published var folderA: URL?
    @Published var folderB: URL?
    @Published var outputFolder: URL?
    
    @Published var folderAPath: String = ""
    @Published var folderBPath: String = ""
    @Published var outputFolderPath: String = ""
    
    @Published var needsReselectFolderA = false
    @Published var needsReselectFolderB = false
    @Published var needsReselectOutputFolder = false
    
    @Published var isSyncing = false
    @Published var skipExistingFiles = true
    @Published var overwriteExistingFiles = false
    @Published var selectionMode: FileSelectionMode = .allInFolder
    
    @Published var showLogSheet = false
    @Published var showInputSheet = false
    
    @Published var logMessages: [String] = []
    @Published var alertMessage: IdentifiableString?
    
    @Published var manualInputFilenames: [String] = []
    
    @Published var imageExtensions: [String] = ["jpg", "jpeg", "png"]
    @Published var rawExtensions: [String] = ["acr", "nef", "xmp"]
    
    var hasLaunchedBefore: Bool {
        get { UserDefaults.standard.bool(forKey: "hasLaunchedBefore") }
        set { UserDefaults.standard.set(newValue, forKey: "hasLaunchedBefore") }
    }
    
    func selectFolder() -> URL? {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        return panel.runModal() == .OK ? panel.url : nil
    }
    
    func validateRestoredPaths() {
        let fm = FileManager.default
        
        if !folderAPath.isEmpty {
            let url = URL(fileURLWithPath: folderAPath)
            if fm.fileExists(atPath: url.path, isDirectory: nil) {
                folderA = url
                needsReselectFolderA = false
            } else {
                folderA = nil
                needsReselectFolderA = true
            }
        }
        
        if !folderBPath.isEmpty {
            let url = URL(fileURLWithPath: folderBPath)
            if fm.fileExists(atPath: url.path, isDirectory: nil) {
                folderB = url
                needsReselectFolderB = false
            } else {
                folderB = nil
                needsReselectFolderB = true
            }
        }
        
        if !outputFolderPath.isEmpty {
            let url = URL(fileURLWithPath: outputFolderPath)
            var isDirectory: ObjCBool = false
            if fm.fileExists(atPath: url.path, isDirectory: &isDirectory), isDirectory.boolValue {
                let writable = fm.isWritableFile(atPath: url.path)
                outputFolder = writable ? url : nil
                needsReselectOutputFolder = !writable
            } else {
                outputFolder = nil
                needsReselectOutputFolder = true
            }
        }
    }
}
