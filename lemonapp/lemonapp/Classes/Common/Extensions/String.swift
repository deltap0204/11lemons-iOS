//
//  String.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation

extension String {
    
    func toBase64() -> String? {
        
        let data = self.data(using: String.Encoding.utf8)
        
        return data?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
    }
    
    func splitWithPattern(_ pattern: [Int]) -> [String] {
        var result = [String]()
        var prevIndex = 0
        pattern.forEach {
            var substring: String?
            if self.count > prevIndex + $0 {
                substring = self.substring(with: self.index(self.startIndex, offsetBy: prevIndex) ..< self.index(self.startIndex, offsetBy: prevIndex+$0))
            } else if self.count > prevIndex {
                substring = self.substring(from: self.index(self.startIndex, offsetBy: prevIndex))
            }
            prevIndex += $0
            if let substring = substring {
                result.append(substring)
            }
        }
        return result
    }
}

extension String {
    func index(from: Int) -> Index {
        return self.index(startIndex, offsetBy: from)
    }
    
    func substring(from: Int) -> String {
        let fromIndex = index(from: from)
        return String(self[fromIndex...])
    }
    
    func substring(to: Int) -> String {
        let toIndex = index(from: to)
        return String(self[..<toIndex])
    }
    
    func substring(with r: CountableRange<Int>) -> String {
        let startIndex = index(from: r.lowerBound)
        let endIndex = index(from: r.upperBound)
        let range = startIndex..<endIndex
        return String(self[range])
    }
}

func * (left: String, right: Int) -> String {
    var result = ""
    for _ in 0...right - 1 {
        result += left
    }
    return result
}
func * (left: Int, right: String) -> String {
    return right * left
}
