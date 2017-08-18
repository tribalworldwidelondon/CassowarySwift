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

public class Solver {

    private class Tag {
        var marker: Symbol = Symbol()
        var other: Symbol?
    }

    private class EditInfo {
        var tag: Tag
        var constraint: EditConstraint
        var constant: Double

        public init(constraint: EditConstraint, tag: Tag, constant: Double){
            self.constraint = constraint
            self.tag = tag
            self.constant = constant
        }
    }

    private var _cns = OrderedDictionary<Constraint, Tag>()
    private var _rows = OrderedDictionary<Symbol, Row>()
    private var _vars = OrderedDictionary<Variable, Symbol>()
    private var _edits = OrderedDictionary<Variable, EditInfo>()
    private var _infeasibleRows = [Symbol]()
    private var _objective = Row()
    private var _artificial: Row?
    
    // MARK: Initializers
    
    public init() {
        
    }

    /// Add a constraint to the solver.
    public func addConstraint(_ constraint: Constraint) throws {
        if _cns[constraint] != nil {
            throw CassowaryError.duplicateConstraint(constraint)
        }

        let tag = Tag()
        let row = createRow(constraint: constraint, tag: tag)
        var subject = Solver.chooseSubject(row: row, tag: tag)

        if subject.symbolType == .invalid && Solver.allDummies(row: row) {
            if !row.constant.isNearZero {
                throw CassowaryError.unsatisfiableConstraint(constraint, _cns.keys)
            } else {
                subject = tag.marker
            }
        }

        if subject.symbolType == .invalid {
            if try !addWithArtificialVariable(row: row) {
                throw CassowaryError.unsatisfiableConstraint(constraint, _cns.keys)
            }
        } else {
            row.solveFor(subject)
            substitute(symbol: subject, row: row)
            _rows[subject] = row
        }

        _cns[constraint] = tag

        try optimize(objective: _objective)
    }
    
    /// Remove a constraint from the solver
    public func removeConstraint(_ constraint: Constraint) throws {
        guard let tag = _cns[constraint] else {
            throw CassowaryError.unknownConstraint(constraint)
        }

        _cns[constraint] = nil
        removeConstraintEffects(constraint: constraint, tag: tag)

        if _rows[tag.marker] != nil {
            _rows[tag.marker] = nil
        } else {
            guard let row = getMarkerLeavingRow(marker: tag.marker) else {
                throw CassowaryError.internalSolver("Internal solver error")
            }

            var leaving: Symbol?
            for s in _rows.keys {
                if let r = _rows[s], r == row {
                    leaving = s
                }
            }

            if leaving == nil {
                throw CassowaryError.internalSolver("Internal solver error")
            }

            _rows[leaving!] = nil
            row.solveFor(leaving!, tag.marker)
            substitute(symbol: tag.marker, row: row)
        }

        try optimize(objective: _objective)
    }

    private func removeConstraintEffects(constraint: Constraint, tag: Tag) {
        if tag.marker.symbolType == .error {
            removeMarkerEffects(marker: tag.marker, strength: constraint.strength)
        } else if tag.other?.symbolType == .error {
            removeMarkerEffects(marker: tag.other!, strength: constraint.strength)
        }
    }

    private func removeMarkerEffects(marker: Symbol, strength: Double) {
        if let row = _rows[marker] {
            _objective.insert(other: row, coefficient: -strength)
        } else {
            _objective.insert(symbol: marker, coefficient: -strength)
        }
    }

    private func getMarkerLeavingRow(marker: Symbol) -> Row? {
        let dmax = Double.greatestFiniteMagnitude
        var r1 = dmax
        var r2 = dmax

        var first: Row?
        var second: Row?
        var third: Row?

        for s in _rows.keys {
            let candidateRow = _rows[s]!
            let c = candidateRow.coefficientFor(marker)

            if c == 0.0 {
                continue
            }

            if s.symbolType == .external {
                third = candidateRow
            } else if c < 0.0 {
                let r = -candidateRow.constant / c
                if r < r1 {
                    r1 = r
                    first = candidateRow
                }
            } else {
                let r = candidateRow.constant / c
                if r < r2 {
                    r2 = r
                    second = candidateRow
                }
            }
        }

        if first != nil {
            return first
        }

        if second != nil {
            return second
        }

        return third
    }
    
    /// Check if the solver has a constraint
    public func hasConstraint(_ constraint: Constraint) -> Bool {
        return _cns[constraint] != nil
    }
    
