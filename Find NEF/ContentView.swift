//
//  ContentView.swift
//  Find NEF
//
//  Created by 高继鹏 on 6/14/25.
//

import SwiftUI
import AppKit

extension String {
    var localized: String {
        NSLocalizedString(self, comment: "")
    }
}

struct IdentifiableString: Identifiable, Equatable {
    let id = UUID()
    let value: String

    static func == (lhs: IdentifiableString, rhs: IdentifiableString) -> Bool {
        lhs.id == rhs.id && lhs.value == rhs.value
    }
}

struct ContentView: View {
    enum FileSelectionMode: String, CaseIterable, Identifiable {
        case allFromFolderA = "Use All Files in Folder A"
        case manualInput = "Enter File Names Manually"
        var id: String { self.rawValue }
    }

    @State private var folderA: URL?
    @State private var folderB: URL?
    @State private var outputFolder: URL?
    @AppStorage("folderAPath") private var folderAPath: String = ""
    @AppStorage("folderBPath") private var folderBPath: String = ""
    @AppStorage("outputFolderPath") private var outputFolderPath: String = ""
    @State private var needsReselectFolderA = false
    @State private var needsReselectFolderB = false
    @State private var needsReselectOutputFolder = false
    @AppStorage("imageExtensionsInput") private var imageExtensionsInput: String = "jpg, jpeg, png"
    @AppStorage("rawExtensionsInput") private var rawExtensionsInput: String = "acr, NEF, xmp"
    @State private var logMessages: [String] = []
    @State private var isLogPresented = false
    @State private var isSyncing = false
    @State private var currentProgress: Int = 0
    @State private var totalCount: Int = 0
    @State private var isCancelled = false
    @State private var selectionMode: FileSelectionMode = .allFromFolderA
    @State private var showInputSheet = false
    @State private var inputFilenames: String = ""
    @State private var skipExistingFiles = true
    @State private var overwriteExistingFiles = false
    @State private var alertMessage: IdentifiableString?
    @State private var copiedFiles: [URL] = []
    @AppStorage("hasLaunchedBefore") private var hasLaunchedBefore: Bool = false
    @State private var showAdvancedOptions = false

