import XCTest
@testable import IPFSWebService

class IPFSWebServiceTests: XCTestCase {

    func testInstantiation() {
        XCTAssertNotNil(DefaultAPI())
    }

    static var allTests = [
        ("testInstantiation", testInstantiation),
    ]

}
