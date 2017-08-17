/*
 
 Copyright (c) 2017, Tribal Worldwide London
 Copyright (c) 2015, Alex Birkett
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 
 * Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 
 * Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation
 and/or other materials provided with the distribution.
 
 * Neither the name of kiwi-java nor the names of its
 contributors may be used to endorse or promote products derived from
 this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 */

import XCTest
@testable import Cassowary

class TermTests: XCTestCase {
    
    func testConstructors() {
        let term = Term(variable: Variable("x"))
        
        XCTAssertEqual(term.variable.name, "x")
        assertIsCloseTo(term.coefficient, 1.0)
        
        let term1 = Term(variable: Variable("y"), coefficient: 1234.5678)
        XCTAssertEqual(term1.variable.name, "y")
        assertIsCloseTo(term1.coefficient, 1234.5678)
    }
    
    func testUpdateVariable() {
        let x = Variable("x")
        let y = Variable("y")
        
        let term = Term(variable: x)
        XCTAssertEqual(term.variable, x)
        
        term.variable = y
        XCTAssertEqual(term.variable, y)
    }
    
    func testUpdateCoefficient() {
        let term = Term(variable: Variable("x"))
        term.coefficient = 1234.5678
        
        assertIsCloseTo(term.coefficient, 1234.5678)
    }
    
    func testValue() {
        let x = Variable("x")
        x.value = 5
        
        let term = Term(variable: x, coefficient: 2.0)
        assertIsCloseTo(term.value, 10.0)
    }
    
    func testDescription() {
        let term = Term(variable: Variable("x"))
        XCTAssertEqual(term.description, "x")
        
        term.coefficient = 2.0
        XCTAssertEqual(term.description, "x * 2.0")
    }
}


