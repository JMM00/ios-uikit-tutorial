//
//  EKEventStore+AsyncFetch.swift
//  UIKit-tutorial-jimin
//
//  Created by Jeon Jimin on 2022/07/14.
//

import Foundation
import EventKit

extension EKEventStore {
    func fetchReminders(matching predicate: NSPredicate) async throws -> [EKReminder] {
        //결과가 inline으로 반환될 수 있도록 concurrent callback 함수를 continuations를 사용하여 wrap
        try await withCheckedThrowingContinuation { continuation in
            //일치하는 미리알림을 completion handler에 전달
            fetchReminders(matching: predicate) { reminders in
                if let reminders = reminders {
                    //성공 시 continuation재개하면서 미리알림(EKReminder 배열) 반환
                    continuation.resume(returning: reminders)
                }else{
                    //오류 발생시키면서 continuation재개
                    continuation.resume(throwing: TodayError.failedReadingReminders)
                }
            }
        }
    }
}
