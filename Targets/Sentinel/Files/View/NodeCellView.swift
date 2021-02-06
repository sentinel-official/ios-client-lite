//
// Copyright (c) N/A
//

import NetworkExtension
import NetworkKit
import SwiftUIX

struct NoNodeCellView: View {
    var body: some View {
        VStack(spacing: 0) {
            Text("Disconnected")
                .bold()
                .font(.title)
                .foregroundColor(.primary)
                .fixedSize()
                .padding(.bottom)
            
            Text("You're not connected to any node\nat the moment.")
                .font(.callout)
                .foregroundColor(.secondary)
                .lineLimit(2)
                .multilineTextAlignment(.center)
        }
        .frame(.greedy, .horizontal)
        .padding()
        .padding(.vertical)
        .padding(.vertical)
        .background(VisualEffectBlurView(blurStyle: .systemThinMaterialDark).opacity(0.5))
        .cornerRadius(13)
    }
}

struct NodeCellView: View {
    @EnvironmentObject var appModel: AppModel
    
    let model: Node
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            if appModel.connection?.node == model {
                Button(toggle: $appModel.connectionViewIsVisible) {
                    content.contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())
            } else {
                content
            }
            
            HStack {
                if appModel.badNodes.contains(model) {
                    Image(systemName: .exclamationmarkTriangleFill)
                        .foregroundColor(.yellow)
                        .imageScale(.small)
                }
                
                NodeConnectButton(node: model, isCompact: true)
            }
        }
        .padding()
        .background(Color.black.opacity(0.2))
        .cornerRadius(13)
        .contextMenu(menuItems: {
            PresentationLink(destination: SupportInformationMailComposer(node: model)) {
                Label("Report", systemImage: .flagFill)
            }
        })
    }
    
    private var content: some View {
        VStack(alignment: .leading) {
            HStack {
                if let country = (model.location?.country).flatMap({ Continents.countryNameToCountryMap[$0] }) {
                    Image(country.alpha2)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 32)
                }
                
                Text(model.name)
                    .font(.headline)
            }
            .padding(.bottom, .small)
            
            VStack(spacing: 8) {
                /*makeLabel(title: "Address", value: model.ip ?? "---")
                    .alignmentGuide(.trailing)*/
                
                makeLabel(title: "Latency", value: model.latencyDescription ?? "---")
                    .alignmentGuide(.trailing)
                
                makeLabel(title: "Version", value: model.version ?? "---")
                    .alignmentGuide(.trailing)
                
                makeLabel(title: "Rating", value: model.ratingDescription ?? "---")
                    .alignmentGuide(.trailing)
            }
        }
    }
    
    func makeLabel(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.footnote)
                .foregroundColor(.gray)
            
            Text(value)
                .font(.footnote)
                .foregroundColor(.white)
            
            Spacer()
        }
    }
}

struct NodeConnectButton: View {
    @EnvironmentObject var appModel: AppModel
    
    let node: Node?
    var country: String? = nil
    let isCompact: Bool
        
    init(node: Node? = nil, country: String? = nil, isCompact: Bool) {
        self.node = node
        self.country = country
        self.isCompact = isCompact
    }
    
    var body: some View {
        Group {
            Button(action: connectOrDisconnect) {
                if isCompact {
                    HStack(spacing: 4) {
                        Text((status ?? .disconnected) .buttonTitle)
                            .font(.subheadlineSemibold)
                            .foregroundColor(Color.white.opacity(status == .disconnected ? 0.5 : 1.0))
                            .animation(.default)
                        
                        if let node = node, let nodeTask = appModel.nodeTasks[node] {
                            if nodeTask.statusDescription == .active {
                                ActivityIndicator()
                                    .style(.medium)
                                    .scaleEffect(0.8)
                            }
                        }
                    }
                } else {
                    VStack(alignment: .leading) {
                        HStack(alignment: .firstTextBaseline) {
                            Image(systemName: .boltFill)
                            
                            Text((status ?? .disconnected).largeButtonTitle)
                                .font(.headlineSemibold)
                                .fixedSize()
                        }
                        
                        Divider()
                            .padding(.trailing)
                            .padding(.trailing)
                        
                        Text("Connect to a random node")
                            .font(.footnote)
                            .foregroundColor(Color.secondary)
                            .fixedSize()
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black.opacity(0.2))
                    .cornerRadius(13, style: .continuous)
                    .animation(.default)
                }
            }
        }
    }
    
    var status: NEVPNStatus? {
        if let node = node {
            return appModel.connection?.node == node
                ? appModel.connection?.status
                : .disconnected
        } else {
            return appModel.connection?.status
        }
    }
    
    private func connectOrDisconnect() {
        if let status = status, status == .connected || status == .connecting {
            appModel.disconnect()
        } else {
            if let node = node {
                if appModel.badNodes.contains(node) {
                    Alert(
                        title: "Oops!",
                        message: "This node is temporarily unavailable.",
                        dismissButtonTitle: "Dismiss"
                    )
                    .present()
                } else {
                    appModel.connectOrDisconnect(to: node)
                }
            } else {
                appModel.connectToRandomNode(in: country)
            }
        }
    }
}

extension NEVPNStatus {
    var buttonTitle: String {
        switch self {
            case .invalid:
                return "Invalid"
            case .disconnected:
                return "Connect"
            case .connecting:
                return "Connecting"
            case .connected:
                return "Disconnect"
            case .reasserting:
                return "Reasserting"
            case .disconnecting:
                return "Disconnecting"
            @unknown default:
                return "Unknown"
        }
    }
    
    var largeButtonTitle: String {
        switch self {
            case .invalid:
                return "Invalid"
            case .disconnected:
                return "Quick Connect"
            case .connecting:
                return "Connecting"
            case .connected:
                return "Disconnect"
            case .reasserting:
                return "Reasserting"
            case .disconnecting:
                return "Disconnecting"
            @unknown default:
                return "Unknown"
        }
    }
    
    var buttonForegroundColor: Color {
        switch self {
            case .invalid:
                return .sentinelYellow
            case .disconnected:
                return .sentinelYellow
            case .connecting:
                return .sentinelBlack
            case .connected:
                return .sentinelBlack
            case .reasserting:
                return .sentinelBlack
            case .disconnecting:
                return .sentinelBlack
            @unknown default:
                return .sentinelBlack
        }
    }
    
    var buttonBackgroundColor: Color {
        switch self {
            case .invalid:
                return .sentinelBlack
            case .disconnected:
                return .sentinelBlack
            case .connecting:
                return .sentinelYellow
            case .connected:
                return .sentinelYellow
            case .reasserting:
                return .sentinelYellow
            case .disconnecting:
                return .sentinelYellow
            @unknown default:
                return .sentinelYellow
        }
    }
    
    var largeButtonBackgroundColor: Color {
        switch self {
            case .invalid:
                return .sentinelGray
            case .disconnected:
                return .sentinelGray
            case .connecting:
                return .sentinelYellow
            case .connected:
                return .sentinelYellow
            case .reasserting:
                return .sentinelYellow
            case .disconnecting:
                return .sentinelYellow
            @unknown default:
                return .sentinelYellow
        }
    }
}

struct NodeCellView_Previews: PreviewProvider {
    static var previews: some View {
        NodeList_Previews.previews
    }
}
