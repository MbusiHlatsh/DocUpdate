//
//  MessageRowView.swift
//  DocUpdate
//
//  Created by Mbusi Hlatshwayo on 2/22/26.
//

import SwiftUI

struct MessageRowView: View {
    let message: Message
    let physicianName: String

    private var sentimentColor: Color {
        switch message.sentiment.lowercased() {
        case "positive": return .green
        case "negative": return .red
        default: return .secondary
        }
    }

    private var formattedTimestamp: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: message.timestamp)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(message.topic.replacingOccurrences(of: "_", with: " ").capitalized)
                    .font(.headline)
                Spacer()
                Text(message.sentiment.capitalized)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(sentimentColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(sentimentColor.opacity(0.12), in: Capsule())
            }

            Text(physicianName)
                .font(.subheadline)
                .foregroundStyle(.primary)

            Text(formattedTimestamp)
                .font(.caption)
                .foregroundStyle(.secondary)

            if message.complianceTag != "allowed" {
                complianceTagBadge
            }
        }
        .padding(.vertical, 4)
    }

    @ViewBuilder
    private var complianceTagBadge: some View {
        let (label, color) = tagStyle(for: message.complianceTag)
        Text(label)
            .font(.caption2)
            .fontWeight(.medium)
            .foregroundStyle(color)
            .padding(.horizontal, 7)
            .padding(.vertical, 2)
            .background(color.opacity(0.12), in: Capsule())
    }

    private func tagStyle(for tag: String) -> (String, Color) {
        switch tag.lowercased() {
        case "needs_review": return ("Needs Review", .orange)
        case "disallowed": return ("Disallowed", .red)
        default: return (tag.replacingOccurrences(of: "_", with: " ").capitalized, .secondary)
        }
    }
}
