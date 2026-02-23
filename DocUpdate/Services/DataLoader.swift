//
//  DataLoader.swift
//  DocUpdate
//
//  Created by Mbusi Hlatshwayo on 2/22/26.
//

import Foundation

enum DataLoaderError: Error, LocalizedError {
    case fileNotFound(String)
    case parseFailure(String)

    var errorDescription: String? {
        switch self {
        case .fileNotFound(let name): return "Resource file '\(name)' not found in bundle."
        case .parseFailure(let detail): return "Failed to parse data: \(detail)"
        }
    }
}

struct DataLoader {

    // MARK: - Physicians

    static func loadPhysicians() throws -> [Physician] {
        guard let url = Bundle.main.url(forResource: "physicians", withExtension: "csv") else {
            throw DataLoaderError.fileNotFound("physicians.csv")
        }
        let raw = try String(contentsOf: url, encoding: .utf8)
        let lines = raw.components(separatedBy: "\n").dropFirst().filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }

        return try lines.map { line in
            let cols = parseCSVLine(line)
            guard cols.count >= 8,
                  let id = Int(cols[0]) else {
                throw DataLoaderError.parseFailure("Physician row: \(line)")
            }
            return Physician(
                id: id,
                npi: cols[1],
                firstName: cols[2],
                lastName: cols[3],
                specialty: cols[4],
                state: cols[5],
                consentOptIn: cols[6].lowercased() == "true",
                preferredChannel: cols[7]
            )
        }
    }

    // MARK: - Messages

    static func loadMessages() throws -> [Message] {
        guard let url = Bundle.main.url(forResource: "messages", withExtension: "csv") else {
            throw DataLoaderError.fileNotFound("messages.csv")
        }
        let raw = try String(contentsOf: url, encoding: .utf8)
        let lines = raw.components(separatedBy: "\n").dropFirst().filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate, .withTime, .withDashSeparatorInDate, .withColonSeparatorInTime]

        return try lines.compactMap { line in
            let cols = parseCSVLine(line)
            guard cols.count >= 11,
                  let msgId = Int(cols[0]),
                  let physId = Int(cols[1]) else {
                return nil
            }
            let timestamp = formatter.date(from: cols[4]) ?? Date.distantPast
            let latency = cols.count > 11 ? Double(cols[11]) : nil
            return Message(
                id: msgId,
                physicianId: physId,
                channel: cols[2],
                direction: cols[3],
                timestamp: timestamp,
                text: cols[5],
                campaignId: cols[6],
                topic: cols[7],
                complianceTag: cols[8],
                sentiment: cols[9],
                deliveryStatus: cols[10],
                responseLatencySec: latency
            )
        }
    }

    // MARK: - Compliance Policies

    static func loadCompliancePolicies() throws -> CompliancePolicyStore {
        guard let url = Bundle.main.url(forResource: "compliance_policies", withExtension: "json") else {
            throw DataLoaderError.fileNotFound("compliance_policies.json")
        }
        let data = try Data(contentsOf: url)
        do {
            return try JSONDecoder().decode(CompliancePolicyStore.self, from: data)
        } catch {
            throw DataLoaderError.parseFailure(error.localizedDescription)
        }
    }

    // MARK: - CSV Helpers

    /// Handles simple CSV lines (no embedded newlines; quoted fields with commas).
    static func parseCSVLine(_ line: String) -> [String] {
        var fields: [String] = []
        var current = ""
        var inQuotes = false

        for char in line {
            switch char {
            case "\"":
                inQuotes.toggle()
            case "," where !inQuotes:
                fields.append(current.trimmingCharacters(in: .init(charactersIn: "\r")))
                current = ""
            default:
                current.append(char)
            }
        }
        fields.append(current.trimmingCharacters(in: .init(charactersIn: "\r")))
        return fields
    }
}
