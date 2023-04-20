public typealias Lanes = (UInt64, UInt64, UInt64, UInt64, UInt64)

public struct State {
    private var lanes: Lanes
    
    public init(lanes: Lanes) {
        self.lanes = lanes
    }
    
    public mutating func permute(rounds: Int) {
        precondition((0...12).contains(rounds))
        
        lanes.0 = UInt64(bigEndian: lanes.0)
        lanes.1 = UInt64(bigEndian: lanes.1)
        lanes.2 = UInt64(bigEndian: lanes.2)
        lanes.3 = UInt64(bigEndian: lanes.3)
        lanes.4 = UInt64(bigEndian: lanes.4)
        
        stride(from: 0xf0 as UInt64, through: 0x4b, by: -0xf).suffix(rounds).forEach {
            lanes.2 ^= $0
            
            self.substitute()
            
            self.diffuse()
        }
        
        lanes.0 = lanes.0.bigEndian
        lanes.1 = lanes.1.bigEndian
        lanes.2 = lanes.2.bigEndian
        lanes.3 = lanes.3.bigEndian
        lanes.4 = lanes.4.bigEndian
    }
    
    @inline(__always)
    private mutating func substitute() {
        lanes.0 ^= lanes.4
        lanes.4 ^= lanes.3
        lanes.2 ^= lanes.1
        
        lanes = (
            lanes.0 ^ ~lanes.1 & lanes.2,
            lanes.1 ^ ~lanes.2 & lanes.3,
            lanes.2 ^ ~lanes.3 & lanes.4,
            lanes.3 ^ ~lanes.4 & lanes.0,
            lanes.4 ^ ~lanes.0 & lanes.1
        )
        
        lanes.1 ^= lanes.0
        lanes.3 ^= lanes.2
        lanes.0 ^= lanes.4
        lanes.2 = ~lanes.2
    }
    
    @inline(__always)
    private mutating func diffuse() {
        lanes.0.diffuse(withRotations: 19, 28)
        lanes.1.diffuse(withRotations: 61, 39)
        lanes.2.diffuse(withRotations: 01, 06)
        lanes.3.diffuse(withRotations: 10, 17)
        lanes.4.diffuse(withRotations: 07, 41)
    }
}

extension UInt64 {
    @inline(__always)
    fileprivate mutating func diffuse(withRotations r0: Int, _ r1: Int) {
        self ^= self.rotated(right: r0) ^ self.rotated(right: r1)
    }
    
    @inline(__always)
    private func rotated(right count: Int) -> Self {
        (self &<< (Self.bitWidth - count)) | (self &>> count)
    }
}
