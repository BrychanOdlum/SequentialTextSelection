//
//  AttributeRange.swift
//  SequentialTextSelection
//
//  Created by Brychan Bennett-Odlum on 08/06/2018.
//  Copyright © 2018 Brychan Bennett-Odlum. All rights reserved.
//
//	Based on INDSequentialTextSelectionManager by Indragie Karunaratne.
//

import Foundation

class AttributeRange: NSObject {
	let attribute: NSAttributedString.Key
	let value: Any
	let range: NSRange
	
	init(attribute: NSAttributedString.Key, value: Any, range: NSRange) {
		self.attribute = attribute
		self.value = value
		self.range = range
		
		super.init()
	}
}
