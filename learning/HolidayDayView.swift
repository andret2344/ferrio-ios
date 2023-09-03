//
//  CardView.swift
//  learning
//
//  Created by Andrzej Chmiel on 28/08/2023.
//

import SwiftUI

struct HolidayDayView: View {
    let day: Int
    let holidayDay: HolidayDay
    var body: some View {
        let count = holidayDay.holidays.count
        NavigationLink {
            DayScreenView(holidayDay: holidayDay)
        } label: {
            Text(count == 0 ? "SAD" : String(day + 1))
//                    .background(.random)
                    .cornerRadius(15)
        }
    }
}

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        HolidayDayView(day: 1, holidayDay: HolidayDay(id: "1", day: 1, month: 1, holidays: [Holiday(id: 1, usual: true, name: "Text", description: "Text", url: "")]))
    }
}

extension ShapeStyle where Self == Color {
    static var random: Color {
        Color(
                red: .random(in: 0...1),
                green: .random(in: 0...1),
                blue: .random(in: 0...1)
        )
    }
}
