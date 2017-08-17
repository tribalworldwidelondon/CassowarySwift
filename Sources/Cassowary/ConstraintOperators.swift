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

// MARK: - Variable *, /, and unary invert
public func * (_ variable: Variable, _ coefficient: Double) -> Term {
    return Term(variable: variable, coefficient: coefficient)
        .addingDebugDescription("\(variable.name) * \(coefficient)")
}

public func / (_ variable: Variable, _ denominator: Double) -> Term {
    return (variable * (1.0 / denominator))
        .addingDebugDescription("\(variable.name) / \(denominator)")
}

public prefix func - (_ variable: Variable) -> Term {
    return (variable * -1.0)
        .addingDebugDescription("-\(variable.name)")
}

// Term *, /, and unary invert
public func * (_ term: Term, _ coefficient: Double) -> Term {
    return Term(variable: term.variable, coefficient: term.coefficient * coefficient)
        .addingDebugDescription("(\(term.debugDescription)) * \(coefficient)")
}

public func / (_ term: Term, _ denominator: Double) -> Term {
    return (term * (1.0 / denominator))
        .addingDebugDescription("(\(term.debugDescription)) / \(denominator)")
}

public prefix func - (_ term: Term) -> Term {
    return (term * -1.0)
        .addingDebugDescription("-(\(term.debugDescription))")
}

// MARK: - Expression *, /, and unary invert
public func * (_ expression: Expression, _ coefficient: Double) -> Expression {
    var terms = [Term]()
    for term in expression.terms {
        terms.append(term * coefficient)
    }

    // TODO: Do we need to make a copy of the term objects in the array?
    return Expression(terms: terms, constant: expression.constant * coefficient)
        .addingDebugDescription("(\(expression.debugDescription)) * \(coefficient)")
}

public func * (_ expression1: Expression, _ expression2: Expression) throws -> Expression {
    if expression1.isConstant {
        return expression1.constant * expression2
    } else if expression2.isConstant {
        return expression2.constant * expression1
    } else {
        throw CassowaryError.nonLinear
    }
}

public func / (_ expression: Expression, _ denominator: Double) -> Expression {
    return (expression * (1.0 / denominator))
        .addingDebugDescription("(\(expression.debugDescription)) / \(denominator)")
}

public func / (_ expression1: Expression, _ expression2: Expression) throws -> Expression {
    if expression2.isConstant {
        return expression1 / expression2.constant
    } else {
        throw CassowaryError.nonLinear
    }
}

public prefix func - (_ expression: Expression) -> Expression {
    return (expression * -1.0)
        .addingDebugDescription("-(\(expression.debugDescription))")
}

// MARK: - Double *
public func * (_ coefficient: Double, _ expression: Expression) -> Expression {
    return (expression * coefficient)
        .addingDebugDescription("(\(expression.debugDescription)) * \(coefficient)")
}


public func * (_ coefficient: Double, _ term: Term) -> Term {
    return (term * coefficient)
        .addingDebugDescription("\(coefficient) * (\(term.debugDescription))")
}


public func * (_ coefficient: Double, _ variable: Variable) -> Term {
    return (variable * coefficient)
        .addingDebugDescription("\(coefficient) * \(variable.name)")
}

// MARK: - Expression + and -
public func + (_ first: Expression, _ second: Expression) -> Expression {
    // TODO: do we need to copy term objects?

    var terms = [Term]()
    terms.append(contentsOf: first.terms)
    terms.append(contentsOf: second.terms)

    return Expression(terms: terms, constant: first.constant + second.constant)
        .addingDebugDescription("(\(first.debugDescription)) + (\(second.debugDescription))")
}

public func + (_ first: Expression, _ second: Term) -> Expression {
    // TODO: do we need to copy term objects?

    var terms = [Term]()

    terms.append(contentsOf: first.terms)
    terms.append(second)

    return Expression(terms: terms, constant: first.constant)
        .addingDebugDescription("(\(first.debugDescription)) + (\(second.debugDescription))")
}

public func + (_ expression: Expression, _ variable: Variable) -> Expression {
    return (expression + Term(variable: variable))
        .addingDebugDescription("(\(expression.debugDescription)) + \(variable.name)")
}

public func + (_ expression: Expression, _ constant: Double) -> Expression {
    return Expression(terms: expression.terms, constant: expression.constant + constant)
        .addingDebugDescription("(\(expression.debugDescription))¨ + \(constant)")
}

public func - (_ first: Expression, _ second: Expression) -> Expression {
    return (first + -second)
        .addingDebugDescription("(\(first.debugDescription)) - (\(second.debugDescription))")
}

