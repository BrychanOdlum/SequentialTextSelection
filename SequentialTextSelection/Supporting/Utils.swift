//
//  Util.swift
//  SequentialTextSelection
//
//  Created by Brychan Bennett-Odlum on 10/06/2018.
//  Copyright © 2018 Brychan Bennett-Odlum. All rights reserved.
//
//	Based on INDSequentialTextSelectionManager by Indragie Karunaratne.
//

import Foundation

internal class Utils {
	static func characterIndexFor(_ event: NSEvent, in textView: NSTextView) -> Int {
		let contentView = event.window!.contentView!
		let point = contentView.convert(event.locationInWindow, from: nil)
		let textPoint = textView.convert(point, from: contentView)
		return textView.characterIndexForInsertion(at: textPoint)
	}
	
	static func forwardRangeForIndices(idx1: Int, idx2: Int) -> NSRange {
		var range: NSRange
		if idx2 >= idx1 {
			range = NSRange(location: idx1, length: idx2 - idx1)
		} else if idx2 < idx1 {
			range = NSRange(location: idx2, length: idx1 - idx2)
		} else {
			range = NSRange(location: NSNotFound, length: 0)
		}
		return range
	}
}
