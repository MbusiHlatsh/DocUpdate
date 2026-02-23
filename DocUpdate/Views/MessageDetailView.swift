//
//  MessageDetailView.swift
//  DocUpdate
//
//  Created by Mbusi Hlatshwayo on 2/22/26.
//

import SwiftUI

struct MessageDetailView: View {
    @State var viewModel: MessageDetailViewModel

    private var formattedTimestamp: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter.string(from: viewModel.message.timestamp)
    }

    private var sentimentColor: Color {
        switch viewModel.message.sentiment.lowercased() {
        case "positive": return .green
        case "negative": return .red
        default: return .secondary
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                headerSection
                messageTextSection
                metadataSection
                complianceSection
            }
            .padding()
        }
        .navigationTitle("Message Detail")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Sections

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(viewModel.message.topic.replacingOccurrences(of: "_", with: " ").capitalized)
                .font(.title2)
                .fontWeight(.bold)

            if let physician = viewModel.physician {
                HStack(spacing: 6) {
                    Image(systemName: "stethoscope")
                        .foregroundStyle(.secondary)
                        .font(.subheadline)
                    Text(physician.fullName)
                        .font(.subheadline)
                    Text("·")
                        .foregroundStyle(.secondary)
                    Text(physician.specialty)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            Text(formattedTimestamp)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var messageTextSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Message", systemImage: "text.bubble")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .textCase(.uppercase)

            Text(viewModel.message.text)
                .font(.body)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.secondary.opacity(0.08), in: RoundedRectangle(cornerRadius: 10))
        }
    }

    private var metadataSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Details", systemImage: "info.circle")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .textCase(.uppercase)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                MetadataCell(label: "Sentiment", value: viewModel.message.sentiment.capitalized, valueColor: sentimentColor)
                MetadataCell(label: "Channel", value: viewModel.message.channel.capitalized)
                MetadataCell(label: "Direction", value: viewModel.message.direction.capitalized)
                MetadataCell(label: "Delivery", value: viewModel.message.deliveryStatus.capitalized)
                MetadataCell(label: "Campaign", value: viewModel.message.campaignId)
                MetadataCell(label: "Existing Tag", value: viewModel.message.complianceTag.replacingOccurrences(of: "_", with: " ").capitalized)
            }
        }
    }

    private var complianceSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Compliance Check", systemImage: "shield.lefthalf.filled")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .textCase(.uppercase)

            if viewModel.hasRunCheck {
                ComplianceResultView(results: viewModel.complianceResults)
            }

            Button {
                viewModel.runComplianceCheck()
            } label: {
                HStack {
                    if viewModel.isChecking {
                        ProgressView()
                            .tint(.white)
                            .scaleEffect(0.85)
                    } else {
                        Image(systemName: viewModel.hasRunCheck ? "arrow.clockwise.circle" : "shield.lefthalf.filled.badge.checkmark")
                    }
                    Text(viewModel.hasRunCheck ? "Re-run Compliance Check" : "Run Compliance Check")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.isChecking)
            .tint(.indigo)
        }
    }
}

// MARK: - Supporting Views

private struct MetadataCell: View {
    let label: String
    let value: String
    var valueColor: Color = .primary

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(valueColor)
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.secondary.opacity(0.06), in: RoundedRectangle(cornerRadius: 8))
    }
}
