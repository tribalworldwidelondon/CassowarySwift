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

extension Term {
    convenience init(variable: Variable, coefficient: CGFloat) {
        self.init(variable: variable, coefficient: Double(coefficient))
    }
}

extension Expression {
    convenience init(constant: CGFloat) {
        self.init(constant: Double(constant))
    }
}

// MARK: - Variable *, /, and unary invert

public func * (_ variable: Variable, _ coefficient: CGFloat) -> Term {
    return Term(variable: variable, coefficient: coefficient)
        .addingDebugDescription("\(variable.name) * \(coefficient)")
}

public func / (_ variable: Variable, _ denominator: CGFloat) -> Term {
    return (variable * (1.0 / denominator))
        .addingDebugDescription("\(variable.name) / \(denominator)")
}

// Term *, /, and unary invert
public func * (_ term: Term, _ coefficient: CGFloat) -> Term {
    return Term(variable: term.variable, coefficient: term.coefficient * Double(coefficient))
        .addingDebugDescription("(\(term.debugDescription)) * \(coefficient)")
}

public func / (_ term: Term, _ denominator: CGFloat) -> Term {
    return (term * (1.0 / denominator))
        .addingDebugDescription("(\(term.debugDescription)) / \(denominator)")
}

// MARK: - Expression *, /, and unary invert
public func * (_ expression: Expression, _ coefficient: CGFloat) -> Expression {
    var terms = [Term]()
    for term in expression.terms {
        terms.append(term * coefficient)
    }
    
    // TODO: Do we need to make a copy of the term objects in the array?
    return Expression(terms: terms, constant: expression.constant * Double(coefficient))
        .addingDebugDescription("(\(expression.debugDescription)) * \(coefficient)")
}

public func / (_ expression: Expression, _ denominator: CGFloat) -> Expression {
    return (expression * (1.0 / denominator))
        .addingDebugDescription("(\(expression.debugDescription)) / \(denominator)")
}

// MARK: - CGFloat *
public func * (_ coefficient: CGFloat, _ expression: Expression) -> Expression {
    return (expression * coefficient)
        .addingDebugDescription("(\(expression.debugDescription)) * \(coefficient)")
}


public func * (_ coefficient: CGFloat, _ term: Term) -> Term {
    return (term * coefficient)
        .addingDebugDescription("\(coefficient) * (\(term.debugDescription))")
}


public func * (_ coefficient: CGFloat, _ variable: Variable) -> Term {
    return (variable * coefficient)
        .addingDebugDescription("\(coefficient) * \(variable.name)")
}

public func + (_ expression: Expression, _ constant: CGFloat) -> Expression {
    return Expression(terms: expression.terms, constant: expression.constant + Double(constant))
        .addingDebugDescription("(\(expression.debugDescription))¨ + \(constant)")
}

public func - (_ expression: Expression, _ constant: CGFloat) -> Expression{
    return (expression + -constant)
        .addingDebugDescription("(\(expression.debugDescription)) - \(constant)")
}

public func + (_ term: Term, _ constant: CGFloat) -> Expression {
    return Expression(term: term, constant: Double(constant))
        .addingDebugDescription("(\(term.debugDescription)) + \(constant)")
}

public func - (_ term: Term, _ constant: CGFloat) -> Expression {
    return (term + -constant)
        .addingDebugDescription("(\(term.debugDescription)) - \(constant)")
}

public func + (_ variable: Variable, _ constant: CGFloat) -> Expression {
    return (Term(variable: variable) + constant)
        .addingDebugDescription("\(variable.name) + \(constant)")
}

public func - (_ variable: Variable, _ constant: CGFloat) -> Expression {
    return (variable + -constant)
        .addingDebugDescription("\(variable.name) - \(constant)")
}

// MARK: - CGFloat + and -
public func + (_ constant: CGFloat, _ expression: Expression) -> Expression {
    return (expression + constant)
        .addingDebugDescription("\(constant) + (\(expression.debugDescription))")
}

public func + (_ constant: CGFloat, _ term: Term) -> Expression {
    return (term + constant)
        .addingDebugDescription("\(constant) + (\(term.debugDescription))")
}

public func + (_ constant: CGFloat, _ variable: Variable) -> Expression {
    return (variable + constant)
        .addingDebugDescription("\(constant) + \(variable.name)")
}

