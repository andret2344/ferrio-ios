//
// Created by Andrzej Chmiel on 02/09/2023.
//

import SwiftUI

struct DayScreenView: View {
    let holidayDay: HolidayDay
    let link = URL(string: "https://www.admin.ch")!

    var body: some View {
        NavigationView {
            if holidayDay.holidays.count == 0 {
                VStack {
                    Image("SadIcon")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 128, height: 128)
                    Text("No unusual holidays.")
                }
            } else {
                List {
                    ForEach(holidayDay.holidays, id: \.id) { holiday in
                        Text(holiday.name)
                    }
                }
            }
        }
                .navigationBarTitle(holidayDay.getDate())
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        let holidays = holidayDay.holidays.map { holiday in
                            "-" + holiday.name
                        }.joined(separator: "\n")
                        let text = "\(holidayDay.day).\(holidayDay.month):\n\n\(holidays)\n\n\(NSLocalizedString("Check it yourself!", comment: ""))"
                        ShareLink(item: text, preview: SharePreview(text))
                                .labelStyle(.iconOnly)
                    }
                }
    }
}
