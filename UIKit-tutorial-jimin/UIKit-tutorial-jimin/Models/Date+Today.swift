//
//  Date+Today.swift
//  ios-uikit-tutorial-ch2
//
//  Created by Jeon Jimin on 2022/07/08.
//

import Foundation

extension Date{
    var dayAndTimeText: String {
        //시간 구성요소만 전달
        let timeText = formatted(date: .omitted, time: .shortened)
        
        if Locale.current.calendar.isDateInToday(self) {
            let timeFormat = NSLocalizedString("Today at %@", comment: "Today at time format string")
            return String(format: timeFormat, timeText)
        } else {
            let dateText = formatted(.dateTime.month(.abbreviated).day())
            let dateAndTimeFormat = NSLocalizedString("%@ at %@", comment: "Date and time format String")
            return String(format: dateAndTimeFormat, dateText, timeText)
        }
        
    }
    var dayText: String {
        if Locale.current.calendar.isDateInToday(self){
            return NSLocalizedString("Today", comment: "Today due date description")
        } else{
            return formatted(.dateTime.month().day().weekday(.wide))
        }
    }
}
