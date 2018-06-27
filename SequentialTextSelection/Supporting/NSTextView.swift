//
//  NSTextView.swift
//  SequentialTextSelection
//
//  Created by Brychan Bennett-Odlum on 08/06/2018.
//  Copyright © 2018 Brychan Bennett-Odlum. All rights reserved.
//
//	Based on INDSequentialTextSelectionManager by Indragie Karunaratne.
//

import Foundation
import ObjectiveC

private let DISABLED_SELECTED_TEXT_BG_COLOR = NSColor(deviceRed: 0.83, green: 0.83, blue: 0.83, alpha: 1.0)

private var uniqueIdentifierKey: UInt8 = 0
private var backgroundColorRangesKey: UInt8 = 0
private var highlightedRangeKey: UInt8 = 0

extension NSTextView {
	var uniqueIdentifier: String? {
		get {
			return objc_getAssociatedObject(self, &uniqueIdentifierKey) as? String
		}
		set {
			objc_setAssociatedObject(self, &uniqueIdentifierKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
		}
	}
	var backgroundColorRanges: [AttributeRange]? {
		get {
			return objc_getAssociatedObject(self, &backgroundColorRangesKey) as? [AttributeRange]
		}
		set {
			objc_setAssociatedObject(self, &backgroundColorRangesKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
		}
	}
	var highlightedRange: NSRange? {
		get {
			return objc_getAssociatedObject(self, &highlightedRangeKey) as? NSRange
		}
		set {
			objc_setAssociatedObject(self, &highlightedRangeKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
		}
	}
	
	func highlightSelectedText(in range: NSRange, drawActive active: Bool) {
		if backgroundColorRanges == nil {
			backupBackgroundColorState()
		}
		highlightedRange = range
		
		var selectedColor: NSColor? = nil
		if active {
			selectedColor = selectedTextAttributes[NSAttributedString.Key.backgroundColor] as? NSColor ?? NSColor.selectedTextBackgroundColor
		} else {
			selectedColor = DISABLED_SELECTED_TEXT_BG_COLOR
		}
		
		textStorage?.beginEditing()
		textStorage?.removeAttribute(NSAttributedString.Key.backgroundColor, range: NSRange(location: 0, length: self.textStorage!.length))
		textStorage?.addAttribute(NSAttributedString.Key.backgroundColor, value: selectedColor!, range: range)
		textStorage?.endEditing()
		
		self.needsDisplay = true
	}
	
	func deselectHighlighedText() {
		textStorage?.beginEditing()
		textStorage?.removeAttribute(NSAttributedString.Key.backgroundColor, range: NSRange(location: 0, length: string.count))
		for range in backgroundColorRanges! {
			self.textStorage?.addAttribute(range.attribute, value: range.value, range: range.range)
		}
		textStorage?.endEditing()
		
		self.needsDisplay = true
		
		backgroundColorRanges = nil
		highlightedRange = NSRange(location: 0, length: 0)
	}
	
	func backupBackgroundColorState() {
		var ranges = [AttributeRange]()
		let attribute = NSAttributedString.Key.backgroundColor
		
		textStorage?.enumerateAttribute(
			NSAttributedString.Key.backgroundColor,
			in: NSRange(location: 0, length: textStorage?.length ?? 0),
			options: [],
			using: { value, range, stop in
				if value == nil {
					return
				}
				let attrRange = AttributeRange(attribute: attribute, value: value, range: range)
				ranges.append(attrRange)
		})
		
		backgroundColorRanges = ranges
	}
}
