//
//  Helpers.swift
//  SwiftUIPaths
//
//  Created by James Valaitis on 15/03/2021.
//

import Foundation

extension CGPoint {
	func distance(to other: CGPoint) -> CGFloat {
		(pow(x - other.x, 2) + pow(y - other.y, 2)).squareRoot()
	}

	func mirrored(relativeTo reference: CGPoint) -> CGPoint {
		reference - (self - reference)
	}

	static prefix func -(rhs: CGPoint) -> CGPoint {
			CGPoint(x: -rhs.x, y: -rhs.y)
		}

		static func +(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
			CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
		}

		static func +(lhs: CGPoint, rhs: CGSize) -> CGPoint {
			CGPoint(x: lhs.x + rhs.width, y: lhs.y + rhs.width)
		}

		static func -(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
			lhs + (-rhs)
		}

		func rounded() -> CGPoint {
			return CGPoint(x: x.rounded(), y: y.rounded())
		}
}
