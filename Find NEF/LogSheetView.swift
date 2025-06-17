//
//  LogSheetView.swift
//  Find NEF
//
//  Created by 高继鹏 on 6/14/25.
//

import SwiftUI

struct LogSheetView: View {
    let logMessages: [String]
    @Binding var isPresented: Bool

    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Text("Log Output")
                    .font(.headline)
                Spacer()
                Button("Copy All") {
                    let fullLog = logMessages.joined(separator: "\n")
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(fullLog, forType: .string)
                }
                Button("Close") {
                    isPresented = false
                }
            }

            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(logMessages.indices, id: \.self) { index in
                        Text(logMessages[index])
                            .font(.system(size: 12, design: .monospaced))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding()
            }
        }
        .padding()
        .frame(minWidth: 500, minHeight: 300)
    }
}
