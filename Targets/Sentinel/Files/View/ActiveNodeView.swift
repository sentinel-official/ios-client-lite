//
// Copyright (c) N/A
//

import Combine
import SwiftUIX
import Swallow

struct ActiveNodeView: View {
    @EnvironmentObject var appModel: AppModel
    
    @TimerState(interval: 0.5) var tick
    
    @State var backupTick: Int = 0
    let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    
    let node: Node
    
    var body: some View {
        NavigationView {
            XStack {
                VStack {
                    VStack(alignment: .leading) {
                        VStack(alignment: .leading) {
                            node.locationDescription.ifSome {
                                Text($0).font(.titleSemibold)
                            }
                            
                            node.ip.ifSome {
                                (Text("IP").font(.title2Semibold) + Text(" ") + Text($0).font(.titleSemibold))
                            }
                        }
                        .padding()
                        
                        HStack {
                            Spacer()
                            
                            VStack(spacing: 4) {
                                Image(systemName: .hourglass)
                                    .imageScale(.large)
                                
                                Text("Latency")
                                    .font(.body)
                                
                                Text(String(node.latency ?? 0))
                                    .font(.footnote)
                                    .foregroundColor(.white)
                            }
                            
                            Spacer()
                            
                            VStack(spacing: 4) {
                                Image(systemName: "cpu")
                                    .imageScale(.large)
                                
                                Text("Encryption")
                                    .font(.body)
                                
                                Text(node.enc_method ?? "")
                                    .font(.footnote)
                                    .foregroundColor(.white)
                            }
                            
                            Spacer()
                            
                            VStack(spacing: 4) {
                                Image(systemName: "clock.arrow.circlepath")
                                    .imageScale(.large)
                                
                                Text("Duration")
                                    .font(.body)
                                
                                if let connectedAt = appModel.connection?.connectedAt {
                                    Text(connectedAt, style: .relative)
                                        .font(.footnote)
                                        .foregroundColor(.white)
                                        .animation(.default)
                                        .id(ManyHashable(tick, backupTick))
                                } else {
                                    Text("-")
                                        .font(.footnote)
                                        .foregroundColor(.white)
                                        .animation(.default)
                                        .id(ManyHashable(tick, backupTick))
                                }
                            }
                            
                            Spacer()
                        }
                        .font(.body)
                        .foregroundColor(Color.white.opacity(0.8))
                        .padding()
                        
                        (appModel.connection?.status ?? .connected).ifSome { status in
                            ZStack {
                                LinearGradient(gradient: .init(colors: [Color.green.opacity(0.2), Color.green]), startPoint: .leading, endPoint: .trailing)
                                
                                Text("VPN Status: \(status.description)")
                                    .font(.body)
                            }
                            .height(44)
                        }
                        
                        Spacer()
                        
                        Button(action: { appModel.disconnect() }) {
                            ZStack {
                                VisualEffectBlurView(blurStyle: .systemThinMaterialDark).opacity(0.2)
                                
                                LinearGradient(gradient: .init(colors: [Color.black, Color.white]), startPoint: .leading, endPoint: .trailing)
                                    .opacity(0.1)
                                
                                HStack {
                                    if appModel.connection?.status == .disconnecting {
                                        ActivityIndicator()
                                    }
                                    
                                    Text(appModel.connection?.status == .disconnecting ? "Disconnecting " : "Disconnect")
                                        .font(.title3Semibold)
                                        .foregroundColor(Color.white.opacity(0.8))
                                        .textCase(.uppercase)
                                }
                            }
                        }
                        .height(52)
                        .padding(.bottom)
                    }
                }
            }
            .backgroundFill(BackgroundGradient().background(Color.black.edgesIgnoringSafeArea(.all)))
            .navigationBarTransparent(true)
            .navigationBarTitleView(
                HeaderView(isCompact: true),
                displayMode: .inline
            )
            .onReceive(timer) { _ in
                backupTick += 1
            }
        }
    }
}

struct ActiveNodeView_Previews: PreviewProvider {
    static var previews: some View {
        if let node = AppModel.shared.nodes?.list.first {
            ActiveNodeView(node: node)
                .environmentObject(AppModel.shared)
                .background(BackgroundGradient())
        } else {
            ActivityIndicator()
        }
    }
}

private extension Node {
    var locationDescription: String? {
        guard let city = location?.city, let country = location?.country else {
            return nil
        }
        
        return city + ", " + country
    }
}
