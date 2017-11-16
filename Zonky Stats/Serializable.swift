//
//  Serializable.swift
//  Zonky Stats
//
//  Created by lgergel on 15/11/2017.
//  Copyright © 2017 Lukas Gergel. All rights reserved.
//

import Foundation
typealias Serializable = [SerializableD]

typealias SerializableD = [String: Any]

protocol SerializableKey {
    var stringValue: String { get }
}

extension RawRepresentable where RawValue == String {
    var stringValue: String {
        return rawValue
    }
}

protocol SerializableValue {}

extension Bool: SerializableValue {}
extension String: SerializableValue {}
extension Int: SerializableValue {}
extension Dictionary: SerializableValue {}
extension Array: SerializableValue {}

extension Dictionary where Key == String, Value: Any {
    func value<V: SerializableValue>(forKey key: SerializableKey) -> V? {
        return self[key.stringValue] as? V
    }
}
