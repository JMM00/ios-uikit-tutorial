//
//  ReminderListStyle.swift
//  UIKit-tutorial-jimin
//
//  Created by Jeon Jimin on 2022/07/13.
//

import Foundation

///열거형은 raw Int value를 저장하기 때문에 자동으로 각 케이스에 0부터 시작하는 숫자 할당
enum ReminderListStyle: Int {
    case today
    case future
    case all
    
    //세그먼트 제목으로 표시
    var name: String {
        switch self{
        case .today:
            return NSLocalizedString("Today", comment: "Today style name")
        case .future:
            return NSLocalizedString("Future", comment: "Future style name")
        case .all:
            return NSLocalizedString("All", comment: "All style name")
        }
    }
    func shouldInclude(date: Date) -> Bool {
        //Locale.current.calendar는 사용자의 지역 설정을 기반으로 하는 현재 캘린더
        //isDateInToday의 값은 전달한 날자가 오늘이면 true, 아니면 false
        let isInToday = Locale.current.calendar.isDateInToday(date)
        switch self {
        case .today:
            return isInToday
        case .future:
            return (date > Date.now) && !isInToday
        case .all:
            return true
        }
    }
}
