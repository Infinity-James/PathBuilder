//
//  ModifierHandling.swift
//  SwiftUIPaths
//
//  Created by James Valaitis on 25/04/2021.
//

import SwiftUI

typealias FlagsChanged = (NSEvent.ModifierFlags) -> ()

internal struct ModifierHandling: NSViewRepresentable {
	var onFlagsChanged: FlagsChanged
	class KeyView: NSView {
		var onFlagsChanged: FlagsChanged
		init(onFlagsChanged: @escaping FlagsChanged) {
			self.onFlagsChanged = onFlagsChanged
			super.init(frame: .zero)
		}
		required init?(coder: NSCoder) { fatalError() }
		override var acceptsFirstResponder: Bool { true }
		override func flagsChanged(with event: NSEvent) {
			onFlagsChanged(event.modifierFlags)
		}
	}

	func makeNSView(context: Context) -> KeyView {
		let view = KeyView(onFlagsChanged: onFlagsChanged)
		DispatchQueue.main.async { view.window?.makeFirstResponder(view) }
		return view
	}

	func updateNSView(_ nsView: KeyView, context: Context) { }
}
