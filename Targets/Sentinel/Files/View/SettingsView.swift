//
// Copyright (c) N/A
//

import NetworkKit
import SwiftUIX

struct SettingsItem: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .frame(height: 96)
            .frame(.greedy, .horizontal, alignment: .leading)
            .background(Color.black.opacity(0.2))
            .cornerRadius(13)
    }
}

struct SettingsView: View {
    @Environment(\.openURL) var openURL
    
    @EnvironmentObject var appModel: AppModel
    
    var body: some View {
        XStack {
            VStack {
                gridView
                    .padding(.horizontal)
                
                Toggle(isOn: $appModel.shouldAutoConnect) {
                    VStack(alignment: .leading, spacing: 4) {
                        (Text("Auto ").font(.title3Semibold) + Text("Connect").font(.title3))
                        
                        Text("Automatic connect on app launch")
                            .foregroundColor(Color.white.opacity(0.8))
                            .font(.footnote)
                            .fixedSize()
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
                
                Button(action: { openURL(URL(string: "https://sentinel.co")!) }) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            (Text("Learn ").font(.title3Semibold) + Text("More").font(.title3))
                                .font(.title3)
                                .foregroundColor(.white)
                            
                            Text("Sentinel P2P bandwidth marketplace")
                                .foregroundColor(Color.white.opacity(0.8))
                                .font(.footnote)
                                .fixedSize()
                        }
                        
                        Spacer()
                        
                        Image(systemName: .chevronRight)
                            .imageScale(.medium)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, .small)
                    .background(Color.black.opacity(0.2))
                    .padding(.bottom)
                }
                
                WithInlineState(initialValue: false) { isPresenting in
                    Button("Facing connection issues?") {
                        isPresenting.wrappedValue = true
                    }
                    .sheet(isPresented: isPresenting) {
                        DisclaimerView()
                            .environmentObject(appModel)
                    }
                    .font(.footnote)
                    .foregroundColor(.secondary)
                }

                Spacer()
                
                Link(destination: URL(string: "https://exidio.co")!) {
                    BuiltByDisclaimer()
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.vertical)
        }
    }
    
    var gridView: some View {
        LazyVGrid(columns: [GridItem.init(.flexible()), GridItem(.flexible())]) {
            PresentationLink(destination: SupportInformationMailComposer()) {
                VStack(alignment: .leading) {
                    Image(systemName: .envelopeFill)
                        .imageScale(.large)
                        .squareFrame(sideLength: 28)
                        .padding(.bottom)
                    
                    Text("Support")
                        .font(.headline)
                        .fixedSize()
                }
                .foregroundColor(.white)
                .modifier(SettingsItem())
            }
            
            Link(destination: URL(string: "https://twitter.com/sentinel_co")!) {
                VStack(alignment: .leading) {
                    Image("logo.twitter")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .squareFrame(sideLength: 28)
                        .padding(.bottom)
                    
                    Text("Twitter")
                        .font(.headline)
                        .fixedSize()
                }
                .foregroundColor(.white)
                .modifier(SettingsItem())
            }
            
            Link(destination: URL(string: "https://medium.com/@Sentinel")!) {
                VStack(alignment: .leading) {
                    Image(systemName: "newspaper.fill")
                        .imageScale(.large)
                        .squareFrame(sideLength: 28)
                        .padding(.bottom)
                    
                    Text("Blog")
                        .font(.headline)
                        .fixedSize()
                }
                .foregroundColor(.white)
                .modifier(SettingsItem())
            }
            
            Link(destination: URL(string: "https://t.me/sentinel_co")!) {
                VStack(alignment: .leading) {
                    Image("logo.telegram")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .squareFrame(sideLength: 28)
                        .padding(.bottom)
                    
                    Text("Telegram")
                        .font(.headline)
                        .fixedSize()
                }
                .foregroundColor(.white)
                .modifier(SettingsItem())
            }
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.vertical)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(AppModel.shared)
            .background(BackgroundGradient())
    }
}
