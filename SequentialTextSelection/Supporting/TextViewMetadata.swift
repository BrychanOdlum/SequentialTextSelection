//
//  TextViewMetadata.swift
//  SequentialTextSelection
//
//  Created by Brychan Bennett-Odlum on 10/06/2018.
//  Copyright © 2018 Brychan Bennett-Odlum. All rights reserved.
//

import Foundation

class TextViewMetadata: NSObject {
	let textView: NSTextView
	let transformationBlock: NSAttributedString?
	
	init(textView: NSTextView, transformationBlock: NSAttributedString?) {
		self.textView = textView
		self.transformationBlock = transformationBlock
		
		super.init()
	}
}
