//
// Copyright (c) N/A
//

import Foundation
import Swift
import SwiftUIX

public struct Diagnostics {
    struct Unit: Codable, Hashable {
        struct SourceCodeLocation: Codable, Hashable {
            let file: String
            let line: UInt
        }
        
        let description: String?
        let location: SourceCodeLocation?
        let timestamp: String?
    }
    
    static var isLogLoaded: Bool = false
    static var log: [Unit] = []
    
    public static func write(
        _ description: String,
        file: String = #file,
        line: UInt = #line
    ) {
        if Thread.isMainThread {
            self._write(description, file: file, line: line)
        } else {
            DispatchQueue.main.async {
                self._write(description, file: file, line: line)
            }
        }
    }
    
    private static func _write(
        _ description: String,
        file: String = #file,
        line: UInt = #line
    ) {
        if !isLogLoaded {
            do {
                try readFromDisk()
            } catch {
                assertionFailure()
                
                log = []
            }
        }
        
        let formatter = ISO8601DateFormatter()
        
        formatter.formatOptions = [.withFractionalSeconds, .withInternetDateTime]
        formatter.timeZone = TimeZone(secondsFromGMT: 0)!
        
        do {
            let unit = Unit(
                description: description,
                location: .init(file: file, line: line),
                timestamp: formatter.string(from: Date())
            )
            
            log.append(unit)
            
            try writeToDisk()
        } catch {
            assertionFailure()
        }
    }
    
    public static func write(_ error: Error, file: String = #file, line: UInt = #line) {
        write(error.localizedDescription, file: file, line: line)
    }
}

extension Diagnostics {
    static func diskLocation() throws -> URL {
        try FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false
        )
        .appendingPathComponent("diagnostics.json")
    }
    
    static func readFromDisk() throws {
        let location = try diskLocation()
        
        if !FileManager.default.fileExists(atPath: location.path) {
            FileManager.default.createFile(
                atPath: location.path,
                contents: try JSONEncoder().encode(Array<Unit>()),
                attributes: nil
            )
        }
        
        log = try JSONDecoder().decode([Unit].self, from: try Data(contentsOf: diskLocation()))
        
        isLogLoaded = true
    }
    
    static func writeToDisk() throws {
        /// Cut log to half if `1000` items are logged.
        if log.count >= 1000 {
            log = log.suffix(500)
        }
        
        let encoder = JSONEncoder()
        
        encoder.outputFormatting = .prettyPrinted
        
        try encoder.encode(log).write(to: diskLocation())
    }
}

extension Diagnostics {
    public static func generateSupportMailAttachment() throws -> MailComposer.Attachment {
        let encoder = JSONEncoder()
        
        encoder.outputFormatting = .prettyPrinted
        
        return MailComposer.Attachment(
            data: try encoder.encode(log),
            mimeType: "application/json",
            fileName: "diagnostics.json"
        )
    }
}
