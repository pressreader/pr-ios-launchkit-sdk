import SwiftUI
import PRAppLaunchKit
import CryptoKit

struct GiftRegView: View {
    @Binding var scheme: Scheme
    @State private var siteID: Int? = nil
    @State private var secret = ""
    @State private var giftID = UUID().uuidString
    @State private var duration = 1
    @State private var currentToken = ""
    @Binding var isInstalled: Bool
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Form {
            Section() {
                Picker("scheme", selection: $scheme) {
                    ForEach(Scheme.allCases, id: \.self) { Text($0.rawValue) }
                }
            }

            Section("Gift Registration") {
                TextField("Site ID", value: $siteID, formatter: NumberFormatter())
                    .keyboardType(.numberPad)

                SecureField("Secret", text: $secret).textInputAutocapitalization(.never)
                
                TextField("Gift ID", text: $giftID).minimumScaleFactor(0.5).textInputAutocapitalization(.never)
                
                Stepper("Duration: *^[\(duration) hour](inflect: true)*",
                        value: $duration, in: 1...24)
            }
            
            Section("Calculated Token") {
                Text(currentToken)
                    .font(.caption)
                    .textSelection(.enabled)
            }

            Section {
                HStack {
                    Spacer()
                    Button(isInstalled ? "Open" : "Install") {
                        launchGiftAccess()
                    }
                    .disabled(secret.isEmpty || siteID == 0 || giftID.isEmpty)
                    Spacer()
                }
            }
        }
        .navigationTitle("Gift Registration")
        .onChange(of: siteID) { updateToken() }
        .onChange(of: secret) { updateToken() }
        .onChange(of: giftID) { updateToken() }
        .onChange(of: duration) { updateToken() }
    }
    
    private func updateToken() {
        guard let siteID, !secret.isEmpty && !giftID.isEmpty else {
            currentToken = ""
            return
        }
        
        currentToken = giftJwt(withId: giftID, siteID: siteID, duration: duration, signingSecret: secret)
    }
    
    private func launchGiftAccess() {
        PRAppLaunchKit.defaultAppLaunch().launchApp(withCommand: "register-gifted-access", urlParameters: ["jwt": currentToken])
    }
    
    // JWT Helper methods
    private func giftJwt(withId issID: String, siteID siteid: Int, duration accessH: Int, signingSecret secret: String) -> String {
        let now = lround(Date().timeIntervalSince1970)
        
        let payload = JWTPayload(
            jti: issID,
            iat: now,
            siteID: siteid,
            giftPeriod: JWTPayload.GiftPeriod(hours: accessH)
        )
        
        let b64Payload = (try! JSONEncoder().encode(payload)).urlSafeBase64EncodedString()
        let b64Header = (try! JSONEncoder().encode(JWTHeader())).urlSafeBase64EncodedString()
        let signingInput = [b64Header, b64Payload].joined(separator: ".")
        let privateKey = SymmetricKey(data: Data(secret.utf8))
        let signature = Data(HMAC<SHA256>.authenticationCode(for: Data(signingInput.utf8), using: privateKey)).urlSafeBase64EncodedString()
        
        return [signingInput, signature].joined(separator: ".")
    }
}

// JWT Models - Keep the same as original
private struct JWTHeader: Encodable {
    let alg = "HS256"
    let typ = "JWT"
}

private struct JWTPayload: Encodable {
    let iss: String?
    let jti: String
    let iat: Int
    let nbf: Int?
    let exp: Int?
    let siteID: Int
    let giftPeriod: GiftPeriod
    let deepLink: String?
    
    struct GiftPeriod: Encodable {
        let hours: Int
        
        enum CodingKeys: String, CodingKey {
            case hours = "num-hours"
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case iss, jti, iat, nbf, exp
        case siteID = "site-id"
        case giftPeriod = "gift-period"
        case deepLink = "deep-link"
    }
    
    init(iss: String? = nil, jti: String, iat: Int, nbf: Int? = nil, exp: Int? = nil, siteID: Int, giftPeriod: GiftPeriod, deepLink: String? = nil) {
        self.iss = iss
        self.jti = jti
        self.iat = iat
        self.nbf = nbf
        self.exp = exp
        self.siteID = siteID
        self.giftPeriod = giftPeriod
        self.deepLink = deepLink
    }
}

extension Data {
    func urlSafeBase64EncodedString() -> String {
        return base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}

#Preview {
    @Previewable @State var isInstalled: Bool = PRAppLaunchKit.defaultAppLaunch().scheme == "pressreader"
    @Previewable @State var scheme = Scheme(rawValue: PRAppLaunchKit.defaultAppLaunch().scheme) ?? .pressreader
    GiftRegView(scheme: $scheme, isInstalled: $isInstalled).onChange(of: scheme) {
        isInstalled = scheme == .pressreader
    }
}
