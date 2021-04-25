//
//  CodeGeneration.swift
//  SwiftUIPaths
//
//  Created by James Valaitis on 05/04/2021.
//

import SwiftUI

//  MARK: Path -> Code
internal extension Path {
	var code: String {
		guard !isEmpty else { return "Path()" }
		
		var result = "Path { p in \n"
		forEach { element in
			result.append("\t\(element.code)\n")
		}
		result.append("}")
		return result
	}
}

//  MARK: Path.Element -> Code
private extension Path.Element {
	var code: String {
		switch self {
		case .move(let to):
			return "p.move(to: \(to.code))"
		case .line(let to):
			return "p.addLine(to: \(to.code))"
		case let .quadCurve(to, control):
			return "p.addQuadCurve(to: \(to.code), control: \(control.code)"
		case let .curve(to, control1, control2):
			return "p.addCurve(to: \(to.code), control1: \(control1.code), control2: \(control2.code)"
		case .closeSubpath:
			return "p.closeSubpath()"
		}
	}
}

//  MARK: CGPoint -> Code
private extension CGPoint {
	var code: String { "CGPoint(x: \(x), y: \(y))" }
}
