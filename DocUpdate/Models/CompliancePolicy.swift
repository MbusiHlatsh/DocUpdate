//
//  CompliancePolicy.swift
//  DocUpdate
//
//  Created by Mbusi Hlatshwayo on 2/22/26.
//

import Foundation

struct CompliancePolicyStore: Decodable {
    let version: String
    let updated: String
    let rules: [ComplianceRule]
}

struct ComplianceRule: Decodable, Identifiable {
    let id: String
    let name: String
    let keywordsAny: [String]
    let action: String?
    let requiresAppend: String?

    enum CodingKeys: String, CodingKey {
        case id, name, action
        case keywordsAny = "keywords_any"
        case requiresAppend = "requires_append"
    }
}

struct ComplianceResult: Identifiable {
    let id = UUID()
    let rule: ComplianceRule
    let triggeredKeyword: String

    var explanation: String {
        var parts: [String] = []
        parts.append("Rule \(rule.id) — \"\(rule.name)\" triggered by keyword: \"\(triggeredKeyword)\".")
        if let action = rule.action {
            parts.append("Action: \(action.replacingOccurrences(of: "_", with: " ").capitalized).")
        }
        if let append = rule.requiresAppend {
            parts.append("Required append: \"\(append)\"")
        }
        return parts.joined(separator: " ")
    }
}
