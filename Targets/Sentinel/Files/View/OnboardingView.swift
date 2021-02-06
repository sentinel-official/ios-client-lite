//
// Copyright (c) N/A
//

import CoreData
import SwiftUIX

struct OnboardingView: View {
    @EnvironmentObject var appModel: AppModel
    
    @State var currentPageIndex: Int = 0
    
    var body: some View {
        VStack {
            HeaderView()
                .padding(.top)
                .padding(.top)
                .padding(.top)
            
            Spacer()
            
            PaginationView(0..<5, id: \.hashValue) { index in
                OnboardingPage(index: index)
                    .padding(.bottom)
            }
            .currentPageIndex($currentPageIndex)
            .height(Screen.main.bounds.height * 0.5)
            
            Spacer()
            
            Button(action: moveToNext) {
                Text("Next")
                    .foregroundColor(.secondary)
                    .font(.headline)
            }
            .padding()
        }
        .fill()
        .background(BackgroundGradient())
    }
    
    private func moveToNext() {
        if currentPageIndex == 4 {            
            self.appModel.isOnboarded = true
            self.appModel.isMainViewActive = true
        } else {
            self.currentPageIndex = min(currentPageIndex + 1, 4)
        }
    }
}

extension OnboardingView {
    struct OnboardingPage: View {
        let index: Int
        
        static let descriptions: [String] = [
            "Sentinel is not just a VPN, it's a 'decentralized'\nopen-source, provable VPN, or a 'dVPN'.",
            "The Sentinel dVPN can prove that your\nconnection is being end-to-end encrypted with\nno exceptions.",
            "The Sentinel dVPN can prove that your\nbrowsing history and information is not being stored.",
            "The Sentinel dVPN leverages the first\nencrypted P2P bandwidth network.",
            "We hope you enjoy your ad-free dVPN\nexperience!",
        ]
        
        var body: some View {
            VStack {
                Image("info\(index + 1)")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                
                Text(Self.descriptions[index])
                    .font(.callout)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
            }
        }
    }
}
