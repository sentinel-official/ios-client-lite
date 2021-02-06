//
// Copyright (c) N/A
//

import NetworkExtension
import NetworkKit
import SwiftUIX

struct NodeList: View {
    @EnvironmentObject var appModel: AppModel
    
    let country: String
    let nodeList: [Node]
    
    var body: some View {
        PresentationView {
            ScrollView {
                VStack {
                    NodeConnectButton(
                        node: nil,
                        country: country,
                        isCompact: false
                    )
                    .padding()
                    
                    ForEach(nodeList, id: \.hashValue) { node in
                        NodeCellView(model: node)
                            .padding([.horizontal, .bottom])
                    }
                }
                .padding(.top)
            }
            .navigationBarTitle(country)
            .navigationBarItems(
                trailing: WithInlineState(initialValue: false) { isPresenting in
                    Button {
                        isPresenting.wrappedValue = true
                    } label: {
                        Image(systemName: .questionmarkCircleFill)
                            .imageScale(.large)
                            .padding(.top, .small)
                    }
                    .sheet(isPresented: isPresenting) {
                        DisclaimerView()
                            .environmentObject(appModel)
                    }
                    .font(.footnote)
                    .foregroundColor(.secondary)
                }
                .padding(.bottom, .small)
            )
            .clipped()
        }
        .backgroundFill(BackgroundGradient())
    }
    
    func connectToRandomNode() {
        appModel.connectOrDisconnect(to: nodeList[Int.random(in: 0..<nodeList.count)])
    }
}

struct NodeList_Previews: PreviewProvider {
    static var appModel: AppModel = .shared
    
    static var previews: some View {
        NavigationView {
            NodeList(
                country: appModel.groupedNodes?[0].0 ?? "Test",
                nodeList: appModel.groupedNodes?[0].1 ?? []
            )
            .environmentObject(appModel)
        }
    }
}
