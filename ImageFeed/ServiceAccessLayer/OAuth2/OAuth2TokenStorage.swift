import Foundation
import SwiftKeychainWrapper

// MARK: - OAuth2TokenStorage

final class OAuth2TokenStorage {
    
    // MARK: - Singleton
    static let shared = OAuth2TokenStorage()
    
    // MARK: - Private Properties
    private let tokenKey = "token"
    
    // MARK: - Init
    private init() {}
    
    // MARK: - Public Properties
    
    var token: String? {
        get {
            KeychainWrapper.standard.string(forKey: tokenKey)
        }
        set {
            if let token = newValue {
                KeychainWrapper.standard.set(token, forKey: tokenKey)
            } else {
                KeychainWrapper.standard.removeObject(forKey: tokenKey)
            }
        }
    }
}
