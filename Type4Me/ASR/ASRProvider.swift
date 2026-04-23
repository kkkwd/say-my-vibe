import Foundation

// MARK: - Provider Enum

enum ASRProvider: String, CaseIterable, Codable, Sendable {
    case volcano
    case soniox
    case bailian

    var displayName: String {
        switch self {
        case .volcano:  return L("火山引擎 (Doubao)", "Volcano (Doubao)")
        case .soniox:   return "Soniox"
        case .bailian:  return L("阿里云百炼", "Alibaba Cloud Bailian")
        }
    }

    /// Whether this provider runs entirely on-device (no network required).
    var isLocal: Bool { false }
}

// MARK: - Credential Field Descriptor

struct FieldOption: Sendable {
    let value: String
    let label: String
}

struct CredentialField: Sendable, Identifiable {
    let key: String
    let label: String
    let placeholder: String
    let isSecure: Bool
    let isOptional: Bool
    let defaultValue: String
    /// When non-empty, the UI renders a Picker instead of a TextField.
    let options: [FieldOption]
    /// When true (and options is non-empty), the picker includes a "Custom" entry
    /// that reveals a text field for free-form input.
    let allowCustomInput: Bool

    /// Sentinel value used in the picker to represent "custom input" mode.
    static let customValue = "_custom"

    var id: String { key }

    init(key: String, label: String, placeholder: String, isSecure: Bool, isOptional: Bool, defaultValue: String, options: [FieldOption] = [], allowCustomInput: Bool = false) {
        self.key = key
        self.label = label
        self.placeholder = placeholder
        self.isSecure = isSecure
        self.isOptional = isOptional
        self.defaultValue = defaultValue
        self.options = options
        self.allowCustomInput = allowCustomInput
    }
}

// MARK: - Provider Config Protocol

protocol ASRProviderConfig: Sendable {
    static var provider: ASRProvider { get }
    static var displayName: String { get }
    static var credentialFields: [CredentialField] { get }

    init?(credentials: [String: String])
    func toCredentials() -> [String: String]
    var isValid: Bool { get }
}
