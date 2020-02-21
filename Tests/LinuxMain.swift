import XCTest

import listenTests

var tests = [XCTestCaseEntry]()
tests += listenTests.allTests()
XCTMain(tests)