public func - (_ expression: Expression, _ term: Term) -> Expression {
    return (expression + -term)
        .addingDebugDescription("(\(expression.debugDescription)) - (\(term.debugDescription))")
}

public func - (_ expression: Expression, _ variable: Variable) -> Expression{
    return (expression + -variable)
        .addingDebugDescription("(\(expression.debugDescription)) - \(variable.name)")
}

public func - (_ expression: Expression, _ constant: Double) -> Expression{
    return (expression + -constant)
        .addingDebugDescription("(\(expression.debugDescription)) - \(constant)")
}

// MARK: - Term + and -
public func + (_ term: Term, _ expression: Expression) -> Expression {
    return (expression + term)
        .addingDebugDescription("(\(term.debugDescription)) + (\(expression.debugDescription))")
}

public func + (_ first: Term, _ second: Term) -> Expression {
    var terms = [Term]()
    terms.append(first)
    terms.append(second)
    return Expression(terms: terms)
        .addingDebugDescription("(\(first.debugDescription)) + (\(second.debugDescription))")
}

public func + (_ term: Term, _ variable: Variable) -> Expression {
    return (term + Term(variable: variable))
        .addingDebugDescription("(\(term.debugDescription)) + \(variable.name)")
}

public func + (_ term: Term, _ constant: Double) -> Expression {
    return Expression(term: term, constant: constant)
        .addingDebugDescription("(\(term.debugDescription)) + \(constant)")
}

public func - (_ term: Term, _ expression: Expression) -> Expression {
    return (-expression + term)
        .addingDebugDescription("(\(term.debugDescription)) - (\(expression.debugDescription))")
}

public func - (_ first: Term, _ second: Term) -> Expression {
    return (first + -second)
        .addingDebugDescription("(\(first.debugDescription)) - (\(second.debugDescription))")
}

public func - (_ term: Term, _ variable: Variable) -> Expression {
    return (term + -variable)
        .addingDebugDescription("(\(term.debugDescription)) - \(variable.name)")
}

public func - (_ term: Term, _ constant: Double) -> Expression {
    return (term + -constant)
        .addingDebugDescription("(\(term.debugDescription)) - \(constant)")
}

// MARK: - Variable + and -
public func + (_ variable: Variable, _ expression: Expression) -> Expression {
    return (expression + variable)
        .addingDebugDescription("\(variable.name) + (\(expression.debugDescription))")
}

public func + (_ variable: Variable, _ term: Term) -> Expression {
    return (term + variable)
        .addingDebugDescription("\(variable.name) + (\(term.debugDescription))")
}

public func + (_ first: Variable, _ second: Variable) -> Expression {
    return (Term(variable: first) + second)
        .addingDebugDescription("\(first.name) + \(second.name)")
}

public func + (_ variable: Variable, _ constant: Double) -> Expression {
    return (Term(variable: variable) + constant)
        .addingDebugDescription("\(variable.name) + \(constant)")
}

public func - (_ variable: Variable, _ expression: Expression) -> Expression {
    return (variable + -expression)
        .addingDebugDescription("\(variable.name) - (\(expression.debugDescription))")
}

public func - (_ variable: Variable, _ term: Term) -> Expression {
    return (variable + -term)
        .addingDebugDescription("\(variable.name) - (\(term.debugDescription))")
}

public func - (_ first: Variable, _ second: Variable) -> Expression {
    return (first + -second)
        .addingDebugDescription("\(first.name) - \(second.name)")
}

public func - (_ variable: Variable, _ constant: Double) -> Expression {
    return (variable + -constant)
        .addingDebugDescription("\(variable.name) - \(constant)")
}

// MARK: - Double + and -
public func + (_ constant: Double, _ expression: Expression) -> Expression {
    return (expression + constant)
        .addingDebugDescription("\(constant) + (\(expression.debugDescription))")
}

public func + (_ constant: Double, _ term: Term) -> Expression {
    return (term + constant)
        .addingDebugDescription("\(constant) + (\(term.debugDescription))")
}

public func + (_ constant: Double, _ variable: Variable) -> Expression {
    return (variable + constant)
        .addingDebugDescription("\(constant) + \(variable.name)")
}

public func - (_ constant: Double, _ expression: Expression) -> Expression {
    return (-expression + constant)
        .addingDebugDescription("\(constant) - (\(expression.debugDescription))")
}

public func - (_ constant: Double, _ term: Term) -> Expression {
    return (-term + constant)
        .addingDebugDescription("\(constant) - (\(term.debugDescription))")
}

public func - (_ constant: Double, _ variable: Variable) -> Expression {
    return (-variable + constant)
        .addingDebugDescription("\(constant) - \(variable.name)")
}

