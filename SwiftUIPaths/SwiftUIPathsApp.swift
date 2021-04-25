//
//  SwiftUIPathsApp.swift
//  SwiftUIPaths
//
//  Created by James Valaitis on 08/03/2021.
//

import SwiftUI

@main
struct SwiftUIPathsApp: App {
    var body: some Scene {
        WindowGroup {
			ContentView()
        }
		.commands {
			CommandGroup(replacing: CommandGroupPlacement.pasteboard) {
				Button("Delete", action: { print("Custom Delete") })
				.keyboardShortcut(.delete, modifiers: [])
			}
		}
    }
}
