//
// Copyright (c) N/A
//

import Foundation

class Configuration {
    public let server: String
    public let account: String
    public let password: String
    
    init(server: String, account: String, password: String) {
        self.server = server
        self.account = account
        self.password = password
    }
    
    func getPasswordRef() -> Data? {
        KeychainWrapper.standard.set(password, forKey: "KEYCHAIN_PASSWORD_KEY")
        return KeychainWrapper.standard.dataRef(forKey: "KEYCHAIN_PASSWORD_KEY")
    }
}
