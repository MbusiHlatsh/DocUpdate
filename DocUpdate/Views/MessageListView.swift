//
//  MessageListView.swift
//  DocUpdate
//
//  Created by Mbusi Hlatshwayo on 2/22/26.
//

import SwiftUI

struct MessageListView: View {
    @State private var viewModel = MessageListViewModel()
    @State private var showingFilter = false
    @State private var complianceEngine: ComplianceEngine?

    private var isFiltered: Bool {
        viewModel.selectedPhysicianId != nil || viewModel.dateRangeOption != .all
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView("Loading messages…")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let error = viewModel.loadError {
                    errorView(message: error)
                } else {
                    messageList
                }
            }
            .navigationTitle("Messages")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingFilter = true
                    } label: {
                        Label("Filter", systemImage: isFiltered ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                    }
                }
            }
            .sheet(isPresented: $showingFilter) {
                FilterSheetView(viewModel: viewModel)
            }
            .task {
                viewModel.load()
                if let store = try? DataLoader.loadCompliancePolicies() {
                    complianceEngine = ComplianceEngine(rules: store.rules)
                }
            }
        }
    }

    @ViewBuilder
    private var messageList: some View {
        let messages = viewModel.filteredMessages
        if messages.isEmpty {
            emptyStateView
        } else {
            List(messages) { message in
                let physician = viewModel.physician(for: message)
                NavigationLink {
                    if let engine = complianceEngine {
                        MessageDetailView(
                            viewModel: MessageDetailViewModel(
                                message: message,
                                physician: physician,
                                engine: engine
                            )
                        )
                    }
                } label: {
                    MessageRowView(
                        message: message,
                        physicianName: physician?.fullName ?? "Unknown Physician"
                    )
                }
            }
            .listStyle(.plain)
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "tray")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("No Messages")
                .font(.title3)
                .fontWeight(.semibold)
            Text(isFiltered ? "Try adjusting your filters." : "No messages are available.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            if isFiltered {
                Button("Clear Filters") {
                    viewModel.selectedPhysicianId = nil
                    viewModel.dateRangeOption = .all
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func errorView(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundStyle(.red)
            Text("Failed to Load Data")
                .font(.title3)
                .fontWeight(.semibold)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button("Retry") {
                viewModel.load()
            }
            .buttonStyle(.bordered)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
