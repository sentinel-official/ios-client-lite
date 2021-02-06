//
// Copyright (c) Sentinel
//

import SwiftUIX

@main
struct App: SwiftUI.App {
    @Environment(\.openURL) var openURL
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .accentColor(Color.white.opacity(0.8))
                .environmentObject(AppModel.shared)
        }
    }
}
