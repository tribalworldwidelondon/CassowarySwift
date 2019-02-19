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

public final class Variable: CustomStringConvertible {
    private weak var _owner: AnyObject?
    
    private var _name: String?
    public var name: String {
        if _owner != nil {
            let typeName = String(describing: type(of: _owner!))
            var ident = ObjectIdentifier(_owner!).debugDescription
            ident = ident.replacingOccurrences(of: "ObjectIdentifier(", with: "")
            ident = ident.replacingOccurrences(of: ")", with: "")
            
            let varIdent = "\(typeName)(\(ident)).\(_name ?? "?")"
            return varIdent
        }
        return _name ?? "\(value)"
    }

    public var value: Double = 0.0

    public var description: String {
        return "\(name)"
    }

    public init(_ name: String) {
        _name = name
    }

    public init(_ value: Double) {
        self.value = value
    }
    
    public init(_ name: String, owner: AnyObject) {
        _name = name
        _owner = owner
    }

}

// MARK: Equatable
extension Variable: Equatable {

    public static func == (lhs: Variable, rhs: Variable) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }

}

// MARK: Hashable
extension Variable: Hashable {

    public var hashValue: Int {
        // Return a hash 'unique' to this object
        return ObjectIdentifier(self).hashValue
    }

}
