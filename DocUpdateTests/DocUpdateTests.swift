//
//  DocUpdateTests.swift
//  DocUpdateTests
//
//  Created by Mbusi Hlatshwayo on 2/22/26.
//

import XCTest
@testable import DocUpdate

// MARK: - ComplianceEngine Tests

final class ComplianceEngineTests: XCTestCase {

    private var engine: ComplianceEngine!

    override func setUp() {
        super.setUp()
        let rules = [
            ComplianceRule(id: "R-001", name: "No off-label claims", keywordsAny: ["off-label", "unapproved use"], action: "flag", requiresAppend: nil),
            ComplianceRule(id: "R-002", name: "Include safety statement when mentioning dosing", keywordsAny: ["dosing", "titration"], action: nil, requiresAppend: "See PI for full safety info."),
            ComplianceRule(id: "R-003", name: "No patient PHI", keywordsAny: ["DOB:", "SSN", "MRN"], action: "reject", requiresAppend: nil),
            ComplianceRule(id: "R-004", name: "Samples request needs rep follow-up", keywordsAny: ["samples", "sample request"], action: "route_to_rep", requiresAppend: nil),
            ComplianceRule(id: "R-005", name: "Clinical trial info must cite registry", keywordsAny: ["trial", "clinical trial"], action: nil, requiresAppend: "Refer to ClinicalTrials.gov for eligibility details.")
        ]
        engine = ComplianceEngine(rules: rules)
    }

    private func makeMessage(text: String) -> Message {
        Message(
            id: 1,
            physicianId: 101,
            channel: "sms",
            direction: "outbound",
            timestamp: Date(),
            text: text,
            campaignId: "CMP-01",
            topic: "test",
            complianceTag: "needs_review",
            sentiment: "neutral",
            deliveryStatus: "delivered",
            responseLatencySec: nil
        )
    }

    func testCleanMessageProducesNoResults() {
        let msg = makeMessage(text: "Thank you for your time today.")
        XCTAssertTrue(engine.check(message: msg).isEmpty)
    }

    func testOffLabelKeywordTriggersR001() {
        let msg = makeMessage(text: "This drug has an off-label indication for migraines.")
        let results = engine.check(message: msg)
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results[0].rule.id, "R-001")
        XCTAssertEqual(results[0].triggeredKeyword, "off-label")
    }

    func testDosingKeywordTriggersR002WithRequiredAppend() {
        let msg = makeMessage(text: "Clarify dosing schedule for the patient.")
        let results = engine.check(message: msg)
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results[0].rule.id, "R-002")
        XCTAssertNotNil(results[0].rule.requiresAppend)
    }

    func testPHIKeywordTriggersR003WithRejectAction() {
        let msg = makeMessage(text: "Patient SSN is on file.")
        let results = engine.check(message: msg)
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results[0].rule.id, "R-003")
        XCTAssertEqual(results[0].rule.action, "reject")
    }

    func testSamplesKeywordTriggersR004() {
        let msg = makeMessage(text: "Requesting patient samples for clinic use.")
        let results = engine.check(message: msg)
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results[0].rule.id, "R-004")
    }

    func testTrialKeywordTriggersR005() {
        let msg = makeMessage(text: "Eligibility for clinical trial referral.")
        let results = engine.check(message: msg)
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results[0].rule.id, "R-005")
    }

    func testMultipleRulesCanTriggerForOneMessage() {
        let msg = makeMessage(text: "Dosing for off-label use and samples available.")
        let results = engine.check(message: msg)
        let ruleIds = results.map { $0.rule.id }
        XCTAssertTrue(ruleIds.contains("R-001"))
        XCTAssertTrue(ruleIds.contains("R-002"))
        XCTAssertTrue(ruleIds.contains("R-004"))
    }

    func testKeywordMatchingIsCaseInsensitive() {
        let msg = makeMessage(text: "OFF-LABEL promotion is prohibited.")
        let results = engine.check(message: msg)
        XCTAssertFalse(results.isEmpty)
        XCTAssertEqual(results[0].rule.id, "R-001")
    }

    func testEachRuleOnlyTriggersOncePerMessage() {
        let msg = makeMessage(text: "dosing dosing dosing titration titration")
        let results = engine.check(message: msg)
        XCTAssertEqual(results.count, 1, "R-002 should only appear once even with multiple keyword hits")
    }

    func testComplianceResultExplanationContainsRuleId() {
        let msg = makeMessage(text: "off-label claim here")
        let results = engine.check(message: msg)
        XCTAssertTrue(results[0].explanation.contains("R-001"))
    }
}

// MARK: - DataLoader Tests

final class DataLoaderTests: XCTestCase {

    func testLoadPhysiciansSucceeds() throws {
        let physicians = try DataLoader.loadPhysicians()
        XCTAssertFalse(physicians.isEmpty)
    }

    func testPhysicianFieldsAreParsedCorrectly() throws {
        let physicians = try DataLoader.loadPhysicians()
        let first = try XCTUnwrap(physicians.first)
        XCTAssertGreaterThan(first.id, 0)
        XCTAssertFalse(first.firstName.isEmpty)
        XCTAssertFalse(first.lastName.isEmpty)
        XCTAssertFalse(first.specialty.isEmpty)
    }

    func testLoadMessagesSucceeds() throws {
        let messages = try DataLoader.loadMessages()
        XCTAssertFalse(messages.isEmpty)
    }

    func testMessageFieldsAreParsedCorrectly() throws {
        let messages = try DataLoader.loadMessages()
        let first = try XCTUnwrap(messages.first)
        XCTAssertGreaterThan(first.id, 0)
        XCTAssertGreaterThan(first.physicianId, 0)
        XCTAssertFalse(first.text.isEmpty)
        XCTAssertNotEqual(first.timestamp, Date.distantPast)
    }

    func testLoadCompliancePoliciesSucceeds() throws {
        let store = try DataLoader.loadCompliancePolicies()
        XCTAssertFalse(store.rules.isEmpty)
        XCTAssertEqual(store.version, "v1")
    }

    func testCSVLineParserHandlesSimpleRow() {
        let line = "101,1089250953,Drew,Nguyen,Cardiology,MA,True,sms"
        let cols = DataLoader.parseCSVLine(line)
        XCTAssertEqual(cols.count, 8)
        XCTAssertEqual(cols[0], "101")
        XCTAssertEqual(cols[2], "Drew")
    }

    func testCSVLineParserHandlesQuotedFields() {
        let line = "1,\"Smith, John\",Cardiology"
        let cols = DataLoader.parseCSVLine(line)
        XCTAssertEqual(cols.count, 3)
        XCTAssertEqual(cols[1], "Smith, John")
    }
}
