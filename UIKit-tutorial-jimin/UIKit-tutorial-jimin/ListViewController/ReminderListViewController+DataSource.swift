//
//  Controller+DataSource.swift
//  ios-uikit-tutorial
//
//  Created by Jeon Jimin on 2022/07/09.
//

import UIKit

//알림 목록에 대한 데이터 소스 역할을 하는 reminderListViewController를 허용하는 모든 동작이 포함
extension ReminderListViewController {
    typealias DataSource = UICollectionViewDiffableDataSource<Int, Reminder.ID>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Int, Reminder.ID>
    
    var reminderCompletedValue: String {
        NSLocalizedString("Completed", comment: "Reminder completed value")
    }
    var reminderNotCompletedValue: String {
        NSLocalizedString("Not Completed", comment: "Reminder not completed value")
    }
    
    //공유 알림 저장소를 반환하는 계산속성
    private var reminderStore: ReminderStore { ReminderStore.shared }
    
    func updateSnapshot(reloading idsThatChanged: [Reminder.ID] = []) {
        //filteredReminders 배열의 미리 알림에 해당하는 식별자만 포함하도록 idsThatChanged를 필터링하고 결과를 ids 변수에 할당
        //contains(where:)는 시퀀스에 지정된 요소가 포함되어 있는지 여부를 나타내는 bool값 반환
        let ids = idsThatChanged.filter { id in filteredReminders.contains(where: {$0.id == id})
        }
        //create new snapshot
        var snapshot = Snapshot()
        //append section to the snapshot
        snapshot.appendSections([0])
        //append items to the snapshot
//        snapshot.appendItems(Reminder.sampleData.map { $0.id })
//        snapshot.appendItems(reminders.map {$0.id})
        //map메서드를 사용하여 미리알림 배열을 식별자 배열로 반환
        snapshot.appendItems(filteredReminders.map{$0.id})
        if !ids.isEmpty {
            snapshot.reloadItems(ids)
        }
        //apply the snapshot to the data source
        dataSource.apply(snapshot)
        headerView?.progress = progress
    }
    
    func cellRegistrationHandler(cell: UICollectionViewListCell, indexPath: IndexPath, id: Reminder.ID) {
//        let reminder = reminders[indexPath.item]
        //아래에서 정의한 함수를 사용하도록 변경
        let reminder = reminder(for: id)
        var contentConfiguration = cell.defaultContentConfiguration()
        contentConfiguration.text = reminder.title
        contentConfiguration.secondaryText = reminder.dueDate.dayAndTimeText
        contentConfiguration.secondaryTextProperties.font = UIFont.preferredFont(forTextStyle: .caption1)
        cell.contentConfiguration = contentConfiguration
        
        var doneButtonConfiguration = doneButtonConfiguration(for: reminder)
        doneButtonConfiguration.tintColor = .todayListCellDoneButtonTint
        cell.accessibilityCustomActions = [doneButtonAccessibilityAction(for: reminder)]
        cell.accessibilityValue = reminder.isComplete ? reminderCompletedValue : reminderNotCompletedValue
        cell.accessories = [.customView(configuration: doneButtonConfiguration), .disclosureIndicator(displayed: .always)]
        
        var backgroudnConfiguration = UIBackgroundConfiguration.listGroupedCell()
        backgroudnConfiguration.backgroundColor = .todayListCellBackground
        cell.backgroundConfiguration = backgroudnConfiguration
    }
    
    func completeReminder(with id: Reminder.ID) {
        var reminder = reminder(for: id)
        reminder.isComplete.toggle()
        update(reminder, with: id)
//        updateSnapshot()
        updateSnapshot(reloading: [id])
    }
    
    private func doneButtonAccessibilityAction(for reminder: Reminder) -> UIAccessibilityCustomAction {
        let name = NSLocalizedString("Toggle completion", comment: "Reminder done button accessibility label")
        let action = UIAccessibilityCustomAction(name: name) { [weak self] action in
            self?.completeReminder(with: reminder.id)
            return true
        }
        return action
    }
 
    private func doneButtonConfiguration(for reminder: Reminder) -> UICellAccessory.CustomViewConfiguration {
        let symbolName = reminder.isComplete ? "circle.fill" : "circle"
        let symbolConfiguration = UIImage.SymbolConfiguration(textStyle: .title1)
        let image = UIImage(systemName: symbolName, withConfiguration: symbolConfiguration)
        let button = ReminderDoneButton()
        button.addTarget(self, action: #selector(didPressDoneButton(_:)), for: .touchUpInside)
        button.id = reminder.id
        button.setImage(image, for: .normal)
        return UICellAccessory.CustomViewConfiguration(customView: button, placement: .leading(displayed: .always))
    }
    
    //작업 또는 다른 비동기 함수 내에서 비동기로 표시된 함수를 호출해야함
    func prepareReminderStore() {
        //비동기적으로 실행되는 새로운 작업 단위 생성
        Task {
            do {
                try await reminderStore.requestAcess()
                //readAll()의 결과를 기다린 다음 그 결과를 reminders에 할당
                reminders = try await reminderStore.readAll()
                //외부 앱에서 미리알림 변경 시 이 앱에도 추가되도록하는 기능?
                //시스템이 변경 알림을 수신하면 view controller에서 해당 작업 메서드 호출
                NotificationCenter.default.addObserver(self, selector: #selector(eventStoreChanged(_:)), name: .EKEventStoreChanged, object: nil)
            } catch TodayError.accessDenied, TodayError.accessRestricted {
                //앱이 이벤트에서 작동하기 어려울 때 샘플데이터로 작동할 수 있음
                #if DEBUG
                reminders = Reminder.sampleData
                #endif
            } catch {
                //오류 표시 -> 나머지 오류를 catch
                showError(error)
            }
            updateSnapshot()
        }
    }
    func reminderStoreChanged() {
        Task{
            reminders = try await reminderStore.readAll()
            updateSnapshot()
        }
    }
    //알림 배열에 알림을 추가하는 메서드
    func add(_ reminder: Reminder) {
        //EventKit은 미리 알림에 고유 식별자를 할당 -> 새 식별자를 받을 수 있도록 reminder의 변경가능한 복사본 만들기
        //지역 변수 reminder은 동일한 이름을 가진 매개변수를 숨김
        //변수 선언 후에는 reminder매개변수에 접근할 수 없음
        var reminder = reminder
        do {
            //알림을 저장하고 식별자를 새 상수에 저장하는 블록
            let idFromStore = try reminderStore.save(reminder)
            // 식별자를 reminder 변수에 할당
            reminder.id = idFromStore
            reminders.append(reminder)
        } catch TodayError.accessDenied {
            //사용자가 미리알림에 대한 접근 허용을 하지 않았을 경우 save메서드에서 오류 발생
        } catch {
            //나머지 모든 오류 조건에 대해 오류 메세지
            showError(error)
        }
    }
    
    //지정된 식별자로 미리알림을 삭제하는 메서드
    func deleteReminder(with id: Reminder.ID) {
        let index = reminders.indexOfReminder(with: id)
        reminders.remove(at: index)
    }
    
    func reminder(for id: Reminder.ID) -> Reminder {
        let index = reminders.indexOfReminder(with: id)
        return reminders[index]
    }
    func update(_ reminder: Reminder, with id: Reminder.ID) {
        let index = reminders.indexOfReminder(with: id)
        reminders[index] = reminder
    }
}
