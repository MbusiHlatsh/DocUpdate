//
//  Message.swift
//  DocUpdate
//
//  Created by Mbusi Hlatshwayo on 2/22/26.
//

import Foundation

struct Message: Identifiable, Hashable {
    let id: Int
    let physicianId: Int
    let channel: String
    let direction: String
    let timestamp: Date
    let text: String
    let campaignId: String
    let topic: String
    let complianceTag: String
    let sentiment: String
    let deliveryStatus: String
    let responseLatencySec: Double?
}
