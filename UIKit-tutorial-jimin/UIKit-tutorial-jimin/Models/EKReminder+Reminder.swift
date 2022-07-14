//
//  EKReminder+Reminder.swift
//  UIKit-tutorial-jimin
//
//  Created by Jeon Jimin on 2022/07/14.
//

import Foundation
import EventKit

extension EKReminder {
    func update(using reminder: Reminder, in store: EKEventStore) {
        title = reminder.title
        notes = reminder.notes
        isCompleted = reminder.isComplete
        calendar = store.defaultCalendarForNewReminders()
        
        //EvenKit에는 alarm과 due date를 모두 포함 Today에서는 due date만 사용하므로 alarm을 제거해야함
        alarms?.forEach { alarm in
            guard let absoluteDate = alarm.absoluteDate else { return }
            //The comparison determines the dates to be the same if they occur during the same minute.
            let comparison = Locale.current.calendar.compare(reminder.dueDate, to: absoluteDate, toGranularity: .minute)
            if comparison != .orderedSame {
                removeAlarm(alarm)
            }
        }
        //기한이 되었을 때, 시스템 알림을 트리거 -> reminder에 하나의 alarm이 있어야 함
        if !hasAlarms {
            addAlarm(EKAlarm(absoluteDate: reminder.dueDate))
        }
    }
}
