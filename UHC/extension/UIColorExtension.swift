//
// Created by Andrzej Chmiel on 11/09/2023.
//

import SwiftUI

extension UIColor {
	static func random(seed: Int) -> UIColor {
		var generator = RandomNumberGeneratorWithSeed(seed: seed)
		return UIColor(
				red: .random(in: 0.0..<1.0, using: &generator),
				green: .random(in: 0.0..<1.0, using: &generator),
				blue: .random(in: 0.0..<1.0, using: &generator),
				alpha: 1.0
		)
	}
}

struct RandomNumberGeneratorWithSeed: RandomNumberGenerator {
	init(seed: Int) {
		srand48(seed)
	}

	func next() -> UInt64 {
		withUnsafeBytes(of: drand48()) { bytes in
			bytes.load(as: UInt64.self)
		}
	}
}
