//
//  SyncOptionsView.swift
//  Find NEF
//
//  Created by 高继鹏 on 6/14/25.
//

import SwiftUI

struct SyncOptionsView: View {
    @Binding var skipExistingFiles: Bool
    @Binding var overwriteExistingFiles: Bool
    @Binding var isSyncing: Bool
    let onSync: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Toggle("Skip existing files", isOn: $skipExistingFiles)
                .disabled(isSyncing)

            Toggle("Overwrite existing files", isOn: $overwriteExistingFiles)
                .disabled(isSyncing)

            Button(action: onSync) {
                Text(isSyncing ? "Syncing..." : "Start Sync")
                    .frame(maxWidth: .infinity)
            }
            .padding()
            .background(isSyncing ? Color.gray : Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
            .disabled(isSyncing)
        }
    }
}
