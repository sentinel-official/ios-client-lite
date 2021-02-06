//
// Copyright (c) N/A
//

import MessageUI
import SwiftUIX

struct SupportInformationMailComposer: View {
    @Environment(\.presentationMode) var presentationMode
    
    var node: Node?
    
    var body: some View {
        guard MFMailComposeViewController.canSendMail() else {
            return VStack {
                Text("Oops!")
                    .bold()
                    .font(.title)
                    .foregroundColor(.primary)
                    .fixedSize()
                    .padding(.bottom)
                
                Text("You don't have a configured mail account!")
                    .font(.callout)
                    .foregroundColor(.secondary)
                
                Button("Dismiss") {
                    self.presentationMode.wrappedValue.dismiss()
                }
                .padding(.top)
            }
            .eraseToAnyView()
        }
        
        do {
            return MailComposer(onCompletion: { result, error in
                switch result {
                    case .cancelled:
                        self.presentationMode.dismiss()
                    case .saved:
                        self.presentationMode.dismiss()
                    case .sent:
                        self.presentationMode.dismiss()
                    case .failed:
                        self.presentationMode.dismiss()
                    @unknown default:
                        break
                }
            })
            .toRecipients(["ios.support@sentinel.co"])
            .subject("Sentinel troubleshooting info")
            .attachments(try self.generateAttachments())
            .eraseToAnyView()
        } catch {
            return VStack {
                Text("Oops!")
                    .bold()
                    .font(.title)
                    .foregroundColor(.primary)
                    .fixedSize()
                    .padding(.bottom)
                
                Text("An error occured while generating the mail.")
                    .font(.callout)
                    .foregroundColor(.secondary)
                
                Button("Dismiss") {
                    self.presentationMode.wrappedValue.dismiss()
                }
                .padding(.top)
            }
            .eraseToAnyView()
        }
    }
    
    private func generateAttachments() throws -> [MailComposer.Attachment] {
        struct UserInformation: Codable {
            let deviceModelIdentifier: String?
            let systemVersion: String?
            let bundleVersion: String?
            let build: String?
            
            init() {
                deviceModelIdentifier = UIDevice.current.modelIdentifier
                systemVersion = UIDevice.current.systemVersion
                bundleVersion = Bundle.main.releaseVersionNumber
                build = Bundle.main.buildVersionNumber
            }
        }
        
        let appUserID = MailComposer.Attachment(
            data: try JSONEncoder().encode(UserInformation()),
            mimeType: "application/json",
            fileName: "user-information.json"
        )
        
        let diagnostics = try Diagnostics.generateSupportMailAttachment()
        
        if let node = node {
            let node = MailComposer.Attachment(
                data: try JSONEncoder().encode(node),
                mimeType: "application/json",
                fileName: "node.json"
            )
            return [appUserID, diagnostics, node]
            
        } else {
            return [appUserID, diagnostics]
        }
    }
}

// MARK: - Helpers -

fileprivate extension Bundle {
    var releaseVersionNumber: String? {
        infoDictionary?["CFBundleShortVersionString"] as? String
    }
    
    var buildVersionNumber: String? {
        infoDictionary?["CFBundleVersion"] as? String
    }
    
    var versionDescription: String {
        var version = "1.000"
        var build = "001"
        
        version = object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? version
        build = object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? build
        
        return version + " (" + build + ")"
    }
}

fileprivate extension UIDevice {
    var modelIdentifier: String? {
        if let result = ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] {
            return result
        }
        
        var info = utsname()
        
        uname(&info)
        
        return String(
            bytes: Data(bytes: &info.machine, count: Int(_SYS_NAMELEN)),
            encoding: .ascii
        )?
        .trimmingCharacters(in: .controlCharacters)
    }
}
