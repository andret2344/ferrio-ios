//
//  CardView.swift
//  learning
//
//  Created by Andrzej Chmiel on 28/08/2023.
//

import SwiftUI

struct HolidayDayView: View {
    let holidayDay: HolidayDay
    var body: some View {
        let count = holidayDay.holidays.count
        RoundedRectangle(cornerRadius: 12)
            .foregroundColor(.random)
            .overlay(
                count == 0 ? Text("SAD") : Text(String(count))
            )
    }
}

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        HolidayDayView(holidayDay: HolidayDay(id: "1", day: 1, month: 1, holidays: [Holiday(id: 1, usual: true, name: "Text", description: "Text", url: "")]))
    }
}

extension Color {
    static var random: Color {
        return Color(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1)
        )
    }
}
