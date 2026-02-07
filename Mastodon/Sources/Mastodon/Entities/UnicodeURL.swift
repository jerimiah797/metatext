// Copyright © 2021 Metabolist. All rights reserved.

import Foundation
import os.log

private let logger = Logger(subsystem: "org.arctian.metatext", category: "UnicodeURL")

public struct UnicodeURL: Hashable {
    public let raw: String
    public let url: URL
}

extension UnicodeURL: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        let rawString = try container.decode(String.self)
        raw = rawString

        if let url = URL(unicodeString: rawString) {
            self.url = url
        } else {
            // Avoid failing the entire response decode due to one unparseable URL
            let path = decoder.codingPath.map(\.stringValue).joined(separator: ".")
            if rawString.isEmpty {
                logger.debug("Empty URL string at: \(path, privacy: .public)")
            } else {
                logger.debug("Failed to parse URL at \(path, privacy: .public): \(rawString, privacy: .public)")
            }
            self.url = URL(string: "about:invalid")!
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        try container.encode(raw)
    }
}