    /**
     Add an edit constraint on the provided variable, so that suggestValue can be used on it.
     - parameters:
         - variable: The Variable to add the edit constraint on
         - strength: The strength of the constraint to add. This cannot be "Required".
     */
    public func addEditVariable(variable: Variable, strength: Double) throws {
        guard _edits[variable] == nil else {
            throw CassowaryError.duplicateEditVariable
        }

        let clippedStrength = Strength.clip(strength)

        if clippedStrength == Strength.REQUIRED {
            throw CassowaryError.requiredFailure
        }

        var terms = [Term]()
        terms.append(Term(variable: variable))
        let constraint = EditConstraint(expr: Expression(terms: terms), op: .equal, strength: clippedStrength)

        do {
            try addConstraint(constraint)
        } catch let error as CassowaryError {
            print(error)
        }

        // TODO: Check if tag can be nil
        let info = EditInfo(constraint: constraint, tag: _cns[constraint]!, constant: 0.0)
        _edits[variable] = info
    }
    
    /**
     Remove an edit constraint on the provided variable.
     Throws an error if the variable does not have an edit constraint
     */
    public func removeEditVariable(_ variable: Variable) throws {
        guard let edit = _edits[variable] else {
            throw CassowaryError.unknownEditVariable
        }

        do {
            try removeConstraint(edit.constraint)
        } catch {
            print(error)
        }

        _edits[variable] = nil
    }
    
    /// Checks if the solver has an edit constraint for the provided variable.
    public func hasEditVariable(_ variable: Variable) -> Bool {
        return _edits[variable] != nil
    }
    
    /**
     Specify a desired value for the provided variable.
     The variable needs to have been previously added as an edit variable.
     Throws an error if the provided variable has not been previously added as an edit variable.
     */
    public func suggestValue(variable: Variable, value: Double) throws {
        guard let info = _edits[variable] else {
            throw CassowaryError.unknownEditVariable
        }

        let delta = value - info.constant
        info.constant = value

        var row = _rows[info.tag.marker]
        
        _edits[variable]!.constraint.suggestedValue = value

        if row != nil {
            if row!.add(-delta) < 0.0 {
                _infeasibleRows.append(info.tag.marker)
            }
            try dualOptimize()
            return
        }

        if info.tag.other != nil {
            row = _rows[info.tag.other!]

            if row != nil {
                if row!.add(delta) < 0.0 {
                    _infeasibleRows.append(info.tag.other!)
                }
                try dualOptimize()
                return
            }
        }

        for s in _rows.keys {
            let currentRow = _rows[s]!
            let coefficient = currentRow.coefficientFor(info.tag.marker)
            if coefficient != 0.0 && currentRow.add(delta * coefficient) < 0.0 && s.symbolType != .external {
                _infeasibleRows.append(s)
            }
        }

        try dualOptimize()
    }

    /**
     Update the values of the external solver variables.
     */
    public func updateVariables() {
        for variable in _vars.keys {
            if let row = _rows[_vars[variable]!] {
                variable.value = row.constant
            } else {
                variable.value = 0
            }
        }
    }


    /**
     * Create a new Row object for the given constraint.
     * <p/>
     * The terms in the constraint will be converted to cells in the row.
     * Any term in the constraint with a coefficient of zero is ignored.
     * This method uses the `getVarSymbol` method to get the symbol for
     * the variables added to the row. If the symbol for a given cell
     * variable is basic, the cell variable will be substituted with the
     * basic row.
     * <p/>
     * The necessary slack and error variables will be added to the row.
     * If the constant for the row is negative, the sign for the row
     * will be inverted so the constant becomes positive.
     * <p/>
     * The tag will be updated with the marker and error symbols to use
     * for tracking the movement of the constraint in the tableau.
     */
    private func createRow(constraint: Constraint, tag: Tag) -> Row {
        let expression = constraint.expression
        let row = Row(constant: expression.constant)

        for term in expression.terms {
            if !term.coefficient.isNearZero {
                let symbol = getVarSymbol(term.variable)

                if let otherRow = _rows[symbol] {
                    row.insert(other: otherRow, coefficient: term.coefficient)
                } else {
                    row.insert(symbol: symbol, coefficient: term.coefficient)
                }
            }
        }

        switch constraint.op {
        case .greaterThanOrEqual, .lessThanOrEqual:
            let coeff = constraint.op == .lessThanOrEqual ? 1.0 : -1.0
            let slack = Symbol(.slack)
            tag.marker = slack
            row.insert(symbol: slack, coefficient: coeff)

            if constraint.strength < Strength.REQUIRED {
                let error = Symbol(.error)
                tag.other = error
                row.insert(symbol: error, coefficient: -coeff)
                _objective.insert(symbol: error, coefficient: constraint.strength)
            }
        case .equal:
            if constraint.strength < Strength.REQUIRED {
                let errplus = Symbol(.error)
                let errminus = Symbol(.error)
                tag.marker = errplus
                tag.other = errminus
                row.insert(symbol: errplus, coefficient: -1.0) // v = eplus - eminus
                row.insert(symbol: errminus, coefficient: 1.0) // v - eplus + eminus = 0
                _objective.insert(symbol: errplus, coefficient: constraint.strength)
                _objective.insert(symbol: errminus, coefficient: constraint.strength)
            } else {
                let dummy = Symbol(.dummy)
                tag.marker = dummy
                row.insert(symbol: dummy)
            }
        }

        // Ensure the row as a positive constant.
        if row.constant < 0.0 {
            row.reverseSign()
        }

        return row
    }

