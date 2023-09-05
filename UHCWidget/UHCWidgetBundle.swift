//
//  UHCWidgetBundle.swift
//  UHCWidget
//
//  Created by Andrzej Chmiel on 04/09/2023.
//

import WidgetKit
import SwiftUI

@main
struct UHCWidgetBundle: WidgetBundle {
	var body: some Widget {
		UHCWidget()
		UHCWidgetLiveActivity()
	}
}
