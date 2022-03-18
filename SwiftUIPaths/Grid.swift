//
//  Grid.swift
//  SwiftUIPaths
//
//  Created by James Valaitis on 28/04/2021.
//

import SwiftUI

//  MARK: Grid
public struct Grid: Shape {
	public var grid: CGSize
	public func path(in rect: CGRect) -> Path {
		Path { p in
			for y in stride(from: 0, to: rect.maxY, by: grid.height) {
				p.move(to: CGPoint(x: rect.minX, y: y))
				p.addLine(to: CGPoint(x: rect.maxX, y: y))
			}

			for x in stride(from: 0, to: rect.maxX, by: grid.width) {
				p.move(to: CGPoint(x: x, y: rect.minY))
				p.addLine(to: CGPoint(x: x, y: rect.maxY))
			}
		}
	}
}
