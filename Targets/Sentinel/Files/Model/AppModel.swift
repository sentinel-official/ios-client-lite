//
// Copyright (c) N/A
//

import Combine
import FoundationX
import NetworkKit
import Swallow
import SwiftUIX

final class AppModel: HTTPRepository, CancellablesHolder, ObservableObject {
    static let shared = AppModel()
    
    struct Connection: Codable {
        let connectedAt: Date
        let node: Node
        var status: NEVPNStatus
        
        init(node: Node, status: NEVPNStatus) {
            self.connectedAt = Date()
            self.node = node
            self.status = status
        }
    }
    
    public let session = HTTPSession()
    public let interface = SentinelAPI()
    
    @UserDefault.Published("connection")
    var connection: Connection?
    @UserDefault.Published("shouldAutoConnect")
    var shouldAutoConnect: Bool = false
    @UserDefault.Published("isOnboarded")
    var isOnboarded: Bool = false
    @UserDefault.Published("isDisclaimerShown") 
    var isDisclaimerShown: Bool = false

    @Resource(get: \.getNodeList) var nodes: SentinelAPI.Models.NodeList?
    
    @Published var connectionViewIsVisible: Bool = false
    @Published var isMainViewActive: Bool = false
    @Published var badNodes = Set<Node>()
    @Published var nodeTasks: [Node: _opaque_Task] = [:]
    
    var groupedNodes: [(continent: String, [Node])]? {
        guard let nodes = nodes?.list else {
            return nil
        }
        
        return Dictionary(grouping: nodes) {
            Continents.countryToContinent[$0.location?.country]
        }
        .map({ ($0.key ?? "Unknown Continent", $0.value) })
        .sorted(by: { $0.0 < $1.0 })
    }
    
    private init() {
        UINavigationBar.appearance().barTintColor = .clear
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().titleTextAttributes = [.font: UIFont(name: "Overpass-Regular", size: Font.TextStyle.body.defaultMetrics.size)!]
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        
        NEVPNManager.shared().localizedDescription = Bundle.main.infoDictionary![kCFBundleNameKey as String] as? String
        
        Continents.createCountryToContinentMap()
        
        NEVPNManager.shared()
            .loadFromPreferences()
            .receive(on: DispatchQueue.main)
            .then {
                let status = NEVPNManager.shared().connection.status
                let isNotActive = status == .disconnected || status == .invalid
                
                self.connection =  isNotActive ? nil : (try? UserDefaults.standard.decode(Connection.self, forKey: "connection"))
                
                self.$nodes.publisher.compactMap({ try? $0.get() }).first().delay(for: .seconds(1), scheduler: DispatchQueue.main).then {
                    if self.shouldAutoConnect && self.connection == nil {
                        self.connectToRandomNode()
                    }
                }
                .subscribe(in: self.cancellables)
            }
            .subscribe(in: cancellables)
        
        nodes = nil
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(AppModel.vpnStatusDidChange(_:)),
            name: NSNotification.Name.NEVPNStatusDidChange,
            object: nil
        )
        
        $nodes.publisher.sink { nodes in
            for node in (try? nodes.get().list) ?? [] {
                guard let ip = node.ip else {
                    continue
                }
                
                self.getNodeStatus((ip, 3000))
                    .successPublisher
                    .receiveOnMainQueue()
                    .sinkResult(in: self.cancellables) { status in
                        if status == .failure {
                            self.badNodes.insert(node)
                        }
                    }
            }
        }
        .store(in: cancellables)
    }
}

extension AppModel {
    @objc private func vpnStatusDidChange(_ notification: NSNotification?) {
        let status = NEVPNManager.shared().connection.status
        
        switch status {
            case .invalid: do {
                connection = nil
            }
            case .disconnected: do {
                connection = nil
                FeedbackGenerator.shared.generate(.success)
            }
            case .connecting: do {
                FeedbackGenerator.shared.generate(.light)
            }
            case .connected: do {
                FeedbackGenerator.shared.generate(.success)
            }
            case .reasserting: do {
                FeedbackGenerator.shared.generate(.light)
            }
            case .disconnecting: do {
                FeedbackGenerator.shared.generate(.light)
            }
            
            @unknown default: do {
                connection = nil
            }
        }
        
        connection?.status = status
        
        objectWillChange.send()
    }
}

extension AppModel {
    func installCertificate() {
        UIApplication.shared.open(URL(string: "https://raw.githubusercontent.com/sentinel-official/sentinel/ikev2_modifications/master-node-docker/ca.crt")!, options: [:], completionHandler: nil)
    }
}

// MARK: - Extensions -

extension AppModel {
    func disconnect() {
        NEVPNManager.shared()
            .disconnectIfNecessary(timeout: .seconds(1))
            .receiveOnMainQueue()
            .then {
                withAnimation {
                    self.connection = nil
                    self.connectionViewIsVisible = false
                }
            }
            .handleError { error in
                self.connection = nil
                self.connectionViewIsVisible = false
                
                Diagnostics.write(error)
            }
            .subscribe(in: session.cancellables)
    }
    
