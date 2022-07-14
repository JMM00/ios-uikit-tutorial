//
//  Reminder+EKReminder.swift
//  UIKit-tutorial-jimin
//
//  Created by Jeon Jimin on 2022/07/14.
//

import Foundation
import EventKit

extension Reminder{
    init(with ekReminder: EKReminder) throws {
        //reminder에 알람이 있는 경우 시스템은 reminder기한이 되면 알림을 표시
        //미리 알림의 첫 번째 알림의 절대 날자를 바인딩하는 보호문 추가'
        //이 앱은 모든 알림에 알람이 있어야 함
        guard let dueDate = ekReminder.alarms?.first?.absoluteDate else {
            throw TodayError.reminderHasNoDueDate
        }
        id = ekReminder.calendarItemIdentifier
        title = ekReminder.title
        self.dueDate = dueDate
        notes = ekReminder.notes
        isComplete = ekReminder.isCompleted
    }
}
