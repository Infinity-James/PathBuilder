//
//  Drawing.swift
//  SwiftUIPaths
//
//  Created by James Valaitis on 22/03/2021.
//

import SwiftUI

//  MARK: Drawing
public struct Drawing {
	public var elements: [Element] = []
	public var selection: Set<Drawing.Element.ID> = []
}

//  MARK: Element
public extension Drawing {
	struct Element: Identifiable {
		public let id = UUID()
		public var point: CGPoint { didSet { point = point.rounded() } }
		public var secondaryPoint: CGPoint? { didSet { secondaryPoint = secondaryPoint?.rounded() } }
		private var _primaryPoint: CGPoint? { didSet { _primaryPoint = _primaryPoint?.rounded() } }
		public var primaryPoint: CGPoint?  {
			_primaryPoint ?? secondaryPoint?.mirrored(relativeTo: point)
		}

		init(point: CGPoint, secondaryPoint: CGPoint?) {
			self.point = point.rounded()
			self.secondaryPoint = secondaryPoint?.rounded()
		}
	}
}

public extension Drawing.Element {
	var controlPoints: (CGPoint, CGPoint)? {
		guard let primary = primaryPoint, let secondary = secondaryPoint else { return nil }
		return (primary, secondary)
	}

	mutating func move(to: CGPoint) {
		let delta = to - point
		point = to
		_primaryPoint = _primaryPoint.map { $0 + delta }
		secondaryPoint = secondaryPoint.map { $0 + delta }
	}

	mutating func move(by delta: CGPoint) {
		move(to: point + delta)
	}

	mutating func moveControlPoint1(to: CGPoint, modifier: Bool) {
		if modifier || _primaryPoint != nil { _primaryPoint = to }
		else {
			secondaryPoint = to.mirrored(relativeTo: point)
		}
	}

	mutating func moveControlPoint2(to: CGPoint, modifier: Bool) {
		if modifier && _primaryPoint == nil { _primaryPoint = primaryPoint }
		secondaryPoint = to
	}

	mutating func resetControlPoints() {
		_primaryPoint = nil
		secondaryPoint = nil
	}

	mutating func setCoupledControlPoints(to: CGPoint) {
		_primaryPoint = nil
		secondaryPoint = to
	}
}

public extension Drawing {
	var path: Path {
		var path = Path()
		guard let first = elements.first else { return path }
		path.move(to: first.point)
		var previousControlPoint: CGPoint? = nil
		for element in elements.dropFirst() {
			if let previous = previousControlPoint {
				let controlPoint2 = element.controlPoints?.0 ?? element.point
				path.addCurve(to: element.point, control1: previous, control2: controlPoint2)
			} else {
				if let mirrored = element.controlPoints?.0 {
					path.addQuadCurve(to: element.point, control: mirrored)
				} else {
					path.addLine(to: element.point)
				}
			}
			previousControlPoint = element.secondaryPoint
		}
		return path
	}
}

//  MARK: Drawing + UI
public extension Drawing {
	mutating func update(for state: DragGesture.Value) {
		let isDrag = state.startLocation.distance(to: state.location) > 1
		elements.append(Element(point: state.startLocation, secondaryPoint: isDrag ? state.location : nil))
	}

	mutating func select(_ id: Element.ID, shiftPressed: Bool) {
		if shiftPressed {
			if selection.contains(id) { selection.remove(id) }
			else { selection.insert(id) }
		} else {
			selection = [id]
		}
	}

	mutating func move(_ id: Element.ID, to: CGPoint) {
		guard let elementInFocus = elements.first(where: { $0.id == id }) else { return }
		let relative = to - elementInFocus.point
		for id in selection {
			self[id].move(by: relative)
		}
	}

	mutating func move(by amount: CGPoint) {
			let indices = elements.indices.filter { idx in
				selection.contains(elements[idx].id)
			}
			for idx in indices {
				elements[idx].move(by: amount)
			}
		}

	mutating func move(in direction: MoveCommandDirection, shiftPressed: Bool) {
		let offset: CGFloat = shiftPressed ? 10 : 1
		var point: CGPoint = .zero
		switch direction {
		case .up:
			point.y = -offset
		case .down:
			point.y = offset
		case .left:
			point.x = -offset
		case .right:
			point.x = offset
		@unknown default:
			break
		}
		move(by: point)
	}

	mutating func delete() {
		elements.removeAll { selection.contains($0.id) }
		selection.removeAll()
	}

	private subscript(id: Element.ID) -> Drawing.Element {
		get { elements.first(where: { $0.id == id })! }
		set {
			let idx = elements.indices.first(where: { elements[$0].id == id })!
			elements[idx] = newValue
		}
	}
}