// MARK: - Expression relations
public func == (_ first: Expression, _ second: Expression) -> Constraint {
    return Constraint(expr: first - second, op: .equal)
        .addingDebugDescription("\(first.debugDescription) == \(second.debugDescription)")
}

public func == (_ expression: Expression, _ term: Term) -> Constraint {
    return (expression == Expression(term: term))
        .addingDebugDescription("\(expression.debugDescription) == \(term.debugDescription)")
}

public func == (_ expression: Expression, _ variable: Variable) -> Constraint {
    return (expression == Term(variable: variable))
        .addingDebugDescription("\(expression.debugDescription) == \(variable.name)")
}

public func == (_ expression: Expression, _ constant: Double) -> Constraint {
    return (expression == Expression(constant: constant))
        .addingDebugDescription("\(expression.debugDescription) == \(constant)")
}

public func <= (_ first: Expression, _ second: Expression) -> Constraint {
    return Constraint(expr: first - second, op: .lessThanOrEqual)
        .addingDebugDescription("\(first.debugDescription) <= \(second.debugDescription)")
}

public func <= (_ expression: Expression, _ term: Term) -> Constraint {
    return (expression <= Expression(term: term))
        .addingDebugDescription("\(expression.debugDescription) <=>= \(term.debugDescription)")
}

public func <= (_ expression: Expression, _ variable: Variable) -> Constraint {
    return (expression <= Term(variable: variable))
        .addingDebugDescription("\(expression.debugDescription) <= \(variable.name)")
}

public func <= (_ expression: Expression, _ constant: Double) -> Constraint {
    return (expression <= Expression(constant: constant))
        .addingDebugDescription("\(expression.debugDescription) <= \(constant)")
}

public func >= (_ first: Expression, _ second: Expression) -> Constraint {
    return (Constraint(expr: first - second, op: .greaterThanOrEqual))
        .addingDebugDescription("\(first.debugDescription) >= \(second.debugDescription)")
}

public func >= (_ expression: Expression, _ term: Term) -> Constraint {
    return (expression >= Expression(term: term))
        .addingDebugDescription("\(expression.debugDescription) >= \(term.debugDescription)")
}

public func >= (_ expression: Expression, _ variable: Variable) -> Constraint {
    return (expression >= Term(variable: variable))
        .addingDebugDescription("\(expression.debugDescription) >= \(variable.name)")
}

public func >= (_ expression: Expression, _ constant: Double) -> Constraint {
    return (expression >= Expression(constant: constant))
        .addingDebugDescription("\(expression.debugDescription) >= \(constant)")
}

// MARK: - Term relations
public func == (_ term: Term, _ expression: Expression) -> Constraint {
    return (expression == term)
        .addingDebugDescription("\(term.debugDescription) == \(expression.debugDescription)")
}

public func == (_ first: Term, _ second: Term) -> Constraint {
    return (Expression(term: first) == second)
        .addingDebugDescription("\(first.debugDescription) == \(second.debugDescription)")
}

public func == (_ term: Term, _ variable: Variable) -> Constraint {
    return (Expression(term: term) == variable)
        .addingDebugDescription("\(term.debugDescription) == \(variable.value)")
}

public func == (_ term: Term, _ constant: Double) -> Constraint {
    return (Expression(term: term) == constant)
        .addingDebugDescription("\(term.debugDescription) == \(constant)")
}

public func <= (_ term: Term, _ expression: Expression) -> Constraint {
    return (Expression(term: term) <= expression)
        .addingDebugDescription("\(term.debugDescription) <= \(expression.debugDescription)")
}

public func <= (_ first: Term, _ second: Term) -> Constraint {
    return (Expression(term: first) <= second)
        .addingDebugDescription("\(first.debugDescription) <= \(second.debugDescription)")
}

public func <= (_ term: Term, _ variable: Variable) -> Constraint {
    return (Expression(term: term) <= variable)
        .addingDebugDescription("\(term.debugDescription) <= \(variable.name)")
}

public func <= (_ term: Term, _ constant: Double) -> Constraint {
    return (Expression(term: term) <= constant)
        .addingDebugDescription("\(term.debugDescription) <= \(constant))")
}

public func >= (_ term: Term, _ expression: Expression) -> Constraint {
    return (Expression(term: term) <= expression)
        .addingDebugDescription("\(term.debugDescription) >= \(expression.debugDescription)")
}


public func >= (_ first: Term, _ second: Term) -> Constraint {
    return (Expression(term: first) >= second)
        .addingDebugDescription("\(first.debugDescription) >= \(second.debugDescription)")
}

