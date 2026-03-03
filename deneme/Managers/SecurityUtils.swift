

import Foundation
import UIKit
import MachO

final class SecurityUtils {
    
    private init() {}
    
    // MARK: - Jailbreak Detection
    
   
    static func isJailbroken() -> Bool {
        #if targetEnvironment(simulator)
       
        return false
        #else
        
    
        let suspiciousPaths = [
            "/Applications/Cydia.app",
            "/Applications/Sileo.app",
            "/Applications/Zebra.app",
            "/Applications/Installer.app",
            "/Library/MobileSubstrate/MobileSubstrate.dylib",
            "/bin/bash",
            "/usr/sbin/sshd",
            "/etc/apt",
            "/private/var/lib/apt/",
            "/usr/bin/ssh",
            "/var/cache/apt",
            "/var/lib/cydia",
            "/var/tmp/cydia.log",
            "/private/var/stash"
        ]
        
        for path in suspiciousPaths {
            if FileManager.default.fileExists(atPath: path) {
                print("⚠️ Security: Suspicious path found: \(path)")
                return true
            }
        }
        
    
        let writablePaths = [
            "/private/jailbreak.txt",
            "/private/var/mobile/Library/Preferences/com.saurik.Cydia.plist"
        ]
        
        for path in writablePaths {
            if canWriteToPath(path) {
                print("⚠️ Security: Writable system path detected: \(path)")
                return true
            }
        }
        
     
        if let url = URL(string: "cydia://package/com.example.package") {
            if UIApplication.shared.canOpenURL(url) {
             
                return true
            }
        }
        
      
        if isSandboxCompromised() {
           
            return true
        }
        
        return false
        #endif
    }
    
   
    private static func canWriteToPath(_ path: String) -> Bool {
        let testString = "jailbreak_test"
        do {
            try testString.write(toFile: path, atomically: true, encoding: .utf8)
          
            try? FileManager.default.removeItem(atPath: path)
            return true
        } catch {
            return false
        }
    }
    
  
    private static func isSandboxCompromised() -> Bool {
      
        let pointerToFork = UnsafeMutableRawPointer(bitPattern: -2)
        let forkPtr = dlsym(pointerToFork, "fork")
        if forkPtr != nil {
            
        }
        
    
        let suspiciousDylibs = [
            "SubstrateLoader",
            "MobileSubstrate",
            "TweakInject",
            "libhooker",
            "substitute"
        ]
        
        let imageCount = _dyld_image_count()
        for i in 0..<imageCount {
            if let imageName = _dyld_get_image_name(i) {
                let name = String(cString: imageName)
                for dylib in suspiciousDylibs {
                    if name.lowercased().contains(dylib.lowercased()) {
                     
                        return true
                    }
                }
            }
        }
        
        return false
    }
    
   
    static func deobfuscateAPIKey(parts: [String]) -> String {
       
        let combined = parts.joined()
        guard let data = Data(base64Encoded: combined),
              let decoded = String(data: data, encoding: .utf8) else {
            return ""
        }
        return decoded
    }
    
  
    static func obfuscateAPIKey(_ key: String) -> [String] {
        guard let data = key.data(using: .utf8) else { return [] }
        let base64 = data.base64EncodedString()
        
       
        var parts: [String] = []
        let chunkSize = 8
        var index = base64.startIndex
        
        while index < base64.endIndex {
            let endIndex = base64.index(index, offsetBy: chunkSize, limitedBy: base64.endIndex) ?? base64.endIndex
            parts.append(String(base64[index..<endIndex]))
            index = endIndex
        }
        
        return parts
    }
}