    /**
     Choose the subject for solving for the row

     This method will choose the best subject for using as the solve
     target for the row. An invalid symbol will be returned if there
     is no valid target.
     The symbols are chosen according to the following precedence:
     1) The first symbol representing an external variable.
     2) A negative slack or error tag variable.
     If a subject cannot be found, an invalid symbol will be returned.
     */
    private static func chooseSubject(row: Row, tag: Tag) -> Symbol {

        for cell in row.cells.orderedEntries {
            if cell.key.symbolType == .external {
                return cell.key
            }
        }

        if tag.marker.symbolType == .slack || tag.marker.symbolType == .error {
            if row.coefficientFor(tag.marker) < 0.0 {
                return tag.marker
            }
        }
        if tag.other != nil && (tag.other!.symbolType == .slack || tag.other!.symbolType == .error) {
            if row.coefficientFor(tag.other!) < 0.0 {
                return tag.other!
            }
        }

        return Symbol()
    }

    /**
     * Add the row to the tableau using an artificial variable.
     * <p/>
     * This will return false if the constraint cannot be satisfied.
     */
    private func addWithArtificialVariable(row: Row) throws -> Bool {

        // Create and add the artificial variable to the tableau

        let art = Symbol(.slack)
        _rows[art] = Row(row)

        _artificial = Row(row)

        // Optimize the artificial objective. This is successful
        // only if the artificial objective is optimized to zero.
        try optimize(objective: _artificial!)
        let success = _artificial!.constant.isNearZero
        _artificial = nil

        // If the artificial variable is basic, pivot the row so that
        // it becomes basic. If the row is constant, exit early.

        if let rowptr = _rows[art] {
            var deleteQueue = [Symbol]()
            for s in _rows.keys {
                if _rows[s]! == rowptr {
                    deleteQueue.append(s)
                }
            }

            while !deleteQueue.isEmpty {
                _rows[deleteQueue.popLast()!] = nil
            }

            deleteQueue.removeAll()

            if rowptr.cells.count == 0 {
                return success
            }

            let entering = anyPivotableSymbol(rowptr)
            if entering.symbolType == .invalid {
                return false // unsatisfiable (will this ever happen?)
            }

            rowptr.solveFor(art, entering)
            substitute(symbol: entering, row: rowptr)
            _rows[entering] = rowptr
        }

        // Remove the artificial variable from the tableau.
        for rowEntry in _rows.orderedEntries {
            rowEntry.value.remove(symbol: art)
        }

        _objective.remove(symbol: art)

        return success
    }

    /**
     Substitute the parametric symbol with the given row.

     This method will substitute all instances of the parametric symbol
     in the tableau and the objective function with the given row.
     */
    private func substitute(symbol: Symbol, row: Row) {
        for rowEntry in _rows.orderedEntries {
            rowEntry.value.substitute(symbol: symbol, row: row)

            if rowEntry.key.symbolType != .external && rowEntry.value.constant < 0.0 {
                _infeasibleRows.append(rowEntry.key)
            }
        }

        _objective.substitute(symbol: symbol, row: row)

        if _artificial != nil {
            _artificial!.substitute(symbol: symbol, row: row)
        }
    }

