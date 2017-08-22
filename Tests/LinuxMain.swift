// Generated using Sourcery 0.7.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import XCTest
@testable import CassowaryTests

extension CassowaryTests {
    static var allTests = [
         ("testSimple", testSimple),
         ("testSimple0", testSimple0),
         ("testSimple1", testSimple1),
         ("testCasso1", testCasso1),
         ("testAddDelete1", testAddDelete1),
         ("testAddDelete2", testAddDelete2),
         ("testInconsistent1", testInconsistent1),
         ("testInconsistent2", testInconsistent2),
         ("testInconsistent3", testInconsistent3),
         ("testPaperExample", testPaperExample),
         ("testEditExample", testEditExample),
         ("testExample", testExample),
         ("testTops", testTops),
         ("testAddEditVariable", testAddEditVariable),
         ("testRemoveEditVariable", testRemoveEditVariable),
         ("testSuggestValue", testSuggestValue),
        ]
}

extension ConstraintTests {
    static var allTests = [
         ("testInitConstraint", testInitConstraint),
         ("testEditConstraint", testEditConstraint),
        ]
}

extension DoubleEpsilonTests {
    static var allTests = [
         ("testIsNearZero", testIsNearZero),
         ("testIsApproximately", testIsApproximately),
        ]
}

extension ExpressionTests {
    static var allTests = [
         ("testConstructors", testConstructors),
         ("testDescription", testDescription),
         ("testUpdateTerms", testUpdateTerms),
         ("testUpdateConstant", testUpdateConstant),
         ("testAlias", testAlias),
        ]
}

extension TermTests {
    static var allTests = [
         ("testConstructors", testConstructors),
         ("testUpdateVariable", testUpdateVariable),
         ("testUpdateCoefficient", testUpdateCoefficient),
         ("testValue", testValue),
         ("testDescription", testDescription),
        ]
}

extension VariableTests {
    static var allTests = [
         ("testConstructors", testConstructors),
        ]
}


XCTMain([
     testCase(CassowaryTests.allTests),
     testCase(ConstraintTests.allTests),
     testCase(DoubleEpsilonTests.allTests),
     testCase(ExpressionTests.allTests),
     testCase(TermTests.allTests),
     testCase(VariableTests.allTests),
])
