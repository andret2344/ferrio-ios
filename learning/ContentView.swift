//
//  ContentView.swift
//  learning
//
//  Created by Andrzej Chmiel on 28/08/2023.
//

import SwiftUI

struct ContentView: View {
    private let spacing: CGFloat = 16
    @State
    private var days = [HolidayDay]()
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    let rows: [[HolidayDay]] = days.chunked(into: 7)
                    ForEach(0..<rows.endIndex, id: \.self) { index in
                        WeekView(
                            holidayDays: rows[index],
                            width: getWidth(geometry: geometry),
                            height: getHeight(geometry: geometry),
                            horizontalSpacing: spacing)
                    }
                }
            }
        }
        .task {
            do {
                let url = URL(string: "https://api.unusualcalendar.net/holiday/pl")!
                days = try await URLSession.shared.decode([HolidayDay].self, from: url)
            } catch let DecodingError.dataCorrupted(context) {
                print(context)
            } catch let DecodingError.keyNotFound(key, context) {
                print("Key '\(key)' not found:", context.debugDescription)
                print("codingPath:", context.codingPath)
            } catch let DecodingError.valueNotFound(value, context) {
                print("Value '\(value)' not found:", context.debugDescription)
                print("codingPath:", context.codingPath)
            } catch let DecodingError.typeMismatch(type, context)  {
                print("Type '\(type)' mismatch:", context.debugDescription)
                print("codingPath:", context.codingPath)
            } catch {
                print("error: ", error)
            }
        }
    }
    
    func getWidth(geometry: GeometryProxy) -> CGFloat {
        return (geometry.size.width - spacing * 8) / 7
    }
    
    func getHeight(geometry: GeometryProxy) -> CGFloat {
        return (geometry.size.height - spacing * 7) / 6
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
