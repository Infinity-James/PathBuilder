//
//  Drawing.swift
//  SwiftUIPaths
//
//  Created by James Valaitis on 08/03/2021.
//

import SwiftUI

//  MARK: Drawing View
public struct DrawingView: View {
	@Binding public var drawing: Drawing
	@GestureState private var drag: DragGesture.Value?
	@State private var flags: NSEvent.ModifierFlags = []

	public var body: some View {
		ZStack(alignment: .topLeading) {
			Color.white
			if let grid = drawing.grid {
				Grid(grid: grid)
					.stroke(lineWidth: 1)
					.foregroundColor(Color(white: 0.9))
			}
			liveDrawing.path.stroke(Color.black, lineWidth: 4)
			Points(drawing: Binding(get: { liveDrawing }, set: { drawing = $0 }))
		}
		.gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local)
					.updating($drag) { value, state, _ in state = value }
					.onEnded { state in drawing.update(for: state) })
		.background(
			ModifierHandling { flags = $0 }
				.onMoveCommand { direction in drawing.move(in: direction, shiftPressed: flags.contains(.shift)) }
				.modifier(DeleteModifier { drawing.delete() })
		)
		
    }

	private var liveDrawing: Drawing {
		var copy = drawing
		if let state = drag {
			copy.update(for: state)
		}
		return copy
	}
}

struct DeleteModifier: ViewModifier {
	var delete: () -> ()
	func body(content: Content) -> some View {
		content
			.keyboardShortcut(.delete, modifiers: [])
			.onDeleteCommand(perform: delete)
			.toolbar(content: {
				Button(action: delete){
					Image(systemName: "trash.fill")
				}
				.keyboardShortcut(.delete, modifiers: [])
			})
	}
}

//  MARK: Points
private struct Points: View {
	@Binding var drawing: Drawing

	var body: some View {
		ForEach(Array(zip(drawing.elements, drawing.elements.indices)), id: \.0.id) { element, index in
			let elementID = element.id
			let isSelected = drawing.selection.contains(elementID)
			let drawControlPoints = isSelected || (drawing.selection.isEmpty && index == drawing.elements.endIndex - 1)
			let onClick = { shiftPressed in drawing.select(elementID, shiftPressed: shiftPressed) }
			let move = { (to: CGPoint) in
				let amount = to - element.point
				drawing.move(by: amount, snap: true)
			}
			PathPoint(element: $drawing.elements[index], isSelected: isSelected, drawControlPoints: drawControlPoints, grid: drawing.grid, onClick: onClick, move: move)
		}
	}
}

//  MARK: Path Point
private struct PathPoint: View {
	@Binding var element: Drawing.Element
	let isSelected: Bool
	let drawControlPoints: Bool
	var grid: CGSize?
	let onClick: (_ shiftPressed: Bool) -> ()
	let move: (_ to: CGPoint) -> ()

	private let radius: CGFloat = 12

	var body: some View {
		if drawControlPoints, let controlPoints = element.controlPoints {
			Path { p in
				p.move(to: controlPoints.0)
				p.addLine(to: element.point)
				p.addLine(to: controlPoints.1)
			}
			.stroke(Color.gray)

			controlPoint(at: controlPoints.0) { element.moveControlPoint1(to: $0, grid: grid, modifier: $1) }
			controlPoint(at: controlPoints.1) { element.moveControlPoint2(to: $0, grid: grid, modifier: $1) }
		}

		pathPoint(at: element.point)
	}

	func pathPoint(at point: CGPoint) -> some View {
		let drag = DragGesture(minimumDistance: 1, coordinateSpace: .local)
			.onChanged { state in move(state.location) }
		let optionDrag = DragGesture(minimumDistance: 1, coordinateSpace: .local)
			.modifiers(.option)
			.onChanged { state in element.setCoupledControlPoints(to: state.location) }
		let click = TapGesture(count: 1)
			.onEnded { onClick(false) }
		let shiftClick = TapGesture(count: 1)
			.modifiers(.shift)
			.onEnded { onClick(true) }
		let doubleClick = TapGesture(count: 2)
			.onEnded { element.resetControlPoints() }
		let combinedDrag = optionDrag.exclusively(before: drag)
		let combinedClick = doubleClick.simultaneously(with: shiftClick.exclusively(before: click))
		let gesture = combinedDrag.simultaneously(with: combinedClick)

		return Circle()
			.stroke(isSelected ? Color.blue : .black, lineWidth: isSelected ? 4 : 2)
			.background(Circle().fill(Color.white))
			.padding(4)
			.frame(width: radius * 2, height: radius * 2)
			.offset(x: point.x - radius, y: point.y - radius)
			.gesture(gesture)
	}

	func controlPoint(at point: CGPoint, onDrag: @escaping (CGPoint, Bool) -> ()) -> some View {
		let drag = DragGesture(minimumDistance: 0, coordinateSpace: .local)
			.onChanged { state in onDrag(state.location, false) }
		let optionDrag = DragGesture(minimumDistance: 0, coordinateSpace: .local)
			.modifiers(.option)
			.onChanged { state in onDrag(state.location, true) }
		let gesture = optionDrag.exclusively(before: drag)

		return RoundedRectangle(cornerRadius: 2)
			.stroke(Color.black, lineWidth: 2)
			.background(Circle().fill(Color.white))
			.padding(4)
			.frame(width: radius * 1.5, height: radius * 1.5)
			.offset(x: point.x - radius / 1.5, y: point.y - radius / 1.5)
			.gesture(gesture)
	}
}

//  MARK: Previews
internal struct Drawing_Previews: PreviewProvider {
	static var previews: some View {
		DrawingView(drawing: .constant(Drawing()))
	}
}