public func - (_ constant: CGFloat, _ expression: Expression) -> Expression {
    return (-expression + constant)
        .addingDebugDescription("\(constant) - (\(expression.debugDescription))")
}

public func - (_ constant: CGFloat, _ term: Term) -> Expression {
    return (-term + constant)
        .addingDebugDescription("\(constant) - (\(term.debugDescription))")
}

public func - (_ constant: CGFloat, _ variable: Variable) -> Expression {
    return (-variable + constant)
        .addingDebugDescription("\(constant) - \(variable.name)")
}

public func == (_ expression: Expression, _ constant: CGFloat) -> Constraint {
    return (expression == Expression(constant: constant))
        .addingDebugDescription("\(expression.debugDescription) == \(constant)")
}

public func <= (_ expression: Expression, _ constant: CGFloat) -> Constraint {
    return (expression <= Expression(constant: constant))
        .addingDebugDescription("\(expression.debugDescription) <= \(constant)")
}

public func >= (_ expression: Expression, _ constant: CGFloat) -> Constraint {
    return (expression >= Expression(constant: constant))
        .addingDebugDescription("\(expression.debugDescription) >= \(constant)")
}

public func == (_ term: Term, _ constant: CGFloat) -> Constraint {
    return (Expression(term: term) == constant)
        .addingDebugDescription("\(term.debugDescription) == \(constant)")
}

public func <= (_ term: Term, _ constant: CGFloat) -> Constraint {
    return (Expression(term: term) <= constant)
        .addingDebugDescription("\(term.debugDescription) <= \(constant))")
}

public func >= (_ term: Term, _ constant: CGFloat) -> Constraint {
    return (Expression(term: term) >= constant)
        .addingDebugDescription("\(term.debugDescription) >= \(constant)")
}

public func == (_ variable: Variable, _ constant: CGFloat) -> Constraint{
    return (Term(variable: variable) == constant)
        .addingDebugDescription("\(variable.name) == \(constant)")
}

public func <= (_ variable: Variable, _ constant: CGFloat) -> Constraint {
    return (Term(variable: variable) <= constant)
        .addingDebugDescription("\(variable.name) <= \(constant)")
}

public func >= (_ variable: Variable, _ constant: CGFloat) -> Constraint {
    return (Term(variable: variable) >= constant)
        .addingDebugDescription("\(variable.name) >= \(constant)")
}

// MARK: - CGFloat relations
public func == (_ constant: CGFloat, _ expression: Expression) -> Constraint {
    return (expression == constant)
        .addingDebugDescription("\(constant) == \(expression.debugDescription)")
}

public func == (_ constant: CGFloat, _ term: Term) -> Constraint {
    return (term == constant)
        .addingDebugDescription("\(constant) == \(term.debugDescription)")
}

public func == (_ constant: CGFloat, _ variable: Variable) -> Constraint {
    return (variable == constant)
        .addingDebugDescription("\(constant) == \(variable.name)")
}

public func <= (_ constant: CGFloat, _ expression: Expression) -> Constraint {
    return (Expression(constant: constant) <= expression)
        .addingDebugDescription("\(constant) <= \(expression.debugDescription)")
}

public func <= (_ constant: CGFloat, _ term: Term) -> Constraint {
    return (constant <= Expression(term: term))
        .addingDebugDescription("\(constant) <= \(term.debugDescription)")
}

public func <= (_ constant: CGFloat, _ variable: Variable) -> Constraint {
    return (constant <= Term(variable: variable))
        .addingDebugDescription("\(constant) <= \(variable.name)")
}

public func >= (_ constant: CGFloat, _ term: Term) -> Constraint {
    return (Expression(constant: constant) >= term)
        .addingDebugDescription("\(constant) >= \(term.debugDescription)")
}

public func >= (_ constant: CGFloat, _ variable: Variable) -> Constraint {
    return (constant >= Term(variable: variable))
        .addingDebugDescription("\(constant) >= \(variable.name)")
}

// MARK: - Constraint strength modifier
public func modifyStrength(_ constraint: Constraint, _ strength: CGFloat) -> Constraint {
    return Constraint(other: constraint, strength: Double(strength))
}

public func modifyStrength(_ strength: CGFloat, _ constraint: Constraint) -> Constraint {
    return modifyStrength(constraint, strength)
}
