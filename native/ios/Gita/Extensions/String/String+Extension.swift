//
//  String+Extension.swift
//  TestSwift
//
//  Created by Stanislav Grinberg on 10 Jan 2017.
//  Updated by Olga Zhegulo on 05 Apr 2017.
//  Copyright © 2017 Stanislav Grinberg. All rights reserved.
//

import UIKit

extension String {
	
	func starts(with str: String, ignoreCase: Bool = true) -> Bool {
		return ignoreCase ? self.lowercased().hasPrefix(str.lowercased()) : self.hasPrefix(str)
	}
	
	func index(of str: String, ignoreCase: Bool = true, inverse: Bool = false) -> Int {
		var options: CompareOptions = .literal
		if ignoreCase {
			options.update(with: .caseInsensitive)
		}
		if inverse {
			options.update(with: .backwards)
		}
		
		
		let range = self.range(of: str, options: options)
		guard let unwrappedRange = range else {
			return -1
		}
		
		return self.distance(from: self.startIndex, to: unwrappedRange.lowerBound)
	}

	
	func lastIndex(of str: String) -> Int {
		return index(of: str, ignoreCase: true, inverse: true)
	}
	
	func contains(_ str: String, ignoreCase: Bool = true) -> Bool {
		let range = self.range(of: str, options: ignoreCase ? .caseInsensitive : .literal)
		guard let _ = range else {
			return false
		}

		return true
	}
	
	func isEqualToString(_ str: String, ignoreCase: Bool = true) -> Bool {
		return ignoreCase ? self.lowercased() == str.lowercased() : self == str
	}
	
	func ends(with str: String, ignoreCase: Bool = true) -> Bool {
		return ignoreCase ? self.lowercased().hasSuffix(str) : self.hasSuffix(str)
	}
	
	func firstLetterToLower() -> String {
		let firstCharStr = String(self[self.startIndex])
		let range = self.index(after: self.startIndex)..<self.endIndex
		
		#if swift(>=4.0)
			let strWithoutFirstChar = String(self[range])
		#else
			let strWithoutFirstChar = self[range]
		#endif
		
		return self.count < 2 ? self.lowercased() : String(format: "%@%@", firstCharStr.lowercased(), strWithoutFirstChar)
	}
	
	func firstLetterToUpper() -> String {
		let firstCharStr = String(self[self.startIndex])
		let range = self.index(after: self.startIndex)..<self.endIndex
		
		#if swift(>=4.0)
			let strWithoutFirstChar = String(self[range])
		#else
			let strWithoutFirstChar = self[range]
		#endif
		
		return self.count < 2 ? self.uppercased() : String(format: "%@%@", firstCharStr.uppercased(), strWithoutFirstChar)
	}
	
	func padRight(_ cnt: Int, withString str: String = " ") -> String {
		if cnt > 0 {
			let padStr = String(repeating: str, count: cnt)
			return String(format: "%@%@", self, padStr)
		} else {
			return self
		}
	}
	
	func padLeft(_ cnt: Int, withString str: String = " ") -> String {
		if cnt > 0 {
			let padStr = String(repeating: str, count: cnt)
			return String(format: "%@%@", padStr, self)
		} else {
			return self
		}
	}
	
	func appendLine(_ str: String = "") -> String {
		return self.appendingFormat("%@\r\n", str)
	}
	
	func trim() -> String {
		return self.trimmingCharacters(in: .whitespacesAndNewlines)
	}
	
	func trim(with characters: String) -> String {
		return self.trimmingCharacters(in: CharacterSet.init(charactersIn: characters))
	}
	
	func replace(_ substring: String, withValue value: String, ignoreCase: Bool = false) -> String {
		return self.replacingOccurrences(of: substring, with: value, options: ignoreCase ? .caseInsensitive : .literal)
	}
	
	func replace(_ substring: String, withValue value: String, ignoreCase: Bool = false, replaceAll: Bool = true) -> String {
		if replaceAll {
			return self.replace(substring, withValue: value, ignoreCase: ignoreCase)
		}
		
		//guard let range = self.range(of: substring) else { return self }
		guard let range = self.range(of: substring, options: ignoreCase ? .caseInsensitive : .literal, range: nil, locale: nil) else { return self }
		return replacingCharacters(in: range, with: value)
	}
	