    /**
     Optimize the system for the given objective function.

     This method performs iterations of Phase 2 of the simplex method
     until the objective function reaches a minimum.
     */
    private func optimize(objective: Row) throws {
        while true {
            let entering = Solver.getEnteringSymbol(objective)
            if entering.symbolType == .invalid {
                return
            }

            guard let entry = getLeavingRow(entering) else {
                throw CassowaryError.internalSolver("The objective is unbounded.")
            }

            var leaving: Symbol?

            for key in _rows.keys {
                if _rows[key]! == entry {
                    leaving = key
                }
            }

            var entryKey: Symbol?

            for key in _rows.keys {
                if _rows[key]! == entry {
                    entryKey = key
                }
            }

            _rows[entryKey!] = nil
            entry.solveFor(leaving!, entering)
            substitute(symbol: entering, row: entry)
            _rows[entering] = entry
        }
    }

    private func dualOptimize() throws {
        while !_infeasibleRows.isEmpty {
            let leaving = _infeasibleRows.popLast()!

            if let row = _rows[leaving], row.constant < 0.0 {
                let entering = getDualEnteringSymbol(row)
                if entering.symbolType == .invalid {
                    throw CassowaryError.internalSolver("Internal solver error")
                }

                _rows[leaving] = nil
                row.solveFor(leaving, entering)
                substitute(symbol: entering, row: row)
                _rows[entering] = row
            }
        }
    }


    /**
     * Compute the entering variable for a pivot operation.
     * <p/>
     * This method will return first symbol in the objective function which
     * is non-dummy and has a coefficient less than zero. If no symbol meets
     * the criteria, it means the objective function is at a minimum, and an
     * invalid symbol is returned.
     */
    private static func getEnteringSymbol(_ objective: Row) -> Symbol {
        for cell in objective.cells.orderedEntries {
            if cell.key.symbolType != .dummy && cell.value < 0.0 {
                return cell.key
            }
        }

        return Symbol()
    }

    private func getDualEnteringSymbol(_ row: Row) -> Symbol {
        var entering = Symbol()

        var ratio = Double.greatestFiniteMagnitude

        for s in row.cells.keys {
            if s.symbolType != .dummy {
                let currentCell = row.cells[s]!
                if currentCell > 0.0 {
                    let coefficient = _objective.coefficientFor(s)
                    let r = coefficient / currentCell
                    if r < ratio {
                        ratio = r
                        entering = s
                    }
                }
            }
        }

        return entering
    }


    /**
     Get the first Slack or Error symbol in the row.

     sIf no such symbol is present, and Invalid symbol will be returned.
     */
    private func anyPivotableSymbol(_ row: Row) -> Symbol {
        var symbol: Symbol?

        for entry in row.cells.orderedEntries {
            if entry.key.symbolType == .slack || entry.key.symbolType == .error {
                symbol = entry.key
            }
        }

        if symbol == nil {
            symbol = Symbol()
        }

        return symbol!
    }

    /**
     Compute the row which holds the exit symbol for a pivot.

     This documentation is copied from the C++ version and is outdated

     This method will return an iterator to the row in the row map
     which holds the exit symbol. If no appropriate exit symbol is
     found, the end() iterator will be returned. This indicates that
     the objective function is unbounded.
     */
    private func getLeavingRow(_ entering: Symbol) -> Row? {
        var ratio = Double.greatestFiniteMagnitude
        var row: Row?

        for key in _rows.keys {
            if key.symbolType != .external {
                let candidateRow = _rows[key]!
                let temp = candidateRow.coefficientFor(entering)
                if temp < 0 {
                    let tempRatio = -candidateRow.constant / temp
                    if tempRatio < ratio {
                        ratio = tempRatio
                        row = candidateRow
                    }
                }
            }
        }

        return row
    }

    /**
     * Get the symbol for the given variable.
     * <p/>
     * If a symbol does not exist for the variable, one will be created.
     */
    private func getVarSymbol(_ variable: Variable) -> Symbol {
        if let symbol = _vars[variable] {
            return symbol
        } else {
            let symbol = Symbol(.external)
            _vars[variable] = symbol
            return symbol
        }
    }

    /**
     Test whether a row is composed of all dummy variables.
     */
    private static func allDummies(row: Row) -> Bool {
        for cell in row.cells.orderedEntries {
            if cell.key.symbolType != .dummy {
                return false
            }
        }
        return true
    }

}
