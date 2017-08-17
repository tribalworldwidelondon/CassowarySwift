//
//  CassowaryDebugDescription.swift
//  CassowaryTests
//
//  Created by Andy Best on 08/08/2017.
//

import Foundation

protocol CassowaryDebugDescription {
    var debugDescription: String { get set }
    
    func addingDebugDescription(_ desc: String) -> Self
}