	func split(_ separators: [String] , removeSeparators remove: Bool, removeEmptyEntries removeEmpty: Bool) -> [String] {
		var src = self
		var array: [String] = [String]()
		var hasSubstrings = false
		
		repeat {
			hasSubstrings = false
			var minIndex = Int.max
			var minIndexStr: String? = nil
			
			var strIndex: Index? = nil
			for separator in separators {
				guard separator.count > 0 else { continue }
				
				let index = src.index(of: separator)
				if index != -1 {
					hasSubstrings = true
					if index < minIndex {
						minIndex = index
						strIndex = src.index(src.startIndex, offsetBy: index)
						minIndexStr = separator
					}
				}
			}
			
			if minIndexStr != nil  && strIndex != nil {
				#if swift(>=4.0)
					var subString = String(src[src.startIndex..<strIndex!])
				#else
					var subString = String(src[src.startIndex..<strIndex!])!
				#endif
				
				let subStringTrim = subString.trim()
				if !removeEmpty || subStringTrim.count > 0 {
					array.append(subStringTrim)
				}
				if !remove {
					if !removeEmpty || minIndexStr!.count > 0 {
						array.append(minIndexStr!)
					}
				}
				#if swift(>=4.0)
					subString = String(src[src.index(strIndex!, offsetBy: minIndexStr!.count)..<src.endIndex])
				#else
					subString = String(src[src.index(strIndex!, offsetBy: minIndexStr!.count)..<src.endIndex])!
				#endif
				
				src = subString
			} else if src.count > 0 {
				hasSubstrings = true
				if !removeEmpty || src.count > 0 {
					array.append(src)
				}
				src = ""
			}
			
		} while hasSubstrings == true && src.count > 0
		
		return array
	}
	
	func matches(for pattern: String) -> Bool {
		do {
			let regEx = try NSRegularExpression(pattern: pattern)
			return regEx.matches(in: self, range: NSRange(location: 0, length: self.count)).count > 0
		} catch let error {
			print("invalid regex: \(error.localizedDescription)")
			return false
		}
	}

	func characterAt(_ index: Int) -> String {
		//return self.utf16[String.UTF16Index(encodedOffset: index)]
		return String(self[self.index(self.startIndex, offsetBy: index)])
	}
	
	func substring(from: Int, to: Int) -> String {
		let start = index(self.startIndex, offsetBy: from)
		let end = index(self.startIndex, offsetBy: to)
		
		#if swift(>=4.0)
			return String(self[start..<end])
		#else
			return String(self[start..<end])!
		#endif
	}
	
	func substringTo(_ index: Int) -> String {
		#if swift(>=4.0)
			return String(self[self.startIndex..<self.index(self.startIndex, offsetBy: index)])
		#else
			return String(self[self.startIndex..<self.index(self.startIndex, offsetBy: index)])!
		#endif
	}
	
	func substringFrom(_ index: Int) -> String {
		#if swift(>=4.0)
			return String(self[self.index(self.startIndex, offsetBy: index)..<self.endIndex])
		#else
			return String(self[self.index(self.startIndex, offsetBy: index)..<self.endIndex])!
		#endif
	}
	
	func isNumber() -> Bool {
		let badCharacters = NSCharacterSet.decimalDigits.inverted
		
		return rangeOfCharacter(from: badCharacters) == nil
	}
	
	func plainText() -> String {
		var s = self
		while let r = range(of: "<[^>]+>", options: .regularExpression) {
			s = s.replacingCharacters(in: r, with: "")
		}
		
		return s
	}
	
	
	// MARK: - Text size and dimension
	
	public func size(width maxWidth: CGFloat = CGFloat.greatestFiniteMagnitude, height maxHeight: CGFloat = CGFloat.greatestFiniteMagnitude, font: UIFont) -> CGSize {
		let constraintRect = CGSize(width: maxWidth, height: maxHeight)
		
		#if swift(>=4.0)
			let attributes: [NSAttributedStringKey: Any] = [.font: font]
		#else
			let attributes: [String: Any] = [NSFontAttributeName: font]
		#endif
		
		let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
		
		return boundingBox.size
	}
	
	// MARK: - Static methods
	
	/**
	Checks if the specified string is nil or an empty string.
	params:
	- value the string to be checked.
	- returns: true if and only if the specified string is nil or empty.
	*/
	static func isNilOrEmpty(_ value: String?) -> Bool {
		if let value = value {
			return value.isEmpty
		}
		return true
	}
	
	static func isNilOrWhiteSpace(_ value: String?) -> Bool {
		if let value = value {
			return value.trim().isEmpty
		}
		return true
	}
	
}

extension String {
	
	subscript(i: Int) -> String {
		get {
			//return self.utf16[String.UTF16Index(encodedOffset: i)]
			return String(self[self.index(self.startIndex, offsetBy: i)])
		}
	}
	
}