public func >= (_ term: Term, _ variable: Variable) -> Constraint {
    return (Expression(term: term) >= variable)
        .addingDebugDescription("\(term.debugDescription) >= \(variable.name)")
}

public func >= (_ term: Term, _ constant: Double) -> Constraint {
    return (Expression(term: term) >= constant)
        .addingDebugDescription("\(term.debugDescription) >= \(constant)")
}

// MARK: - Variable relations
public func == (_ variable: Variable, _ expression: Expression) -> Constraint {
    return (expression == variable)
        .addingDebugDescription("\(variable.name) == \(expression.debugDescription)")
}

public func == (_ variable: Variable, _ term: Term) -> Constraint {
    return (term == variable)
        .addingDebugDescription("\(variable.name) == \(term.debugDescription)")
}

public func == (_ first: Variable, _ second: Variable) -> Constraint {
    return (Term(variable: first) == second)
        .addingDebugDescription("\(first.name) == \(second.name)")
}

public func == (_ variable: Variable, _ constant: Double) -> Constraint{
    return (Term(variable: variable) == constant)
        .addingDebugDescription("\(variable.name) == \(constant)")
}

public func <= (_ variable: Variable, _ expression: Expression) -> Constraint {
    return (Term(variable: variable) <= expression)
        .addingDebugDescription("\(variable.name) <= \(expression.debugDescription)")
}

public func <= (_ variable: Variable, _ term: Term) -> Constraint {
    return (Term(variable: variable) <= term)
        .addingDebugDescription("\(variable.name) <= \(term.debugDescription)")
}

public func <= (_ first: Variable, _ second: Variable) -> Constraint {
    return (Term(variable: first) <= second)
        .addingDebugDescription("\(first.name) <= \(second.name)")
}

public func <= (_ variable: Variable, _ constant: Double) -> Constraint {
    return (Term(variable: variable) <= constant)
        .addingDebugDescription("\(variable.name) <= \(constant)")
}

public func >= (_ variable: Variable, _ expression: Expression) -> Constraint {
    return (Term(variable: variable) >= expression)
        .addingDebugDescription("\(variable.name) >= \(expression.debugDescription)")
}

public func >= (_ variable: Variable, _ term: Term) -> Constraint {
    return (term >= variable)
        .addingDebugDescription("\(variable.name) >= \(term.debugDescription)")
}

public func >= (_ first: Variable, _ second: Variable) -> Constraint {
    return (Term(variable: first) >= second)
        .addingDebugDescription("\(first.name) >= \(second.name)")
}

public func >= (_ variable: Variable, _ constant: Double) -> Constraint {
    return (Term(variable: variable) >= constant)
        .addingDebugDescription("\(variable.name) >= \(constant)")
}

// MARK: - Double relations
public func == (_ constant: Double, _ expression: Expression) -> Constraint {
    return (expression == constant)
        .addingDebugDescription("\(constant) == \(expression.debugDescription)")
}

public func == (_ constant: Double, _ term: Term) -> Constraint {
    return (term == constant)
        .addingDebugDescription("\(constant) == \(term.debugDescription)")
}

public func == (_ constant: Double, _ variable: Variable) -> Constraint {
    return (variable == constant)
        .addingDebugDescription("\(constant) == \(variable.name)")
}

public func <= (_ constant: Double, _ expression: Expression) -> Constraint {
    return (Expression(constant: constant) <= expression)
        .addingDebugDescription("\(constant) <= \(expression.debugDescription)")
}

public func <= (_ constant: Double, _ term: Term) -> Constraint {
    return (constant <= Expression(term: term))
        .addingDebugDescription("\(constant) <= \(term.debugDescription)")
}

public func <= (_ constant: Double, _ variable: Variable) -> Constraint {
    return (constant <= Term(variable: variable))
        .addingDebugDescription("\(constant) <= \(variable.name)")
}

public func >= (_ constant: Double, _ term: Term) -> Constraint {
    return (Expression(constant: constant) >= term)
        .addingDebugDescription("\(constant) >= \(term.debugDescription)")
}

public func >= (_ constant: Double, _ variable: Variable) -> Constraint {
    return (constant >= Term(variable: variable))
        .addingDebugDescription("\(constant) >= \(variable.name)")
}

// MARK: - Constraint strength modifier
public func modifyStrength(_ constraint: Constraint, _ strength: Double) -> Constraint {
    return Constraint(other: constraint, strength: strength)
}

public func modifyStrength(_ strength: Double, _ constraint: Constraint) -> Constraint {
    return modifyStrength(strength, constraint)
}
