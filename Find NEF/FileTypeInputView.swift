//
//  FileTypeInputView.swift
//  Find NEF
//
//  Created by 高继鹏 on 6/14/25.
//

import SwiftUI

struct FileTypeInputView: View {
    @Binding var imageExtensions: [String]
    @Binding var rawExtensions: [String]
    let isSyncing: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            GroupBox(label: Text("Image File Types (Folder A)").bold()) {
                TextField("e.g. jpg, jpeg, png", text: Binding(
                    get: { imageExtensions.joined(separator: ", ") },
                    set: { imageExtensions = $0.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }.filter { !$0.isEmpty } }
                ))
                .disabled(isSyncing)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .help("Enter image file extensions separated by commas.")
            }

            GroupBox(label: Text("RAW/XMP File Types (Folder B)").bold()) {
                TextField("e.g. nef, xmp, acr", text: Binding(
                    get: { rawExtensions.joined(separator: ", ") },
                    set: { rawExtensions = $0.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }.filter { !$0.isEmpty } }
                ))
                .disabled(isSyncing)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .help("Enter raw or metadata file extensions separated by commas.")
            }
        }
    }
}
