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

import Foundation

public class Row {

    private(set) var constant: Double

    private(set) var cells: OrderedDictionary<Symbol, Double> = [:]

    public convenience init() {
        self.init(constant: 0)
    }

    public init(constant: Double) {
        self.constant = constant
    }

    public init(_ other: Row) {
        self.cells = OrderedDictionary<Symbol, Double>(other.cells)
        self.constant = other.constant
    }

    /**
     Add a constant value to the row constant.
     - returns: The new value of the constant
     */
    func add(_ value: Double) -> Double {
        self.constant += value
        return self.constant
    }

    /**
     Insert a symbol into the row with a given coefficient.

     If the symbol already exists in the row, the coefficient will be
     added to the existing coefficient. If the resulting coefficient
     is zero, the symbol will be removed from the row
     */
    func insert(symbol: Symbol, coefficient: Double) {
        var coeff = coefficient

        if let existingCoefficient = cells[symbol] {
            coeff += existingCoefficient
        }

        if coeff.isNearZero {
            cells[symbol] = nil
        } else {
            cells[symbol] = coeff
        }
    }

    /**
     Insert a symbol into the row with a given coefficient.

     If the symbol already exists in the row, the coefficient will be
     added to the existing coefficient. If the resulting coefficient
     is zero, the symbol will be removed from the row
     */
    func insert(symbol: Symbol) {
        insert(symbol: symbol, coefficient: 1.0)
    }

    /**
     Insert a row into this row with a given coefficient.

     The constant and the cells of the other row will be multiplied by
     the coefficient and added to this row. Any cell with a resulting
     coefficient of zero will be removed from the row.
     */
    func insert(other: Row, coefficient: Double) {
        constant += other.constant * coefficient

        for s in other.cells.keys {
            let coeff = other.cells[s]! * coefficient

            let value = cells[s]

            if value == nil {
                cells[s] = 0.0
            }

            let temp = cells[s]! + coeff
            cells[s] = temp

            if temp.isNearZero {
                cells[s] = nil
            }
        }
    }

    /**
     Insert a row into this row with a given coefficient.

     The constant and the cells of the other row will be multiplied by
     the coefficient and added to this row. Any cell with a resulting
     coefficient of zero will be removed from the row.
     */
    func insert(other: Row) {
        insert(other: other, coefficient: 1.0)
    }

    /**
     Remove the given symbol from the row.
     */
    func remove(symbol: Symbol) {
        cells[symbol] = nil
    }

    /**
     Reverse the sign of the constant and all cells in the row.
     */
    func reverseSign() {
        constant = -constant

        var newCells = OrderedDictionary<Symbol, Double>()

        for symbol in cells.keys {
            let value = -cells[symbol]!
            newCells[symbol] = value
        }

        cells = newCells
    }

    /**
     Solve the row for the given symbol.

     This method assumes the row is of the form a * x + b * y + c = 0
     and (assuming solve for x) will modify the row to represent the
     right hand side of x = -b/a * y - c / a. The target symbol will
     be removed from the row, and the constant and other cells will
     be multiplied by the negative inverse of the target coefficient.
     The given symbol *must* exist in the row.
     */
    func solveFor(_ symbol: Symbol) {
        let coeff = -1.0 / cells[symbol]!
        cells[symbol] = nil
        constant *= coeff

        var newCells = OrderedDictionary<Symbol, Double>()

        for s in cells.keys {
            let value = cells[s]! * coeff
            newCells[s] = value
        }

        cells = newCells
    }

    /**
     Solve the row for the given symbols.

     This method assumes the row is of the form x = b * y + c and will
     solve the row such that y = x / b - c / b. The rhs symbol will be
     removed from the row, the lhs added, and the result divided by the
     negative inverse of the rhs coefficient.
     The lhs symbol *must not* exist in the row, and the rhs symbol
     *must* exist in the row.
     */
    func solveFor(_ lhs: Symbol, _ rhs: Symbol) {
        insert(symbol: lhs, coefficient: -1.0)
        solveFor(rhs)
    }

    /**
     Get the coefficient for the given symbol.

     If the symbol does not exist in the row, zero will be returned.
     */
    func coefficientFor(_ symbol: Symbol) -> Double {
        if let coeff = cells[symbol] {
            return coeff
        } else {
            return 0.0
        }
    }

    /**
     Substitute a symbol with the data from another row.

     Given a row of the form a * x + b and a substitution of the
     form x = 3 * y + c the row will be updated to reflect the
     expression 3 * a * y + a * c + b.
     If the symbol does not exist in the row, this is a no-op.
     */
    func substitute(symbol: Symbol, row: Row) {
        if let coeff = cells[symbol] {
            cells[symbol] = nil
            insert(other: row, coefficient: coeff)
        }
    }

}

// MARK: Equatable
extension Row: Equatable {

    public static func == (lhs: Row, rhs: Row) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }

}

// MARK: Hashable
extension Row: Hashable {

    public var hashValue: Int {
        // Return a hash 'unique' to this object
        return ObjectIdentifier(self).hashValue
    }

}
