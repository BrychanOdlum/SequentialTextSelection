//
//  SequentialTextSelectionManager.swift
//  SequentialTextSelection
//
//  Created by Brychan Bennett-Odlum on 10/06/2018.
//  Copyright © 2018 Brychan Bennett-Odlum. All rights reserved.
//
//	Based on INDSequentialTextSelectionManager by Indragie Karunaratne.
//

import Foundation
import AppKit
import Cocoa

class SequentialTextSelectionManager: NSResponder {
	var textViews = [String: TextViewMetadata]()
	var sortedTextViews = NSMutableOrderedSet()
	
	var currentSession: TextViewSelectionSession?
	var firstResponder = false
	
	private var _cachedAttributedText: NSAttributedString?
	var cachedAttributedText: NSAttributedString? {
		get {
			if _cachedAttributedText == nil {
				_cachedAttributedText = buildAttributedStringForCurrentSession()
			}
			return _cachedAttributedText
		}
		set {
			_cachedAttributedText = newValue
		}
	}
	
	override init() {
		NSEvent.addLocalMonitorForEvents(matching: .leftMouseDown) { event in
			return self.handleLeftMouseDown(event) ? nil : event
		}
		NSEvent.addLocalMonitorForEvents(matching: .leftMouseDragged) { event in
			return self.handleLeftMouseDragged(event) ? nil : event
		}
		NSEvent.addLocalMonitorForEvents(matching: .leftMouseUp) { event in
			return self.handleLeftMouseUp(event) ? nil : event
		}
		NSEvent.addLocalMonitorForEvents(matching: .rightMouseDown) { event in
			return self.handleRightMouseDown(event) ? nil : event
		}
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	
	
	
	// Complete
	func handleLeftMouseDown(_ event: NSEvent) -> Bool {
		if event.clickCount == 1 {
			endSession()
			
			if let textView = validTextView(for: event), textView.window?.firstResponder != textView {
				currentSession = TextViewSelectionSession(textView: textView, event: event)
				return true
			}
			
		}
		return false
	}
	
	// Complete
	func handleLeftMouseUp(_ event: NSEvent) -> Bool {
		if currentSession == nil {
			return false
		}
		
		event.window?.makeFirstResponder(self)
		if let textView = validTextView(for: event) {
			let index = Utils.characterIndexFor(event, in: textView)
			if index < textView.string.count {
				let attributes = textView.attributedString().attributes(at: index, effectiveRange: nil)
				if let link = attributes[NSAttributedString.Key.link] {
					textView.clicked(onLink: link, at: index)
				}
				
			}
		}
		return true
	}
	
	// Complete
	func handleLeftMouseDragged(_ event: NSEvent) -> Bool {
		guard let currentSession = self.currentSession else {
			return false
		}
		
		guard let textView = validTextView(for: event) else {
			return true
		}
		
		textView.window?.makeFirstResponder(textView)
		let affinity: NSSelectionAffinity = (event.locationInWindow.y < currentSession.windowPoint.y) ? .downstream : .upstream
		currentSession.windowPoint = event.locationInWindow
		
		var current = 0
		let identifier = currentSession.textViewIdentifier
		if textView.uniqueIdentifier == identifier {
			current = currentSession.characterIndex
		} else {
			let start = sortedTextViews.index(of: textViews[identifier]!.textView)
			let end = sortedTextViews.index(of: textView)
			current = (end >= start) ? 0 : textView.string.count
		}
		let index = Utils.characterIndexFor(event, in: textView)
		let range = Utils.forwardRangeForIndices(idx1: index, idx2: current)
		setSelectionRange(for: textView, with: range)
		processCompleteSelections(for: textView, affinity: affinity)
		
		return true
		
	}
	
	// Complete
	func handleRightMouseDown(_ event: NSEvent) -> Bool {
		if self.currentSession == nil {
			return false
		}
		
		event.window!.makeFirstResponder(self)
		if let textView = validTextView(for: event) {
			NSMenu.popUpContextMenu(menu(for: event), with: event, for: textView)
		}
	}
	
	// Complete
	func validTextView(for event: NSEvent) -> NSTextView? {
		let contentView = event.window!.contentView
		let point = contentView!.convert(event.locationInWindow, from: nil)
		let view = contentView!.hitTest(point)
		guard let textView = view as? NSTextView else {
			return nil
		}
		
		let identifier = textView.uniqueIdentifier
		return (textView.isSelectable && identifier != nil && textViews[identifier!] != nil) ? textView : nil
	}
	
	// Complete
	func copy(_ sender: Any?) {
		let pboard = NSPasteboard.general
		pboard.clearContents()
		pboard.writeObjects([cachedAttributedText!])
	}
	
	func buildSharingMenu() -> NSMenu {
		let shareMenu = NSMenu(title: NSLocalizedString("Share", comment: ""))
		let services = NSSharingService.sharingServices(forItems: [cachedAttributedText!])
		
		for service in services {
			let item = shareMenu.addItem(withTitle: service.title, action: #selector(self.share(_:)), keyEquivalent: "")
			item.target = self
			item.image = service.image
			item.representedObject = service
		}
		
		return shareMenu
	}
	
	// Complete
	func menu(for event: NSEvent) -> NSMenu {
		let menu = NSMenu(title: NSLocalizedString("Share", comment: ""))
		let copy = menu.addItem(withTitle: NSLocalizedString("Share", comment: ""), action: nil, keyEquivalent: "")
		copy.target = self
		menu.addItem(NSMenuItem.separator())
		
		let share = menu.addItem(withTitle: NSLocalizedString("Share", comment: ""), action: nil, keyEquivalent: "")
		share.submenu = buildSharingMenu()
		
		return menu
	}
	
	// Complete
	@objc func share(_ item:NSMenuItem) {
		let service = item.representedObject as! NSSharingService
		service.perform(withItems: [cachedAttributedText!])
	}
	
	// Complete
	func rehighlightSelectedRangesAsActive(_ active: Bool) {
		let ranges = currentSession!.selectionRanges.values
		for range in ranges {
			let meta = textViews[range.textViewIdentifier]
			meta?.textView.highlightSelectedText(in: range.range, drawActive: active)
		}
	}
	
	// Complete
	override func resignFirstResponder() -> Bool {
		rehighlightSelectedRangesAsActive(false)
		firstResponder = false
		return true
	}
	
	// Complete
	override func becomeFirstResponder() -> Bool {
		rehighlightSelectedRangesAsActive(true)
		firstResponder = true
		return true
	}
	
	// Complete
	func setSelectionRange(for textView: NSTextView, with range: NSRange) {
		if range.location == NSNotFound || NSMaxRange(range) == 0 {
			textView.deselectHighlighedText()
			currentSession?.remove(for: textView)
		} else {
			let selRange = TextViewSelectionRange(textView: textView, selected: range)
			currentSession?.add(selRange)
			textView.highlightSelectedText(in: range, drawActive: true)
		}
	}
	
	// Complete
	func processCompleteSelections(for textView: NSTextView, affinity: NSSelectionAffinity) {
		guard let currentSession = self.currentSession else {
			return
		}
		
		let meta = textViews[currentSession.textViewIdentifier]
		let start = sortedTextViews.index(of: meta?.textView)
		let end = sortedTextViews.index(of: textView)
		
		if start == NSNotFound || end == NSNotFound {
			return
		}
		
		let count = sortedTextViews.count
		var subrange = NSRange(location: NSNotFound, length: 0)
		var select = false
		if end > start {
			if affinity == NSSelectionAffinity.downstream {
				subrange = NSRange(location: start, length: end - start)
				select = true
			} else if count > end + 1 {
				subrange = NSRange(location: end + 1, length: start - end)
			}
		} else if end < start {
			if affinity == NSSelectionAffinity.upstream {
				subrange = NSRange(location: end + 1, length: start - end)
				select = true
			} else {
				subrange = NSRange(location: 0, length: end)
			}
		}
		
		var subarray = [NSTextView]()
		if subrange.location == NSNotFound {
			let views = sortedTextViews.mutableCopy() as! NSMutableOrderedSet
			views.remove(textView)
			subarray = views.array as! [NSTextView]
		} else {
			subarray = Array(sortedTextViews.array[subrange.location..<subrange.length]) as! [NSTextView]
		}
		
		for tv in subarray {
			let range: NSRange
			if select {
				let currentRange = tv.highlightedRange!
				if affinity == NSSelectionAffinity.downstream {
					range = NSRange(location: currentRange.location, length: tv.string.count - currentRange.location)
				} else {
					range = NSRange(location: 0, length: NSMaxRange(currentRange)) // TODO: NSMaxRange(currentRange) ?? tv?.string.count
				}
			} else {
				range = NSRange(location: 0, length: 0)
			}
			setSelectionRange(for: tv, with: range)
		}
	}
	
	// Complete
	func endSession() {
		for meta in textViews.values {
			meta.textView.deselectHighlighedText()
		}
		currentSession = nil
		cachedAttributedText = nil
	}
	
	func buildAttributedStringForCurrentSession() -> NSAttributedString? {
		guard let currentSession = self.currentSession else {
			return nil
		}
		
		let ranges = currentSession.selectionRanges
		var keys = ranges.keys as! [TextViewSelectionRange]
		let textViewComparator = self.textViewCompatator
		
		/*keys.sort
		keys = (keys as NSArray).sortedArray(comparator: { obj1, obj2 in
				let meta1 = self.textViews[obj1 ?? ""] as? TextViewMetadata
				let meta2 = self.textViews[obj2 ?? ""] as? TextViewMetadata
				return textViewComparator(meta1?.textView, meta2?.textView)
			}) as? [TextViewSelectionRange] ?? keys
		*/
	}
	
	// Complete
	func register(_ textView: NSTextView, identifier: String, transformationBlock block: NSAttributedString? = nil) {
		unregister(textView)
		textView.uniqueIdentifier = identifier
		if let currentSession = self.currentSession, let range = currentSession.selectionRanges[identifier] {
			textView.highlightSelectedText(in: range.range, drawActive: firstResponder)
		}
		self.textViews[identifier] = TextViewMetadata(textView: textView, transformationBlock: block)
		
		sortedTextViews.add(textView)
		sortTextViews()
	}
	
	func textViewCompatator(this:NSTextView, that:NSTextView) -> Bool {
		let thisFrame = this.convert(this.bounds, to: nil)
		let thatFrame = that.convert(that.bounds, to: nil)
		
		return NSMinY(thisFrame) > NSMinY(thatFrame)
	}
	
	func sortTextViews() {
		//sortedTextViews.sort(comparator: self.textViewCompatator)
		sortedTextViews = sortedTextViews.sorted(by: <#T##(Any, Any) throws -> Bool#>)
	}
	
	// Complete
	func unregister(_ textView: NSTextView) {
		guard let uniqueIdentifier = textView.uniqueIdentifier else {
			return
		}
		
		textViews.removeValue(forKey: uniqueIdentifier)
		sortedTextViews.remove(textView)
		sortTextViews()
	}
	
	// Complete
	func unregisterAll() {
		textViews.removeAll()
		sortedTextViews.removeAllObjects()
	}
}



