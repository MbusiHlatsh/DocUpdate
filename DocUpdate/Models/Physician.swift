//
//  Physician.swift
//  DocUpdate
//
//  Created by Mbusi Hlatshwayo on 2/22/26.
//

import Foundation

struct Physician: Identifiable, Hashable {
    let id: Int
    let npi: String
    let firstName: String
    let lastName: String
    let specialty: String
    let state: String
    let consentOptIn: Bool
    let preferredChannel: String

    var fullName: String { "\(firstName) \(lastName)" }
}
