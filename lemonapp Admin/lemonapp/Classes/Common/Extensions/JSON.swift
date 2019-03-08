//
//  JSON.swift
//  lemonapp
//
//  Copyright © 2015 11lemons. All rights reserved.
//

import SwiftyJSON

extension JSON {
    
    func value<T: JSONDecodable>() throws -> T {
        return try T.decode(self)
    }
    
    func value<T: JSONDecodable>() throws -> [T] {
        return try [T].decode(self)
    }
    
    func value<T>() throws -> T {
        let result: T?
        switch T.self {
        case is [JSON].Type:
            result = try self.array() as? T
        case is [String : JSON].Type:
            result = try self.dictionary() as? T
        case is Bool.Type:
            result = try self.bool() as? T
        case is String.Type:
            result = try self.string() as? T
        case is NSNumber.Type:
            if T.self is NSDecimalNumber.Type {
                result = NSDecimalNumber(value: try self.double() as Double) as? T
            } else {
                result = try self.number() as? T
            }
        case is NSNull.Type:
            result = try self.null() as? T
        case is Foundation.URL.Type:
            result = try self.URL() as? T
        case is Double.Type:
            result = try self.double() as? T
        case is Float.Type:
            result = try self.float() as? T
        case is Int.Type:
            result = try self.int() as? T
        case is UInt.Type:
            result = try self.uInt() as? T
        case is Int8.Type:
            result = try self.int8() as? T
        case is Int16.Type:
            result = try self.int16() as? T
        case is Int32.Type:
            result = try self.int32() as? T
        case is Int64.Type:
            result = try self.int64() as? T
        default:
            result = nil
        }
        if let result = result {
            return result
        } else {
            throw self.error ?? LemonError.unknownTypeForParsing
        }
    }
    
    func array() throws -> [JSON] {
        guard type == .array else {
            throw self.error ?? LemonError.unknown
        }
        return array ?? []
    }
    
    func dictionary() throws -> [String : JSON] {
        if let dictionary = self.dictionary {
            return dictionary
        } else {
            throw self.error ?? LemonError.unknown
        }
    }
    
    func bool() throws -> Bool {
        if let bool = self.bool {
            return bool
        } else if let boolString = self.string {
            switch boolString {
            case "Y", "y", "true", "TRUE", "Yes", "yes":
                return true
            default:
                return false
            }
        } else {
            throw self.error ?? LemonError.unknown
        }
    }
    
    func string() throws -> String {
        if let string = self.string {
            return string
        } else {
            throw self.error ?? LemonError.unknown
        }
    }
    
    func number() throws -> NSNumber {
        if let number = self.number {
            return number
        } else {
            throw self.error ?? LemonError.unknown
        }
    }
    
    func null() throws -> NSNull {
        if let null = self.null {
            return null
        } else {
            throw self.error ?? LemonError.unknown
        }
    }
    
    func URL() throws -> Foundation.URL {
        if let URL = self.url {
            return URL
        } else {
            throw self.error ?? LemonError.unknown
        }
    }
    
    func double() throws -> Double {
        if let double = try self.double ?? Double(self.string()) {
            return double
        } else {
            throw self.error ?? LemonError.unknown
        }
    }
    
    func float() throws -> Float {
        if let float = self.float {
            return float
        } else {
            throw self.error ?? LemonError.unknown
        }
    }
    
    func int() throws -> Int {
        if let int = self.int {
            return int
        } else {
            throw self.error ?? LemonError.unknown
        }
    }
    
    func uInt() throws -> UInt {
        if let uInt = self.uInt {
            return uInt
        } else {
            throw self.error ?? LemonError.unknown
        }
    }
    
    func int8() throws -> Int8 {
        if let int8 = self.int8 {
            return int8
        } else {
            throw self.error ?? LemonError.unknown
        }
    }
    
    func int16() throws -> Int16 {
        if let int16 = self.int16 {
            return int16
        } else {
            throw self.error ?? LemonError.unknown
        }
    }
    
    func int32() throws -> Int32 {
        if let int32 = self.int32 {
            return int32
        } else {
            throw self.error ?? LemonError.unknown
        }
    }
    
    func int64() throws -> Int64 {
        if let int64 = self.int64 {
            return int64
        } else {
            throw self.error ?? LemonError.unknown
        }
    }
    
}
