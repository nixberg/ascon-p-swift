public typealias Lanes = (UInt64, UInt64, UInt64, UInt64, UInt64)

public struct State {
    private var lanes: Lanes
    
    public init(lanes: Lanes) {
        self.lanes = lanes
    }
    
    public mutating func permute(withRounds rounds: Int) {
        precondition((0...12).contains(rounds))
        
        lanes.0 = UInt64(bigEndian: lanes.0)
        lanes.1 = UInt64(bigEndian: lanes.1)
        lanes.2 = UInt64(bigEndian: lanes.2)
        lanes.3 = UInt64(bigEndian: lanes.3)
        lanes.4 = UInt64(bigEndian: lanes.4)
        
        stride(from: 0xf0 as UInt64, through: 0x4b, by: -0x0f).suffix(rounds).forEach {
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
        
        let temps = (lanes.0, lanes.1)
        
        lanes.0 ^= ~lanes.1 & lanes.2
        lanes.1 ^= ~lanes.2 & lanes.3
        lanes.2 ^= ~lanes.3 & lanes.4
        lanes.3 ^= ~lanes.4 & temps.0
        lanes.4 ^= ~temps.0 & temps.1
        
        lanes.1 ^= lanes.0
        lanes.3 ^= lanes.2
        lanes.0 ^= lanes.4
        lanes.2 = ~lanes.2
    }
    
    @inline(__always)
    private mutating func diffuse() {
        lanes.0.diffuse(withRotations: 19, 28)
        lanes.1.diffuse(withRotations: 61, 39)
        lanes.2.diffuse(withRotations:  1,  6)
        lanes.3.diffuse(withRotations: 10, 17)
        lanes.4.diffuse(withRotations:  7, 41)
    }
}

private extension UInt64 {
    @inline(__always)
    mutating func diffuse(withRotations a: Int, _ b: Int) {
        self ^= self.rotated(right: a) ^ self.rotated(right: b)
    }
    
    @inline(__always)
    private func rotated(right count: Int) -> Self {
        (self &<< (Self.bitWidth - count)) | (self &>> count)
    }
}
