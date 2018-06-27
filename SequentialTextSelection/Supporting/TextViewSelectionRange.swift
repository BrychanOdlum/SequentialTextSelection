//
//  TextViewSelectionRange.swift
//  SequentialTextSelection
//
//  Created by Brychan Bennett-Odlum on 10/06/2018.
//  Copyright © 2018 Brychan Bennett-Odlum. All rights reserved.
//
//	Based on INDSequentialTextSelectionManager by Indragie Karunaratne.
//

import Foundation

class TextViewSelectionRange: NSObject {
	let textViewIdentifier: String
	let range: NSRange
	let attributedText: NSAttributedString
	
	init(textView: NSTextView, selected range: NSRange) {
		self.textViewIdentifier = textView.uniqueIdentifier! // TODO: Check if need copy!
		self.range = range
		self.attributedText = textView.attributedString().attributedSubstring(from: range).copy() as! NSAttributedString
		
		
		super.init()
	}
}
