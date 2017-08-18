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

public enum CassowaryError: Error {
    /// An internal error.
    case internalError(String)
    
    /// The constraint is a non-linear expression, which isn't supported
    case nonLinear
    
    /// The constraint is not added to the solver
    case unknownConstraint(Constraint)
    
    /// The constraint already exists in the solver
    case duplicateConstraint(Constraint)
    
    /// The constraint cannot be satisfied by the solver
    case unsatisfiableConstraint(Constraint, [Constraint])
    
    /// The variable has not been added as an edit variable
    case unknownEditVariable
    
    /// The variable has already been added as an edit variable
    case duplicateEditVariable
    
    /// The strength cannot be set to 'Required'
    case requiredFailure
    
    /// An internal solver error.
    case internalSolver(String)

    /// Provides a more detailed description of the error
    public func detailedDescription() -> String {
        switch self {
        case .unsatisfiableConstraint(let constraint, let allConstraints):
            return describeUnsatisfiableConstraint(constraint, allConstraints: allConstraints)

        default:
            return String(describing: self)
        }
    }

    private func describeUnsatisfiableConstraint(_ constraint: Constraint, allConstraints: [Constraint]) -> String {
        let otherConstraints = allConstraints.filter { $0 != constraint }

        var output = [
            "Unable to simultanously satisfy constraints.",
            "\tConflicting constraint: \(constraint)",
            "\t\n",
            "\tThe constraint conflicts with one of the following"]
        output.append(contentsOf: otherConstraints.map { "\t\t\($0)"})

        return output.joined(separator: "\n")
    }

}
