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
}
