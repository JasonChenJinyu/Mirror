//
//  ContentView.swift
//  SidecarAutoConnect
//
//  Created by Jason Chen on 2025/8/20.
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                Image(nsImage: NSApplication.shared.applicationIconImage)
                    .resizable()
                    .frame(width: 64, height: 64)
                    .cornerRadius(12)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Mirror")
                        .font(.title3).bold()
                        .foregroundStyle(.secondary)
                }
            }
            Divider()
            Text("© 2025 Your Name. All rights reserved.")
            Text("This utility initiates Sidecar connections to your iPad. “Sidecar” and related marks are trademarks of Apple Inc. This project is not affiliated with or endorsed by Apple.")
                .font(.footnote)
                .foregroundStyle(.secondary)
            Spacer()
            HStack {
                Spacer()
                Button("Close") { NSApp.keyWindow?.close() }
            }
        }
        .padding(20)
        .frame(minWidth: 420, minHeight: 200)
    }
}

#Preview {
    AboutView()
}
