//
//  ContentView.swift
//  SwiftUIPaths
//
//  Created by James Valaitis on 08/03/2021.
//

import SwiftUI

struct ContentView: View {
	@State private var drawing = Drawing()
	@State internal var flags: NSEvent.ModifierFlags = []

    var body: some View {
		VStack {
			DrawingView(drawing: $drawing)
				.frame(maxWidth: .infinity, maxHeight: .infinity)
			ScrollView {
				Text(drawing.path.code)
					.multilineTextAlignment(.leading)
					.padding()
					.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
			}
			.frame(height: 150)
		}
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
