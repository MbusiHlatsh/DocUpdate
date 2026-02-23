//
//  FilterSheetView.swift
//  DocUpdate
//
//  Created by Mbusi Hlatshwayo on 2/22/26.
//

import SwiftUI

struct FilterSheetView: View {
    @Bindable var viewModel: MessageListViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Physician") {
                    Picker("Physician", selection: $viewModel.selectedPhysicianId) {
                        Text("All Physicians").tag(Optional<Int>.none)
                        ForEach(viewModel.physicians) { physician in
                            Text(physician.fullName).tag(Optional(physician.id))
                        }
                    }
                    .pickerStyle(.menu)
                }

                Section("Date Range") {
                    Picker("Date Range", selection: $viewModel.dateRangeOption) {
                        ForEach(MessageListViewModel.DateRangeOption.allCases) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section {
                    Button("Clear Filters", role: .destructive) {
                        viewModel.selectedPhysicianId = nil
                        viewModel.dateRangeOption = .all
                    }
                }
            }
            .navigationTitle("Filter Messages")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
