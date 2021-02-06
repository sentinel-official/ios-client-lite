//
// Copyright (c) N/A
//

import API
import NetworkKit
import Swallow

public struct SentinelAPI: RESTfulHTTPInterface {
    public struct Models { }
    
    public var host = URL(string: "https://api.sentinelgroup.io")!
    
    public var baseURL: URL {
        host.appendingPathComponent("client")
    }
    
    public var id: some Hashable {
        ObjectIdentifier(Self.self)
    }
    
    @Path("/vpn/ikev2-list")
    @GET(Models.NodeList.self)
    var getNodeList = Endpoint()
    
    struct ConnectToNodeResponse: Codable {
        let token: String
        let ip: String
        let port: Int
    }
    
    @Path("/vpn")
    @POST
    @Body(json: { node in
        return [
            "device_id": UIDevice.current.sentinelID as Any,
            "vpn_addr": node.account_addr as Any
        ]
    })
    var getServerInfo = Endpoint<Node, ConnectToNodeResponse, Void>()
    
    struct GetUserDetailsResponse: Codable {
        struct Node: Codable {
            struct VPN: Codable {
                let username: String
                let password: String
            }
            
            let vpn: VPN
            let success: Bool?
            let message: String?
        }
        
        let node: Node
    }
    
    @AbsolutePath(fromContext: { "http://\($0.input.ip):\($0.input.port)/vpn" })
    @POST
    @Body(json: { input in
        return [
            "account_addr": UIDevice.current.sentinelID as Any,
            "vpn_addr": input.node.account_addr as Any,
            "token": input.token
        ]
    })
    var getUserDetails = Endpoint<(ip: String, port: Int, token: String, node: Node), GetUserDetailsResponse, Void>()
    
    @AbsolutePath(fromContext: { "http://\($0.input.ip):\($0.input.port)" })
    @GET
    var getNodeStatus = Endpoint<(ip: String, port: Int), HTTPResponseStatusCode, Void>()
}

extension SentinelAPI {
    final class Endpoint<Input, Output, Options>: BaseHTTPEndpoint<SentinelAPI, Input, Output, Options> {
        override func buildRequestBase(from input: Input, context: BuildRequestContext) throws -> HTTPRequest {
            try super.buildRequestBase(from: input, context: context)
                .header(.accept(.json))
                .header(.contentType(.json))
        }
        
        override func decodeOutputBase(from response: Request.Response, context: DecodeOutputContext) throws -> Output {
            try response.validate()
            
            return try response.decode(Output.self, using: JSONDecoder())
        }
    }
}

fileprivate extension UIDevice {
    var sentinelID: String? {
        UIDevice.current.identifierForVendor?.uuidString.replacingOccurrences(of: "-", with: "")
    }
}