    func connectOrDisconnect(to node: Node) {
        session.cancellables.cancel()
        
        if connection?.node == node {
            NEVPNManager.shared()
                .disconnectIfNecessary(timeout: .seconds(1))
                .receiveOnMainQueue()
                .then {
                    self.connection = nil
                    self.connectionViewIsVisible = false
                }
                .subscribe(in: session.cancellables)
        } else {
            connect(to: node)
        }
    }
    
    private func connect(to node: Node) {
        let task = NEVPNManager.shared()
            .disconnectIfNecessary(timeout: .seconds(10))
            .then(on: DispatchQueue.main) {
                self.connection = .init(node: node, status: .connecting)
                self.connectionViewIsVisible = true
            }
            .catchAndMapTo(())
            .receiveOnMainQueue()
            .then {
                self.getServerInfo(node)
                    .successPublisher
                    .flatMap({ response in
                        self.getUserDetails((response.ip, response.port, response.token, node))
                            .successPublisher
                    })
                    .flatMap({ response in
                        self.connect(
                            host: node.ip ?? "",
                            username: response.node.vpn.username,
                            password: response.node.vpn.password
                        )
                    })
            }
            .receiveOnMainQueue()
            .handleError { error in
                self.connection = nil
                self.connectionViewIsVisible = false
                self.badNodes.insert(node)
                
                Diagnostics.write("Connecting to \(node.name) failed!")
                Diagnostics.write(error)
                
                Alert(
                    title: "Something went wrong!",
                    message: "Please retry the operation.",
                    dismissButtonTitle: "Dismiss"
                )
                .present()
            }
            .handleCancel {
                DispatchQueue.main.async {
                    guard let connection = self.connection, connection.status.isTransient else {
                        return
                    }
                    
                    NEVPNManager.shared().connection.stopVPNTunnel()
                    
                    self.connection?.status = .disconnecting
                    self.connectionViewIsVisible = false
                }
            }
            .convertToTask()
        
        nodeTasks[node] = task
        
        task.onResult { [weak self] _ in
            self?.objectWillChange.send()
        }
        
        task.subscribe(in: session.cancellables)
    }
    
    private func connect(host: String, username: String, password: String) -> some Publisher {
        let config = Configuration(
            server: host,
            account: username,
            password: password
        )
        
        return NEVPNManager.shared().connect(withConfiguration: config)
    }
    
    func nodeList(for continent: String) -> [Node]? {
        groupedNodes?.first(where: { $0.continent == continent }).map({ $0.1 })
    }
    
    func connectToRandomNode(in country: String? = nil) {
        guard let nodes = (country.flatMap(nodeList(for:)) ?? nodes?.list)?.filter({ !badNodes.contains($0) }) else {
            return
        }
        
        session.cancellables.cancel()
        
        if connection != nil {
            NEVPNManager.shared()
                .disconnectIfNecessary()
                .timeout(.seconds(2), scheduler: RunLoop.main)
                .receiveOnMainQueue()
                .then {
                    self.connection = nil
                }
                .subscribe(in: session.cancellables)
        } else {
            connect(to: nodes[Int.random(in: 0..<nodes.count)])
        }
    }
}

extension NEVPNManager {
    func connect(withConfiguration configuration: Configuration) -> some Publisher {
        let protocolConfiguration = NEVPNProtocolIKEv2()
        
        protocolConfiguration.authenticationMethod = NEVPNIKEAuthenticationMethod.none
        protocolConfiguration.serverAddress = configuration.server
        protocolConfiguration.disconnectOnSleep = false
        protocolConfiguration.deadPeerDetectionRate = NEVPNIKEv2DeadPeerDetectionRate.medium
        protocolConfiguration.username = configuration.account
        protocolConfiguration.passwordReference = configuration.getPasswordRef()
        protocolConfiguration.sharedSecretReference = nil
        protocolConfiguration.disableMOBIKE = false
        protocolConfiguration.disableRedirect = false
        protocolConfiguration.enableRevocationCheck = false
        protocolConfiguration.enablePFS = false
        protocolConfiguration.useExtendedAuthentication = true
        protocolConfiguration.useConfigurationAttributeInternalIPSubnet = false
        
        protocolConfiguration.ikeSecurityAssociationParameters.encryptionAlgorithm = .algorithmAES256
        protocolConfiguration.ikeSecurityAssociationParameters.integrityAlgorithm = .SHA512
        protocolConfiguration.ikeSecurityAssociationParameters.diffieHellmanGroup = .group20
        
        protocolConfiguration.childSecurityAssociationParameters.encryptionAlgorithm = .algorithmAES256
        protocolConfiguration.childSecurityAssociationParameters.integrityAlgorithm = .SHA512
        protocolConfiguration.childSecurityAssociationParameters.diffieHellmanGroup = .group20
        
        protocolConfiguration.remoteIdentifier = configuration.server
        protocolConfiguration.localIdentifier = configuration.account
        
        self.protocolConfiguration = nil
        
        return loadFromPreferences().catchAndMapTo(()).then {
            self.protocolConfiguration = protocolConfiguration
            self.isEnabled = true
        }
        .then(deferred: { self.saveToPreferences() })
        .then(deferred: { self.loadFromPreferences() })
        .then(deferred: { self.connection.start() })
    }
}
