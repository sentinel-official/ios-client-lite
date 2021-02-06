//
// Copyright (c) N/A
//

import NetworkExtension
import NetworkKit
import SwiftUIX

struct ContinentList: View {
    @EnvironmentObject var appModel: AppModel
    
    @State var searchIsActive: Bool = false
    @State var searchText: String = ""
    
    var body: some View {
        XStack {
            VStack {
                SearchBar("Search", text: $searchText, isEditing: $searchIsActive)
                    .showsCancelButton(searchIsActive)
                    .padding(.horizontal, .small)
                
                ScrollView {
                    VStack(spacing: 16) {
                        if !searchIsActive {
                            if let node = appModel.connection?.node {
                                NodeCellView(model: node)
                                    .transition(AnyTransition.move(edge: .top).combined(with: .opacity))
                            }
                            
                            if appModel.connection?.node == nil {
                                NodeConnectButton(node: nil, isCompact: false)
                                    .transition(AnyTransition.move(edge: .top).combined(with: .opacity))
                            }
                        }
                        
                        ForEach((appModel.groupedNodes ?? []).filter({ countryAndInfo in
                            if searchText == "" {
                                return true
                            } else {
                                return countryAndInfo.0.lowercased().contains(searchText.lowercased())
                            }
                        }), id: \.0) { (countryAndInfo) in
                            RowView(countryAndInfo: countryAndInfo)
                                .contextMenu {
                                    Button((appModel.connection?.status ?? .disconnected).largeButtonTitle, systemImage: .boltFill) {
                                        appModel.connectToRandomNode(in: countryAndInfo.continent)
                                    }
                                }
                        }
                    }
                    .padding([.horizontal, .top])
                    .animation(.default)
                }
            }
        }
    }
}

extension ContinentList {
    struct RowView: View {
        @EnvironmentObject var appModel: AppModel
        
        let countryAndInfo: (continent: String, [Node])
        
        var body: some View {
            NavigationLink(
                destination: NodeList(
                    country: countryAndInfo.0,
                    nodeList: countryAndInfo.1
                )
                .environmentObject(self.appModel)
            ) {
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(countryAndInfo.0)
                            .font(.headline)
                            .foregroundColor(Color.primary)
                            .fixedSize()
                        
                        Divider()
                            .padding(.trailing)
                            .padding(.trailing)
                        
                        Text(countryAndInfo.1.count.nodeCountDescription)
                            .font(.footnote)
                            .foregroundColor(Color.secondary)
                            .fixedSize()
                    }
                    
                    Spacer()
                }
                .padding()
                .background(Color.black.opacity(0.2))
                .cornerRadius(13, style: .continuous)
            }
        }
    }
}

extension Int {
    var nodeCountDescription: String {
        if self == 0 {
            return "No nodes available"
        } else if self == 1 {
            return "1 available node"
        } else {
            return String(self) + " available nodes"
        }
    }
}

struct ContinentList_Previews: PreviewProvider {
    static var previews: some View {
        ContinentList()
            .environmentObject(AppModel.shared)
    }
}
