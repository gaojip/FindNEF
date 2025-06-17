//
//  ManualInputSheet.swift
//  Find NEF
//
//  Created by 高继鹏 on 6/14/25.
//

import SwiftUI

struct ManualInputSheet: View {
    @Binding var isPresented: Bool
    @Binding var inputText: String
    let onConfirm: ([String]) -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("Enter file names from Folder A")
                .font(.headline)

            TextEditor(text: $inputText)
                .frame(minHeight: 150)
                .border(Color.gray.opacity(0.5), width: 1)
                .padding(.horizontal)

            HStack {
                Spacer()
                Button("Cancel") {
                    isPresented = false
                }
                Button("Confirm") {
                    let names = inputText
                        .components(separatedBy: CharacterSet.whitespacesAndNewlines)
                        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                        .filter { !$0.isEmpty }
                    onConfirm(names)
                    isPresented = false
                }
                .keyboardShortcut(.defaultAction)
            }
            .padding(.horizontal)
        }
        .padding()
        .frame(minWidth: 400)
    }
}
