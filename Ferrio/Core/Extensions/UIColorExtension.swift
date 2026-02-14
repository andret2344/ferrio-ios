//
// Created by Andrzej Chmiel on 11/09/2023.
//

import SwiftUI

extension UIColor {
	static func random(seed: Int) -> UIColor {
		var generator = SeededRandomNumberGenerator(seed: seed)
		return UIColor(
			red: .random(in: 0.0..<1.0, using: &generator),
			green: .random(in: 0.0..<1.0, using: &generator),
			blue: .random(in: 0.0..<1.0, using: &generator),
			alpha: 1.0
		)
	}
}

struct SeededRandomNumberGenerator: RandomNumberGenerator {
	private var state: UInt64

	init(seed: Int) {
		state = UInt64(bitPattern: Int64(seed))
	}

	mutating func next() -> UInt64 {
		state &+= 0x9e3779b97f4a7c15
		var z = state
		z = (z ^ (z >> 30)) &* 0xbf58476d1ce4e5b9
		z = (z ^ (z >> 27)) &* 0x94d049bb133111eb
		return z ^ (z >> 31)
	}
}
