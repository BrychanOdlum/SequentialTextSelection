//
//  TextViewSelectionSession.swift
//  SequentialTextSelection
//
//  Created by Brychan Bennett-Odlum on 10/06/2018.
//  Copyright © 2018 Brychan Bennett-Odlum. All rights reserved.
//
//	Based on INDSequentialTextSelectionManager by Indragie Karunaratne.
//

import Foundation

class TextViewSelectionSession: NSObject {
	var textViewIdentifier: String
	var characterIndex: Int
	var selectionRanges: [String: TextViewSelectionRange]
	var windowPoint: NSPoint
	
	init(textView: NSTextView, event: NSEvent) {
		self.textViewIdentifier = textView.uniqueIdentifier!
		self.characterIndex = Utils.characterIndexFor(event, in: textView)
		self.selectionRanges = [: ]
		self.windowPoint = event.locationInWindow
		
		super.init()
	}
	
	func add(_ range: TextViewSelectionRange) {
		selectionRanges[range.textViewIdentifier] = range
	}
	
	func remove(for textView: NSTextView) {
		selectionRanges.removeValue(forKey: textView.uniqueIdentifier!)
	}
}
