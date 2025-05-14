import XCTest
@testable import EmpikFoto

final class ContentViewTests: XCTestCase {
    func testCreateCollage() {
        let view = ContentView()
        let images = [UIImage(), UIImage(), UIImage()]
        let collage = view.createCollage()
        XCTAssertNotNil(collage)
    }
} 