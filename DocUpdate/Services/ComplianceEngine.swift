//
//  ComplianceEngine.swift
//  DocUpdate
//
//  Created by Mbusi Hlatshwayo on 2/22/26.
//

import Foundation

struct ComplianceEngine {

    let rules: [ComplianceRule]

    /// Runs all compliance rules against the given message text.
    /// Returns one result per triggered rule (a message may trigger multiple rules).
    func check(message: Message) -> [ComplianceResult] {
        let lowercasedText = message.text.lowercased()
        var results: [ComplianceResult] = []

        for rule in rules {
            for keyword in rule.keywordsAny {
                if lowercasedText.contains(keyword.lowercased()) {
                    results.append(ComplianceResult(rule: rule, triggeredKeyword: keyword))
                    break // one result per rule; move to next rule
                }
            }
        }

        return results
    }
}
