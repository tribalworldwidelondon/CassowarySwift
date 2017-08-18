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

public class Expression: CustomStringConvertible, CassowaryDebugDescription {
    private weak var _owner: AnyObject?
    
    private var _desc: String?
    var debugDescription: String {
        get {
            if _alias != nil && _owner != nil {
                let typeName = String(describing: type(of: _owner!))
                var ident = ObjectIdentifier(_owner!).debugDescription
                ident = ident.replacingOccurrences(of: "ObjectIdentifier(", with: "")
                ident = ident.replacingOccurrences(of: ")", with: "")
                
                let varIdent = "\(typeName)(\(ident)).\(_alias ?? "?")"
                return varIdent
            }
            
            return _alias ?? _desc ?? ""
        }
        
        set {
            _desc = newValue
        }
    }
    
    func addingDebugDescription(_ desc: String) -> Self {
        debugDescription = desc
        return self
    }
    

    private var _terms: [Term] = []
    public var terms: [Term] {
        get { return _terms }
        set { _terms = newValue }
    }

    private var _constant: Double
    public var constant: Double {
        get { return _constant }
        set { _constant = newValue }
    }

    public var value: Double {
        return terms.reduce(_constant) { result, term in
            result + term.value
        }
    }
    
    private var _alias: String? = nil

    public var isConstant: Bool {
        return terms.count == 0
    }
    
    /// :nodoc:
    public var description: String {
        if _alias != nil {
            return _alias!
        }
        
        var parts: [String] = [String]()
        
        if !self.constant.isApproximately(value: 0.0) || self.isConstant {
            parts.append(String(self.constant))
        }
        
        let termValues: [(Variable, Double)] = terms.map { ($0.variable, $0.coefficient) }.sorted {
            $0.0.name < $1.0.name
        }
        
        for (variable, coefficient) in termValues {
            let ceStr: String = String(coefficient)
            
            if coefficient.isApproximately(value: 1.0) {
                parts.append(String(describing: variable))
            } else {
                parts.append("\(ceStr) * \(String(describing: variable))")
            }
        }
        
        return parts.joined(separator: " + ")
    }

    // MARK: Initializers

    public convenience init() {
        self.init(constant: 0)
    }

    public init(constant: Double) {
        _constant = constant
    }

    public init(term: Term, constant: Double) {
        _constant = constant
        _terms.append(term)
    }

    public convenience init(term: Term) {
        self.init(term: term, constant: 0.0)
    }

    public init(terms: [Term], constant: Double) {
        _constant = constant
        _terms = terms
    }

    public convenience init(terms: [Term]) {
        self.init(terms: terms, constant: 0)
    }
    
    // MARK: Alias
    
    public func setAlias(_ alias: String?, owner: AnyObject?) -> Expression {
        _alias = alias
        _owner = owner
        return self
    }
}
