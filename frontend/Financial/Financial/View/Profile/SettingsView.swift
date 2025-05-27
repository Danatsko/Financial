//
//  SettingsView.swift
//  Financial
//
//  Created by KeeR ReeK on 12.05.2025.
//  Copyright (c) 2025 Financial

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var languageSettings: LanguageSettings

    var body: some View {
        VStack {
            Text("Select Language")
                .font(.headline)

            Picker("Language", selection: $languageSettings.language) {
                Text("English").tag("en")
                Text("Українська").tag("uk")
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            Spacer()
        }
        .padding()
        .navigationTitle("Settings")
    }
}
