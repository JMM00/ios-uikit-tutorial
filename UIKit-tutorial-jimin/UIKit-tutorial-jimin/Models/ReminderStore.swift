//
//  ReminderStore.swift
//  UIKit-tutorial-jimin
//
//  Created by Jeon Jimin on 2022/07/14.
//

import Foundation
import EventKit

class ReminderStore{
    static let shared = ReminderStore()
    
    private let ekStore = EKEventStore()
    
    //사용자가 미리알림 데이터에 대한 접근 권한을 부여했는지 확인
    var isAvailable: Bool {
        EKEventStore.authorizationStatus(for: .reminder) == .authorized
    }
    
    func requestAcess() async throws {
        let status = EKEventStore.authorizationStatus(for: .reminder)
        
        //사용자가 액세스 권한을 부여한 경우 함수가 반환 아직 결정하지 않은 경우 권한 요청, 다른조건에 대해 오류 발생
        switch status{
        case .authorized:
            return
        case .restricted:
            throw TodayError.accessRestricted
        case .notDetermined:
            let accessGranted = try await ekStore.requestAccess(to: .reminder)
            guard accessGranted else{
                throw TodayError.accessDenied
            }
        case .denied:
            throw TodayError.accessDenied
        @unknown default:
            throw TodayError.unknown
        }
    }
    
    private func read(with id: Reminder.ID) throws -> EKReminder {
        //EventKit에서 미리알림 식별자와 일치하는 캘린더 항목을 쿼리
        //일정 항목 검색 후 Reminder로 캐스팅하는 보호문 추가 store에서 항목을 찾을 수 없으면 오류 발생
        //CalendarItem(withIdentifier:)메서드는 EKCalendarItem을 반환하므로 EKReminder로 다운캐스트
        guard let ekReminder = ekStore.calendarItems(withExternalIdentifier: id) as? EKReminder else {
            throw TodayError.failedReadingCalendarItem
        }
        return ekReminder
    }
    
    func readAll() async throws -> [Reminder] {
        //미리 알림 액세스를 사용할 수 없는 경우 오류 발생
        guard isAvailable else {
            throw TodayError.accessDenied
        }
        //미리 알림 항목으로만 결과를 좁힘
        //선택하면 특정 캘린더의 미리 알림으로 결과를 더 좁힐 수 있음
        let predicate = ekStore.predicateForReminders(in: nil)
        //fetchReminders(matching:)의 결과를 기다리는 상수
        let ekReminders = try await ekStore.fetchReminders(matching: predicate)
        //EKReminder에서 Reminder로 데이터 매핑 결과를 저장하는 상수 생성
        let reminders: [Reminder] = try ekReminders.compactMap{ eKReminder in
            do {
                return try Reminder(with: eKReminder)
            } catch TodayError.reminderHasNoDueDate {
                //nil 반환 시 대상 컬렉션에서 이 알림을 삭제하도록 컴팩트 맵에 지시
                return nil
            }
        }
        //기한에 해당하는 알림이 있는 미리 알림만 포함
        return reminders
    }
    //이 메서드가 모든 상황에서 반환하는 식별자를 사용하지 않음
    //@dicardableResult 속성은 호출 사이트가 반환 값을 캡처하지 않는 경우 경고 생략하도록 컴파일러에게 지시
    @discardableResult
    func save(_ reminder: Reminder) throws -> Reminder.ID {
        guard isAvailable else {
            throw TodayError.accessDenied
        }
        let ekReminder: EKReminder
        do {
            ekReminder = try read(with: reminder.id)
        } catch {
            //new reminder 를 생성하고 상수에 할당하는 블록
            //해당 식별자로 reminder를 찾지 못했다고 해서 오류가 발생하는 것은 아님. -> 새 알림을 저장하고 있음을 나타냄
            ekReminder = EKReminder(eventStore: ekStore)
        }
        ekReminder.update(using: reminder, in: ekStore)
        try ekStore.save(ekReminder, commit: true)
        return ekReminder.calendarItemIdentifier
    }
}
