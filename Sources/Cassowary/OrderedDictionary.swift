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

// Based on the implementation by Michael Kyriacou at
// http://codeforcaffeine.com/programming/swift-3-ordered-dictionary/

import Foundation

public final class OrderedDictionary<KeyType: Hashable, ValueType>: ExpressibleByDictionaryLiteral {
    var keys = [KeyType]()
    fileprivate var dictionary = [KeyType: ValueType]()
    
    public var count: Int { return keys.count }
    
    private var _cachedOrderedEntries: [(key: KeyType, value: ValueType)]? = nil
    public var orderedEntries: [(key: KeyType, value: ValueType)] {
        if _cachedOrderedEntries == nil {
            _cachedOrderedEntries = keys.map {
                (key: $0, value: dictionary[$0]!)
            }
        }
        return _cachedOrderedEntries!
    }
    
    public required init(dictionaryLiteral elements: (KeyType, ValueType)...) {
        for (k, v) in elements {
            self[k] = v
        }
    }
    
    public subscript(key: KeyType) -> ValueType? {
        get { return self.dictionary[key] }
        set {
            _cachedOrderedEntries = nil
            if let v = newValue {
                let oldVal = self.dictionary.updateValue(v, forKey: key)
                if oldVal == nil {
                    self.keys.append(key)
                }
            } else {
                self.dictionary.removeValue(forKey: key)
                keys = keys.filter { $0 != key }
            }
        }
    }
    
    public init(_ dict: OrderedDictionary<KeyType, ValueType>) {
        self.keys = dict.keys
        self.dictionary = dict.dictionary
    }
}

extension OrderedDictionary: Sequence {
    
    public func makeIterator() -> AnyIterator<ValueType> {
        var counter = 0
        return AnyIterator {
            guard counter < self.keys.count else {
                return nil
            }
            
            let next = self.dictionary[self.keys[counter]]
            counter += 1
            return next
        }
    }
    
}
