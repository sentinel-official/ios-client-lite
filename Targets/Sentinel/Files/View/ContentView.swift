//
// Copyright (c) N/A
//

import NetworkKit
import SwiftUIX

struct ContentView: View {
    @EnvironmentObject var appModel: AppModel
    
    var body: some View {
        Group {
            if appModel.isOnboarded {
                if appModel.isMainViewActive {
                    mainView
                } else {
                    LaunchView()
                }
            } else {
                OnboardingView()
            }
        }
    }
    
    private var mainView: some View {
        ZStack {
            NavigationView {
                PaginationView {
                    ContinentList()
                    SettingsView()
                }
                .navigationBarTransparent(true)
                .backgroundFill(BackgroundGradient())
                .navigationBarTitleView(
                    HeaderView(isCompact: true),
                    displayMode: .inline
                )
            }
            .sheet(isPresented: $appModel.connectionViewIsVisible && appModel.connection != nil) {
                if let node = appModel.connection?.node {
                    ActiveNodeView(node: node)
                        .environmentObject(appModel)
                }
            }
            
            Text("").windowOverlay(isKeyAndVisible: .init(get: { !appModel.isDisclaimerShown }, set: { _ in })) {
                DisclaimerView()
                    .environmentObject(appModel)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AppModel.shared)
    }
}
