//
// Created by Andrzej Chmiel on 02/09/2023.
//

import SwiftUI

struct DayScreenView: View {
    let holidayDay: HolidayDay
    var body: some View {
        NavigationView {
            List {
                ForEach(holidayDay.holidays, id: \.id) { holiday in
                    Text(holiday.name)
                }
            }
                    .navigationBarTitle(holidayDay.getDate())
        }
    }
}
