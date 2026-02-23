//
//  ComplianceResultView.swift
//  DocUpdate
//
//  Created by Mbusi Hlatshwayo on 2/22/26.
//

import SwiftUI

struct ComplianceResultView: View {
    let results: [ComplianceResult]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if results.isEmpty {
                HStack(spacing: 10) {
                    Image(systemName: "checkmark.shield.fill")
                        .foregroundStyle(.green)
                        .font(.title2)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("No Issues Found")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        Text("This message passed all compliance rules.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.green.opacity(0.08), in: RoundedRectangle(cornerRadius: 10))
            } else {
                ForEach(results) { result in
                    ComplianceRuleCard(result: result)
                }
            }
        }
    }
}

private struct ComplianceRuleCard: View {
    let result: ComplianceResult

    private var actionColor: Color {
        switch result.rule.action?.lowercased() {
        case "reject": return .red
        case "flag": return .orange
        case "route_to_rep": return .blue
        default: return .yellow
        }
    }

    private var actionIcon: String {
        switch result.rule.action?.lowercased() {
        case "reject": return "xmark.shield.fill"
        case "flag": return "flag.fill"
        case "route_to_rep": return "person.fill.questionmark"
        default: return "exclamationmark.triangle.fill"
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: actionIcon)
                    .foregroundStyle(actionColor)
                    .font(.title3)
                VStack(alignment: .leading, spacing: 1) {
                    Text(result.rule.name)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text("Rule \(result.rule.id)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                if let action = result.rule.action {
                    Text(action.replacingOccurrences(of: "_", with: " ").capitalized)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(actionColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(actionColor.opacity(0.12), in: Capsule())
                }
            }

            Divider()

            Label {
                Text("Triggered by keyword: \"\(result.triggeredKeyword)\"")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } icon: {
                Image(systemName: "magnifyingglass")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if let append = result.rule.requiresAppend {
                Label {
                    Text("Required append: \"\(append)\"")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .italic()
                } icon: {
                    Image(systemName: "text.append")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .background(actionColor.opacity(0.06), in: RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(actionColor.opacity(0.25), lineWidth: 1)
        )
    }
}
