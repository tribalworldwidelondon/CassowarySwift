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

/**
 This is a class that describes a constraint placed on a number of variables in the solver system.
 */
public class Constraint: CassowaryDebugDescription, CustomStringConvertible {
    internal var debugDescription: String = ""
    
    internal func addingDebugDescription(_ desc: String) -> Self {
        debugDescription = desc
        return self
    }
    
    /// :nodoc:
    public var description: String {
        if debugDescription.count > 0 {
            return "Constraint<\(debugDescription) | Strength: \(Strength.readableString(strength))>"
        }
        
        return "Constraint<(\(expression)) | strength: \(Strength.readableString(strength)) | operator: \(op)>"
    }
    
    /// The expression held by the constraint
    private(set) var expression: Expression

    /// The strength of the constraint
    public var strength: Double

    /// The operator of the constraint
    private(set) var op: RelationalOperator
    
    /// Create a constraint with the given expression and operator
    public convenience init(expr: Expression, op: RelationalOperator) {
        self.init(expr: expr, op: op, strength: Strength.REQUIRED)
    }
    
    /// Create a constraint with the given expression, operator and strength
    public init(expr: Expression, op: RelationalOperator, strength: Double) {
        self.expression = Constraint.reduce(expr)
        self.op = op
        self.strength = Strength.clip(strength)
    }
    
    /// Create a constraint, copying the provided constraint, with the given strength
    public convenience init(other: Constraint, strength: Double) {
        self.init(expr: other.expression, op: other.op, strength: strength)
    }

    private static func reduce(_ expr: Expression) -> Expression {
        var vars = OrderedDictionary<Variable, Double>()

        for term in expr.terms {
            var value = vars[term.variable]
            if value == nil {
                value = 0.0
            }
            value! += term.coefficient
            vars[term.variable] = value!
        }

        let reducedTerms = vars.keys.map {
            Term(variable: $0, coefficient: vars[$0]!)
        }

        return Expression(terms: reducedTerms, constant: expr.constant)
    }
    
    /// Set the strength of the constraint
    public func setStrength(_ newStrength: Double) -> Constraint {
        self.strength = newStrength
        return self
    }

}

// MARK: Equatable
extension Constraint: Equatable {
    /// :nodoc:
    public static func == (lhs: Constraint, rhs: Constraint) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }

}

// MARK: Hashable
extension Constraint: Hashable {
    /// :nodoc:
    public var hashValue: Int {
        // Return a hash 'unique' to this object
        return ObjectIdentifier(self).hashValue
    }

}


// MARK: - EditConstraint

internal final class EditConstraint: Constraint {
    internal var suggestedValue: Double?
    
    /// :nodoc:
    override public var description: String {
        if debugDescription.count > 0 {
            return "EditConstraint<\(debugDescription) | Strength: \(Strength.readableString(strength))>"
        }
        
        return "EditConstraint<\(expression) == \(suggestedValue ?? 0) | Strength: \(Strength.readableString(strength))>"
    }
}