    var body: some View {
        VStack(spacing: 18) {
            // Folder A GroupBox
            GroupBox(label: Label("Folder A (Photos):".localized, systemImage: "folder")) {
                HStack(alignment: .top, spacing: 12) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(folderA?.path ?? "None".localized)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .lineLimit(nil)
                            .contextMenu {
                                if let path = folderA?.path {
                                    Button("Copy Path") {
                                        NSPasteboard.general.clearContents()
                                        NSPasteboard.general.setString(path, forType: .string)
                                    }
                                }
                            }
                        Label(
                            needsReselectFolderA ? "Invalid".localized : "Valid".localized,
                            systemImage: needsReselectFolderA ? "xmark.circle.fill" : "checkmark.circle.fill"
                        )
                        .labelStyle(.iconOnly)
                        .foregroundColor(needsReselectFolderA ? Color.red.opacity(0.8) : Color.accentColor)
                        .help(needsReselectFolderA ? "Folder A path is invalid or not a folder.".localized : "Folder A path is valid (restored from last session).".localized)
                        .font(.caption)
                    }
                    Spacer()
                    Button {
                        if let url = selectFolder() {
                            folderA = url
                            folderAPath = url.path
                        }
                    } label: {
                        Label("Select".localized, systemImage: "folder.badge.plus")
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                }
            }
            // Folder B GroupBox
            GroupBox(label: Label("Folder B (RAW/XMP):".localized, systemImage: "externaldrive")) {
                HStack(alignment: .top, spacing: 12) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(folderB?.path ?? "None".localized)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .lineLimit(nil)
                            .contextMenu {
                                if let path = folderB?.path {
                                    Button("Copy Path") {
                                        NSPasteboard.general.clearContents()
                                        NSPasteboard.general.setString(path, forType: .string)
                                    }
                                }
                            }
                        Label(
                            needsReselectFolderB ? "Invalid".localized : "Valid".localized,
                            systemImage: needsReselectFolderB ? "xmark.circle.fill" : "checkmark.circle.fill"
                        )
                        .labelStyle(.iconOnly)
                        .foregroundColor(needsReselectFolderB ? Color.red.opacity(0.8) : Color.accentColor)
                        .help(needsReselectFolderB ? "Folder B path is invalid or not a folder.".localized : "Folder B path is valid (restored from last session).".localized)
                        .font(.caption)
                    }
                    Spacer()
                    Button {
                        if let url = selectFolder() {
                            folderB = url
                            folderBPath = url.path
                        }
                    } label: {
                        Label("Select".localized, systemImage: "folder.badge.plus")
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                }
            }
            // Output Folder GroupBox
            GroupBox(label: Label("Output Folder:".localized, systemImage: "folder.fill.badge.plus")) {
                HStack(alignment: .top, spacing: 12) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(outputFolder?.path ?? "None".localized)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .lineLimit(nil)
                            .contextMenu {
                                if let path = outputFolder?.path {
                                    Button("Copy Path") {
                                        NSPasteboard.general.clearContents()
                                        NSPasteboard.general.setString(path, forType: .string)
                                    }
                                }
                            }
                        Label(
                            needsReselectOutputFolder ? "Invalid".localized : "Valid".localized,
                            systemImage: needsReselectOutputFolder ? "xmark.circle.fill" : "checkmark.circle.fill"
                        )
                        .labelStyle(.iconOnly)
                        .foregroundColor(needsReselectOutputFolder ? Color.red.opacity(0.8) : Color.accentColor)
                        .help(needsReselectOutputFolder ? "Output folder is invalid or not writable.".localized : "Output folder is valid (restored from last session).".localized)
                        .font(.caption)
                    }
                    Spacer()
                    Button {
                        if let url = selectFolder() {
                            outputFolder = url
                            outputFolderPath = url.path
                        }
                    } label: {
                        Label("Select".localized, systemImage: "folder.badge.plus")
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                }
            }

            DisclosureGroup("Advanced Settings".localized, isExpanded: $showAdvancedOptions) {
                VStack(alignment: .leading, spacing: 8) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Extensions for Folder A (comma separated, no dot):".localized)
                            .font(.caption)
                        TextField("e.g. jpg, jpeg, png".localized, text: $imageExtensionsInput)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        Text("Example: jpg, jpeg, png".localized).font(.caption).foregroundColor(.gray)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Extensions for Folder B (comma separated, no dot):".localized)
                            .font(.caption)
                        TextField("e.g. acr, NEF, xmp".localized, text: $rawExtensionsInput)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        Text("Example: cr2, dng, arw".localized).font(.caption).foregroundColor(.gray)
                    }
                    Toggle("Skip files that already exist in output folder".localized, isOn: $skipExistingFiles)
                        .disabled(isSyncing)
                    Toggle("Overwrite files that already exist in output folder".localized, isOn: $overwriteExistingFiles)
                        .disabled(isSyncing)
                        .help("If both skip and overwrite are off, existing files will be skipped with a log message.".localized)
                }
                .padding(.top, 6)
            }
            .animation(.easeInOut, value: showAdvancedOptions)

            Picker("File Selection Mode".localized, selection: $selectionMode) {
                ForEach(FileSelectionMode.allCases) { mode in
                    Text(mode.rawValue.localized).tag(mode)
                }
            }
            .pickerStyle(.menu)
            .onChange(of: selectionMode) { _, newValue in
                if newValue == .manualInput {
                    showInputSheet = true
                }
            }
            if selectionMode == .manualInput {
                Button("Edit Input List".localized) {
                    showInputSheet = true
                }
            }


            HStack(spacing: 12) {
                Button {
                    validateRestoredPaths()
                } label: {
                    Label("Validate Folder Paths".localized, systemImage: "checkmark.shield")
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
                .disabled(isSyncing)

                Button {
                    // Prevent syncing if any folder needs to be reselected
                    if needsReselectFolderA || needsReselectFolderB || needsReselectOutputFolder {
                        return
                    }

                    guard (selectionMode == .manualInput || folderA != nil), let b = folderB, let out = outputFolder else {
                        alertMessage = IdentifiableString(value: "Please select all three folders.".localized)
                        return
                    }

                    var isDirectory: ObjCBool = false
                    if !FileManager.default.fileExists(atPath: out.path, isDirectory: &isDirectory) || !isDirectory.boolValue {
                        alertMessage = IdentifiableString(value: "The output folder does not exist or is not a directory.".localized)
                        return
                    }

                    if !FileManager.default.isWritableFile(atPath: out.path) {
                        alertMessage = IdentifiableString(value: "You don't have permission to write to the output folder. Please reselect it.".localized)
                        return
                    }

                    logMessages = ["Syncing...".localized]
                    isSyncing = true
                    isCancelled = false
                    currentProgress = 0
                    copiedFiles = []
                    Task {
                        let result = await syncFiles(from: folderA ?? URL(fileURLWithPath: "/"), and: b, to: out)
                        await MainActor.run {
                            logMessages = result.log
                            totalCount = result.total
                            isSyncing = false
                            copiedFiles = result.copiedFiles
                            if !isCancelled && !copiedFiles.isEmpty {
                                NSWorkspace.shared.activateFileViewerSelecting(copiedFiles)
                            }
                        }
                    }
                } label: {
                    Label("Start Sync".localized, systemImage: "arrow.triangle.2.circlepath")
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
                .disabled(isSyncing)

                Button {
                    isLogPresented = true
                } label: {
                    Label("Show Logs".localized, systemImage: "doc.text.magnifyingglass")
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                .disabled(logMessages.isEmpty)
            }
            .padding(.bottom, 2)

            if isSyncing {
                ProgressView("Working...".localized + " \(currentProgress)/\(totalCount)")
                    .padding()
                Button("Cancel".localized) {
                    isCancelled = true
                }
                .foregroundColor(.red)
            }

            ScrollView {
                VStack(alignment: .leading) {
                    ForEach(logMessages, id: \.self) { msg in
                        Text(msg.localized)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
            .frame(maxHeight: 300)
        }
        .padding()
        .frame(width: 500)
        .onAppear {
            if !hasLaunchedBefore {
                hasLaunchedBefore = true
            }
            // Removed: validateRestoredPaths()
        }
        .alert(item: $alertMessage) { msg in
            Alert(title: Text("Validation".localized), message: Text(msg.value.localized), dismissButton: .default(Text("OK".localized)))
        }
        .onChange(of: alertMessage) { oldValue, newValue in
            if newValue != nil {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    alertMessage = nil
                }
            }
        }
        .sheet(isPresented: $isLogPresented) {
            VStack(alignment: .leading) {
                Text("Log Output".localized)
                    .font(.headline)
                    .padding()
                ScrollView {
                    Text(logMessages.map { $0.localized }.joined(separator: "\n"))
                        .font(.system(.body, design: .monospaced))
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                Button("Copy to Clipboard".localized) {
                    let fullLog = logMessages.joined(separator: "\n")
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(fullLog, forType: .string)
                }
                .padding()
                Button("Close".localized) {
                    isLogPresented = false
                }
                .padding(.bottom)
            }
            .frame(minWidth: 500, minHeight: 300)
        }
        .sheet(isPresented: $showInputSheet) {
            VStack(alignment: .leading, spacing: 10) {
                Text("Enter file names from Folder A (no extensions)".localized)
                    .font(.headline)
                    .padding(.top)
                TextEditor(text: $inputFilenames)
                    .font(.system(.body, design: .monospaced))
                    .frame(minHeight: 200)
                    .border(Color.gray)
                HStack {
                    Button("Paste from Clipboard".localized) {
                        if let pasted = NSPasteboard.general.string(forType: .string) {
                            inputFilenames = pasted
                        }
                    }
                    Spacer()
                }
                .padding(.top)
                Button("Done".localized) {
                    showInputSheet = false
                }
                .padding(.bottom)
            }
            .padding()
            .frame(width: 500, height: 300)
        }
        .sheet(isPresented: $needsReselectFolderA) {
            VStack {
                Text("Please reselect Folder A".localized)
                Button("Select".localized) {
                    if let url = selectFolder() {
                        folderA = url
                        folderAPath = url.path
                    }
                    needsReselectFolderA = false
                }
            }
            .padding()
            .frame(width: 350, height: 120)
        }
        .sheet(isPresented: $needsReselectFolderB) {
            VStack {
                Text("Please reselect Folder B".localized)
                Button("Select".localized) {
                    if let url = selectFolder() {
                        folderB = url
                        folderBPath = url.path
                    }
                    needsReselectFolderB = false
                }
            }
            .padding()
            .frame(width: 350, height: 120)
        }
        .sheet(isPresented: $needsReselectOutputFolder) {
            VStack {
                Text("Please reselect Output Folder".localized)
                Button("Select".localized) {
                    if let url = selectFolder() {
                        outputFolder = url
                        outputFolderPath = url.path
                    }
                    needsReselectOutputFolder = false
                }
            }
            .padding()
            .frame(width: 350, height: 120)
        }
    }

    func selectFolder() -> URL? {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.canCreateDirectories = true
        panel.allowsMultipleSelection = false
        return panel.runModal() == .OK ? panel.url : nil
    }

    func syncFiles(from folderA: URL, and folderB: URL, to outputFolder: URL) async -> (log: [String], total: Int, copiedFiles: [URL]) {
        let fm = FileManager.default
        let imageExtensions = imageExtensionsInput
            .components(separatedBy: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }
            .filter { !$0.isEmpty }
        let rawExtensions = rawExtensionsInput
            .components(separatedBy: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }
            .filter { !$0.isEmpty }
        var localLog: [String] = []
        var copied: [URL] = []

        let aFiles: [URL]
        if selectionMode == .manualInput {
            aFiles = []
        } else {
            guard FileManager.default.fileExists(atPath: folderA.path) else {
                return (["Failed to read Folder A".localized], 0, [])
            }
            aFiles = (try? fm.contentsOfDirectory(at: folderA, includingPropertiesForKeys: nil)) ?? []
        }
        let bFiles = (try? fm.contentsOfDirectory(atPath: folderB.path)) ?? []
        let bFileDict = Dictionary(uniqueKeysWithValues: bFiles.map { ($0.lowercased(), $0) })

        let selectedManualEntries: [String] = {
            if selectionMode == .manualInput {
                // Separate entries into those with extensions and those without
                let entries = inputFilenames
                    .replacingOccurrences(of: "\r", with: "\n")
                    .components(separatedBy: CharacterSet(charactersIn: " \n"))
                    .filter { !$0.isEmpty }
                    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                return entries
            } else {
                return []
            }
        }()

        let baseNames: [String]
        if selectionMode == .manualInput {
            baseNames = selectedManualEntries
        } else {
            baseNames = aFiles.compactMap { url -> String? in
                let ext = url.pathExtension.lowercased()
                let name = url.deletingPathExtension().lastPathComponent
                return imageExtensions.contains(ext) ? name : nil
            }
        }

        // Prepare all candidate filenames to copy
        let allCandidates: [String]
        if selectionMode == .manualInput {
            let entriesWithExt = selectedManualEntries.filter { $0.contains(".") }
            let entriesWithoutExt = selectedManualEntries.filter { !$0.contains(".") }
            allCandidates = entriesWithExt + entriesWithoutExt.flatMap { base in
                rawExtensions.map { ext in "\(base).\(ext)" }
            }
        } else {
            allCandidates = baseNames.flatMap { base in
                rawExtensions.map { ext in "\(base).\(ext)" }
            }
        }
        let total = allCandidates.count
        await MainActor.run { self.totalCount = total }
        for (idx, candidate) in allCandidates.enumerated() {
            if isCancelled {
                break
            }
            let candidateLower = candidate.lowercased()
            if let actualFileName = bFileDict[candidateLower] {
                let src = folderB.appendingPathComponent(actualFileName)
                let dest = outputFolder.appendingPathComponent(actualFileName)
                if fm.fileExists(atPath: dest.path) {
                    if skipExistingFiles {
                        localLog.append(String(format: NSLocalizedString("Skipped (already exists): %@", comment: ""), actualFileName))
                        await MainActor.run { self.currentProgress = idx + 1 }
                        continue
                    } else if !overwriteExistingFiles {
                        localLog.append(String(format: NSLocalizedString("Skipped (exists, overwrite disabled): %@", comment: ""), actualFileName))
                        await MainActor.run { self.currentProgress = idx + 1 }
                        continue
                    } else {
                        try? fm.removeItem(at: dest)
                    }
                }
                do {
                    try fm.copyItem(at: src, to: dest)
                    localLog.append(String(format: NSLocalizedString("Copied: %@", comment: ""), actualFileName))
                    copied.append(dest)
                } catch {
                    localLog.append(String(format: NSLocalizedString("Failed to copy: %@ — %@", comment: ""), actualFileName, error.localizedDescription))
                }
            }
            await MainActor.run { self.currentProgress = idx + 1 }
        }
        if isCancelled {
            localLog.append("Sync cancelled.".localized)
        } else if copied.isEmpty {
            localLog.append("No matching files found.".localized)
        }
        return (localLog, total, copied)
    }

    func validateRestoredPaths() {
        if !folderAPath.isEmpty {
            let url = URL(fileURLWithPath: folderAPath)
            var isDirectory: ObjCBool = false
            if FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory), isDirectory.boolValue {
                folderA = url
                needsReselectFolderA = false
            } else if alertMessage == nil {
                folderAPath = ""
                alertMessage = IdentifiableString(value: "Folder A path is invalid or not a folder. Please reselect Folder A.".localized)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    needsReselectFolderA = true
                }
                return
            }
        }

        if !folderBPath.isEmpty && alertMessage == nil {
            let url = URL(fileURLWithPath: folderBPath)
            var isDirectory: ObjCBool = false
            if FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory), isDirectory.boolValue {
                folderB = url
                needsReselectFolderB = false
            } else {
                folderBPath = ""
                alertMessage = IdentifiableString(value: "Folder B path is invalid or not a folder. Please reselect Folder B.".localized)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    needsReselectFolderB = true
                }
                return
            }
        }

        if !outputFolderPath.isEmpty && alertMessage == nil {
            let url = URL(fileURLWithPath: outputFolderPath)
            var isDirectory: ObjCBool = false
            if FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory), isDirectory.boolValue {
                if FileManager.default.isWritableFile(atPath: url.path) {
                    outputFolder = url
                    needsReselectOutputFolder = false
                } else {
                    outputFolderPath = ""
                    alertMessage = IdentifiableString(value: "Output folder is not writable. Please reselect the Output Folder.".localized)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        needsReselectOutputFolder = true
                    }
                    return
                }
            } else {
                outputFolderPath = ""
                alertMessage = IdentifiableString(value: "Output folder path is invalid or not a folder. Please reselect the Output Folder.".localized)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    needsReselectOutputFolder = true
                }
                return
            }
        }
    }
}
