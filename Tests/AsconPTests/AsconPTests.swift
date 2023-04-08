import AsconP
import XCTest

final class AsconPTests: XCTestCase {
    func testPermutation() throws {
        var state = State(lanes: (
            0x0101_0101_0101_0101,
            0x0101_0101_0101_0101,
            0x0101_0101_0101_0101,
            0x0101_0101_0101_0101,
            0x0101_0101_0101_0101
        ))
        
        state.permute(withRounds: 12)
        
        XCTAssert(state.elementsEqual([
            0x94, 0x93, 0x31, 0xe2, 0xda, 0xdd, 0xd0, 0x71,
            0xba, 0x5e, 0x60, 0x0a, 0xb7, 0xdb, 0x77, 0x96,
            0xa9, 0xce, 0x41, 0x12, 0xd7, 0x61, 0x4e, 0x6a,
            0x76, 0x51, 0xd3, 0x96, 0x34, 0x11, 0x75, 0x40,
            0xd8, 0x2d, 0x94, 0xf0, 0x41, 0xb5, 0x5a, 0xb4,
       ]))
    }
    
    func testMRAC() {
        var state = State(lanes: (0, 0, 0, 0, 0))
        
        XCTAssertEqual(state.count, 40)
        XCTAssertEqual(state.indices, 0..<40)
        
        XCTAssertEqual(state.index(after: state.startIndex), 1)
        XCTAssertEqual(state.index(before: state.endIndex), 39)
        
        state[21] = 0xff
        XCTAssertEqual(state[21], 0xff)
        state.first = 0xff
        XCTAssertEqual(state.first, 0xff)
        state.last = 0xff
        XCTAssertEqual(state.last, 0xff)
        
        state.withContiguousMutableStorageIfAvailable {
            for (index, element): (_, UInt8) in zip($0.indices, 0...) {
                $0[index] = element
            }
        }
        state.withContiguousStorageIfAvailable {
            XCTAssert($0.elementsEqual(0..<40))
        }
        
        state.withUnsafeMutableBytes {
            $0.copyBytes(from: 1...40)
        }
        state.withUnsafeBytes {
            XCTAssert($0.elementsEqual(1...40))
        }
        
        XCTAssert(state.elementsEqual(1...40))
    }
}
