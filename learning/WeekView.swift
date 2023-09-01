//
//  RowView.swift
//  learning
//
//  Created by Andrzej Chmiel on 28/08/2023.
//

import SwiftUI

struct WeekView: View {
    let holidayDays: [HolidayDay]
    let width: CGFloat
    let height: CGFloat
    let horizontalSpacing: CGFloat
    var body: some View {
        HStack(spacing: horizontalSpacing) {
            ForEach(holidayDays, id: \.id) { holidayDay in
                HolidayDayView(holidayDay: holidayDay)
                    .frame(width: width, height: height)
            }
        }
        .padding()
    }
}

struct WeekView_Previews: PreviewProvider {
    static var previews: some View {
        WeekView(holidayDays: [HolidayDay(id: "1", day: 1, month: 1, holidays: [Holiday(id: 1, usual: true, name: "Test", description: "Test", url: "")]), HolidayDay(id: "2", day: 1, month: 2, holidays: [])], width: 40, height: 70, horizontalSpacing: 10)
    }
}
