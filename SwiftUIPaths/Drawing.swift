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
	public var grid: CGSize? = CGSize(width: 50, height: 50)
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

	mutating func move(to: CGPoint, grid: CGSize?) {
		var dest = to
		if let grid = grid { dest.snap(to: grid) }
		let delta = dest - point
		point = dest
		_primaryPoint = _primaryPoint.map { $0 + delta }
		secondaryPoint = secondaryPoint.map { $0 + delta }
	}

	mutating func move(by delta: CGPoint, grid: CGSize?) {
		move(to: point + delta, grid: grid)
	}

	mutating func moveControlPoint1(to: CGPoint, grid: CGSize?, modifier: Bool) {
		var dest = to
		if let grid = grid { dest.snap(to: grid) }
		if modifier || _primaryPoint != nil { _primaryPoint = dest }
		else { secondaryPoint = dest.mirrored(relativeTo: point) }
	}

	mutating func moveControlPoint2(to: CGPoint, grid: CGSize?, modifier: Bool) {
		var dest = to
		if let grid = grid { dest.snap(to: grid) }
		if modifier && _primaryPoint == nil { _primaryPoint = primaryPoint }
		secondaryPoint = dest
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
		var point = state.startLocation
		var secondary = isDrag ? state.location : nil
		if let grid = grid {
			point.snap(to: grid)
			secondary?.snap(to: grid)
		}
		elements.append(Element(point: point, secondaryPoint: secondary))
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
			self[id].move(by: relative, grid: grid)
		}
	}

	mutating func move(by amount: CGPoint, snap: Bool) {
			let indices = elements.indices.filter { idx in
				selection.contains(elements[idx].id)
			}
			for idx in indices {
				elements[idx].move(by: amount, grid: snap ? grid : nil)
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
		move(by: point, snap: false)
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

//  MARK: CGPoint + Grid
private extension CGPoint {
	mutating func snap(to grid: CGSize) {
		x.snap(to: grid.width)
		y.snap(to: grid.height)
	}
}

private extension CGFloat {
	mutating func snap(to gridAxis: CGFloat) {
		let threshold = gridAxis / 5
		let modulo = truncatingRemainder(dividingBy: gridAxis)
		if modulo < threshold || gridAxis - modulo < threshold {
			self = (self / gridAxis).rounded() * gridAxis
		}
	}
}
