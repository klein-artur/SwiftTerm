//
//  Memory.swift - Ensures that an allocated terminal is deallocated, this is
// to make sure we do not regress when we use helper classes that might introduce
// a strong cycle.
//  
//
//  Created by Miguel de Icaza on 4/17/21.
//

import Foundation
import XCTest

@testable import SwiftTerm
final class SwiftTermMemory: XCTestCase {
    static var deinited = false
    
    class SimpleTerminal: HeadlessTerminal {
        
        init (queue: DispatchQueue) {
            super.init (queue: queue, onEnd: { x in })
        }
        deinit {
            SwiftTermMemory.deinited = true
        }
    }
    
    func allocate (){
        let queue = DispatchQueue(label: "Runner", qos: .userInteractive, attributes: .concurrent, autoreleaseFrequency: .inherit, target: nil)
        let h = SimpleTerminal(queue: queue)
        //h.terminal.close ()
        let _ = h.terminal
    }
    
    // This test ensures that we are not keeping any strong references
    // in the code that would prevent the terminal from being released
    func testMemory ()
    {
        SwiftTermMemory.deinited = false
        allocate ()
        XCTAssertEqual(SwiftTermMemory.deinited, true)
    }
    
    static var allTests = [
        ("testMemory", testMemory),
    ]
}
