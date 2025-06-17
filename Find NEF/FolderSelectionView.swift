//
//  FolderSelectionView.swift
//  Find NEF
//
//  Created by 高继鹏 on 6/14/25.
//

import SwiftUI

struct FolderSelectionView: View {
    let title: String
    let folder: URL?
    let needsReselect: Bool
    let helpTextValid: String
    let helpTextInvalid: String
    let onSelect: () -> Void

    var body: some View {
        HStack {
            Text(title.localized)
            Spacer()
            Button("Select".localized) { onSelect() }
            VStack(alignment: .leading, spacing: 2) {
                Text(folder?.lastPathComponent ?? "None".localized)
                HStack(spacing: 4) {
                    Image(systemName: needsReselect ? "xmark.circle.fill" : "checkmark.circle.fill")
                        .foregroundColor(needsReselect ? .red : .accentColor)
                        .help(needsReselect ? helpTextInvalid.localized : helpTextValid.localized)
                    Text(needsReselect ? "Invalid".localized : "Valid".localized)
                        .foregroundColor(needsReselect ? .red : .green)
                        .font(.caption)
                }
            }
        }
    }
}
