//
//  MessageListViewModel.swift
//  DocUpdate
//
//  Created by Mbusi Hlatshwayo on 2/22/26.
//

import Foundation
import Observation

@Observable
final class MessageListViewModel {

    // MARK: - Loaded data

    private(set) var messages: [Message] = []
    private(set) var physicians: [Physician] = []
    private(set) var loadError: String?
    private(set) var isLoading = false

    // MARK: - Filter state

    var selectedPhysicianId: Int? = nil
    var dateRangeOption: DateRangeOption = .all

    enum DateRangeOption: String, CaseIterable, Identifiable {
        case all = "All Time"
        case last7 = "Last 7 Days"
        case last30 = "Last 30 Days"
        case last90 = "Last 90 Days"

        var id: String { rawValue }

        var startDate: Date? {
            let cal = Calendar.current
            switch self {
            case .all: return nil
            case .last7: return cal.date(byAdding: .day, value: -7, to: Date())
            case .last30: return cal.date(byAdding: .day, value: -30, to: Date())
            case .last90: return cal.date(byAdding: .day, value: -90, to: Date())
            }
        }
    }

    // MARK: - Derived

    var filteredMessages: [Message] {
        messages
            .filter { msg in
                if let physId = selectedPhysicianId, msg.physicianId != physId { return false }
                if let start = dateRangeOption.startDate, msg.timestamp < start { return false }
                return true
            }
            .sorted { $0.timestamp > $1.timestamp }
    }

    func physician(for message: Message) -> Physician? {
        physicians.first { $0.id == message.physicianId }
    }

    // MARK: - Load

    func load() {
        isLoading = true
        loadError = nil
        do {
            physicians = try DataLoader.loadPhysicians()
            messages = try DataLoader.loadMessages()
        } catch {
            loadError = error.localizedDescription
        }
        isLoading = false
    }
}
