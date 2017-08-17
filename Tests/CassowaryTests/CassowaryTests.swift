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

class CassowaryTests: XCTestCase {

    func testSimple() throws {
        let solver = Solver()
        let x = Variable("x")

        try solver.addConstraint(x + 2 == 20)

        solver.updateVariables()
        assertIsCloseTo(x, 18)
    }

    func testSimple0() throws {
        let solver = Solver()
        let x = Variable("x")
        let y = Variable("y")

        try solver.addConstraint(x == 20)
        try solver.addConstraint(x + 2 == y + 10)

        solver.updateVariables()

        assertIsCloseTo(x, 20)
        assertIsCloseTo(y, 12)
    }

    func testSimple1() throws {
        let solver = Solver()
        let x = Variable("x")
        let y = Variable("y")

        try solver.addConstraint(x == y)
        solver.updateVariables()

        assertIsCloseTo(x, y)
    }

    func testCasso1() throws {
        let solver = Solver()
        let x = Variable("x")
        let y = Variable("y")

        try solver.addConstraint(x <= y)
        try solver.addConstraint(y == x + 3.0)
        try solver.addConstraint((x == 10.0).setStrength(Strength.WEAK))
        try solver.addConstraint((y == 10.0).setStrength(Strength.WEAK))

        solver.updateVariables()

        if abs(x.value - 10.0) < Double.epsilon {
            assertIsCloseTo(10.0, x)
            assertIsCloseTo(13.0, y)
        } else {
            assertIsCloseTo(7.0, x)
            assertIsCloseTo(10.0, y)
        }
    }

    func testAddDelete1() throws {
        let solver = Solver()
        let x = Variable("x")

        try solver.addConstraint((x <= 100).setStrength(Strength.WEAK))
        solver.updateVariables()

        assertIsCloseTo(100, x)

        let c10 = x <= 10
        let c20 = x <= 20

        try solver.addConstraint(c10)
        try solver.addConstraint(c20)

        solver.updateVariables()

        assertIsCloseTo(10, x)

        try solver.removeConstraint(c10)
        solver.updateVariables()

        assertIsCloseTo(20, x)

        try solver.removeConstraint(c20)
        solver.updateVariables()

        assertIsCloseTo(100, x)

        let c10again = x <= 10

        try solver.addConstraint(c10again)
        try solver.addConstraint(c10)
        solver.updateVariables()

        assertIsCloseTo(10, x)

        try solver.removeConstraint(c10)
        solver.updateVariables()
        assertIsCloseTo(10, x)

        try solver.removeConstraint(c10again)
        solver.updateVariables()
        assertIsCloseTo(100, x)
    }

    func testAddDelete2() throws {
        let solver = Solver()
        let x = Variable("x")
        let y = Variable("y")

        try solver.addConstraint((x == 100).setStrength(Strength.WEAK))
        try solver.addConstraint((y == 120).setStrength(Strength.STRONG))

        let c10 = x <= 10.0
        let c20 = x <= 20.0

        try solver.addConstraint(c10)
        try solver.addConstraint(c20)
        solver.updateVariables()

        assertIsCloseTo(10, x)
        assertIsCloseTo(120, y)

        try solver.removeConstraint(c10)
        solver.updateVariables()

        assertIsCloseTo(20, x)
        assertIsCloseTo(120, y)

        let cxy = x * 2 == y
        try solver.addConstraint(cxy)
        solver.updateVariables()

        assertIsCloseTo(20, x)
        assertIsCloseTo(40, y)

        try solver.removeConstraint(c20)
        solver.updateVariables()

        assertIsCloseTo(60, x)
        assertIsCloseTo(120, y)

        try solver.removeConstraint(cxy)
        solver.updateVariables()

        assertIsCloseTo(100, x)
        assertIsCloseTo(120, y)
    }

    func testInconsistent1() {
        let solver = Solver()
        let x = Variable("x")

        do {
            try solver.addConstraint(x == 10.0)
            try solver.addConstraint(x == 5.0)
            solver.updateVariables()
        } catch CassowaryError.unsatisfiableConstraint(_) {
            // An error is expected
            return
        } catch {
            XCTFail("An unexpected error was encountered")
        }

        XCTFail("Should throw exception")
    }

    func testInconsistent2() {
        let solver = Solver()
        let x = Variable("x")

        do {
            try solver.addConstraint(x >= 10)
            try solver.addConstraint(x <= 5)
            solver.updateVariables()
        } catch CassowaryError.unsatisfiableConstraint(_) {
            // An error is expected
            return
        } catch {
            XCTFail("An unexpected error was encountered")
        }

        XCTFail("Should throw exception")
    }

    func testInconsistent3() {
        let solver = Solver()
        let w = Variable("w")
        let x = Variable("x")
        let y = Variable("y")
        let z = Variable("z")

        do {
            try solver.addConstraint(w >= 10)
            try solver.addConstraint(x >= w)
            try solver.addConstraint(y >= x)
            try solver.addConstraint(z >= y)
            try solver.addConstraint(z >= 8)
            try solver.addConstraint(z <= 4.0)
            solver.updateVariables()
        } catch let error as CassowaryError {
            // An error is expected
            print(error.detailedDescription())
            return
        } catch {
            XCTFail("An unexpected error was encountered")
        }

        XCTFail("Should throw exception")
    }

    func testPaperExample() throws {
        let xl = Variable("xl")
        let xm = Variable("xm")
        let xr = Variable("xr")

        let solver = Solver()
        try solver.addConstraint(xr <= 100)
        try solver.addConstraint(xm * 2 == xl + xr)
        try solver.addConstraint(xl + 10 <= xr)
        try solver.addConstraint(0 <= xl)

        solver.updateVariables()

        assertIsCloseTo(xl, 90.0)
        assertIsCloseTo(xm, 95.0)
        assertIsCloseTo(xr, 100.0)
    }

    func testEditExample() throws {
        let solver = Solver()

        let left = Variable("left")
        let mid = Variable("mid")
        let right = Variable("right")

        try solver.addConstraint(mid == (left + right) / 2)
        try solver.addConstraint(right == left + 10)
        try solver.addConstraint(right <= 100)
        try solver.addConstraint(left >= 0)

        try solver.addEditVariable(variable: mid, strength: Strength.STRONG)
        try solver.suggestValue(variable: mid, value: 2)

        solver.updateVariables()

        assertIsCloseTo(left, 0.0)
        assertIsCloseTo(mid, 5.0)
        assertIsCloseTo(right, 10.0)
    }

    func testExample() throws {
        let x = Variable("x")
        let y = Variable("y")

        let solver = Solver()

        try solver.addConstraint(x == y)

        solver.updateVariables()

        assertIsCloseTo(x, y)
    }
    
    func testTops() throws {
        class Constrainable {
            let top = Variable("top")
            let height = Variable("height")
            var bottom: Expression {
                return top + height
            }
        }
        
        let parent = Constrainable()
        let child = Constrainable()
        
        let solver = Solver()
        
        do {
            //try solver.addConstraint(parent.top == 100)
            try solver.addConstraint(child.top == parent.top)
            try solver.addConstraint(child.bottom == parent.bottom)
            try solver.addEditVariable(variable: child.height, strength: Strength.STRONG)
            try solver.suggestValue(variable: child.height, value: 24.0)
        } catch {
            print(error)
        }
        
        solver.updateVariables()
        
        assertIsCloseTo(parent.height, 24)
    }

}
