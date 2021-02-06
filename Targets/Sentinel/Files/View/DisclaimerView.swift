//
// Copyright (c) N/A
//

import MessageUI
import SwiftUIX

struct DisclaimerView: View {
    @EnvironmentObject var appModel: AppModel
    
    @AppStorage("areConnectionIssuesAcknowledged") var ack = false
    
    @Environment(\.openURL) var openURL
    @Environment(\.presentationManager) var presentationManager
    
    private var mainText: Text {
        Text("Some users have experienced a disconnect from the dVPN when the phone goes to sleep.\n\nIf you would like to ensure no loss of VPN connection, set your phone's ")
            + (Text("Auto-Lock").font(.bodyBold) + Text(" to "))
            + (Text("Never").font(.bodyBold) + Text("."))
            + (Text("\n\nYour phone's seep settings can be found under ") + Text("Display & Brightness").font(.bodyBold) + Text( " → ") + Text("Auto-Lock").font(.bodyBold))
    }
    
    var body: some View {
        XStack {
            VStack(spacing: 36) {
                VStack(spacing: 36) {
                    Text("Notice")
                        .foregroundColor(.white)
                        .font(Font.custom("Overpass-Bold", relativeTo: .largeTitle))
                    
                    mainText
                        .foregroundColor(Color.white.opacity(0.8))
                }
                .padding(.top, .large)
                .padding(.top, .large)
                
                Group {
                    HStack {
                        Button {
                            openURL(URL(string:"App-Prefs:root=DISPLAY&path=AUTOLOCK")!)
                            appModel.isDisclaimerShown = true
                        } label: {
                            Text("Sleep Settings")
                                .foregroundColor(.white)
                                .padding()
                                .frame(width: Screen.main.width / 2.5)
                                .background(Color.black.opacity(0.2))
                                .cornerRadius(13)
                                .fixedSize()
                        }
                        .width(Screen.main.width / 2.5)
                        
                        Button {
                            presentationManager.dismiss()
                            appModel.isDisclaimerShown = true
                        } label: {
                            Text("Cancel")
                                .foregroundColor(.white)
                                .padding()
                                .frame(width: Screen.main.width / 2.5)
                                .background(Color.black.opacity(0.2))
                                .cornerRadius(13)
                                .fixedSize()
                        }
                    }
                    .visible(ack)
                    .overlay(
                        Group {
                            if !ack {
                                Button {
                                    ack = true
                                } label: {
                                    HStack {
                                        Spacer()
                                        
                                        Text("I understand")
                                            .foregroundColor(.white)
                                            .fixedSize()
                                        
                                        Spacer()
                                    }
                                    .padding()
                                    .background(Color.black.opacity(0.2))
                                    .cornerRadius(13)
                                }
                            }
                        }
                        .animation(.default)
                    )
                    .animation(.default)
                }
                .padding(.top)
                .padding(.bottom, .large)
                .padding(.bottom, .large)
            }
            .font(Font.custom("Overpass-Regular", relativeTo: .body))
            .padding(.horizontal)
        }
        .background(BackgroundGradient().background(.black).edgesIgnoringSafeArea(.all))
        .edgesIgnoringSafeArea(.all)
    }
}

struct DisclaimerView_Previews: PreviewProvider {
    static var previews: some View {
        DisclaimerView()
            .environmentObject(AppModel.shared)
    }
}

extension View {
    public func opaque() -> some View {
        background(Color.black)
    }
}
