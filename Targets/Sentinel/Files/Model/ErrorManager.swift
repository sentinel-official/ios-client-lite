//
// Copyright (c) N/A
//

import API
import NetworkKit
import Swallow

class ErrorManager {
    static func showError(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
        
        let parent = UIApplication.shared.firstKeyWindow?.rootViewController?.topmostViewController
        
        parent?.present(alert, animated: true, completion: nil)
    }
}
