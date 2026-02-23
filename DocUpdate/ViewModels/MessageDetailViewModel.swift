//
//  MessageDetailViewModel.swift
//  DocUpdate
//
//  Created by Mbusi Hlatshwayo on 2/22/26.
//

import Foundation
import Observation

@Observable
final class MessageDetailViewModel {

    let message: Message
    let physician: Physician?
    private let engine: ComplianceEngine

    private(set) var complianceResults: [ComplianceResult] = []
    private(set) var hasRunCheck = false
    private(set) var isChecking = false

    init(message: Message, physician: Physician?, engine: ComplianceEngine) {
        self.message = message
        self.physician = physician
        self.engine = engine
    }

    func runComplianceCheck() {
        isChecking = true
        Task {
            let results = await Task.detached(priority: .userInitiated) {
                self.engine.check(message: self.message)
            }.value
            complianceResults = results
            hasRunCheck = true
            isChecking = false
        }
    }
}
