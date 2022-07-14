//
//  TodayError.swift
//  UIKit-tutorial-jimin
//
//  Created by Jeon Jimin on 2022/07/14.
//

import Foundation

//일반적인 오류를 나타낼 수 있는 유형 만들기
enum TodayError: LocalizedError {
    //캘린더 데이터에 대한 액세스를 허용하지 않는 경우
    case accessDenied
    case accessRestricted
    case failedReadingReminders
    case reminderHasNoDueDate
    case unknown
    
    //오류가 발생하는 명확한 정보 얻을 수 있음
    var errorDescription: String? {
        switch self{
        case .accessDenied:
            return NSLocalizedString("The app doesn't have permission to read reminders", comment: "access denied error description")
        case .accessRestricted:
            return NSLocalizedString("This device doesn't allow access to reminders", comment: "acess restricted error description")
        case .failedReadingReminders:
            return NSLocalizedString("Failed to read reminders.", comment: "failed reading reminders error description")
        case .reminderHasNoDueDate:
            return NSLocalizedString("A reminder has no due date", comment: "reminder has no due date error description")
        case .unknown:
            return NSLocalizedString("An unknown error occurred.", comment: "unknown error description")
        }
    }
}
