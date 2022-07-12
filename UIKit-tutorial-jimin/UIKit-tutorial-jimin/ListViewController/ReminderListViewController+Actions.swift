//
//  ReminderListViewController+Actions.swift
//  ios-uikit-tutorial
//
//  Created by Jeon Jimin on 2022/07/09.
//

import UIKit

extension ReminderListViewController {
    @objc func didPressDoneButton(_ sender: ReminderDoneButton) {
        guard let id = sender.id else {return}
        completeReminder(with: id)
    }
    
    @objc func didPressAddButton(_ sender: UIBarButtonItem) {
        let reminder = Reminder(title: "", dueDate: Date.now)
        let viewController = ReminderViewController(reminder: reminder) { [weak self] reminder in
            //Done버튼 탭할 때 알림 저장
            self?.add(reminder)
            //앱의 데이터가 변경될 때마다 사용자 인터페이스를 업데이트하기 위해 스냅샷을 만들고 적용해야함
            self?.updateSnapshot()
            self?.dismiss(animated: true)
        }
        viewController.isAddingNewReminder = true
        viewController.setEditing(true, animated: false)
        //bar버튼 아이템 만들기
        viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didCancelAdd(_:))) //didCancelAdd가 @objc 속성이기 때문에 selector로 지정 가능
        viewController.navigationItem.title = NSLocalizedString("Add Reminder", comment: "Add Reminder view controller title")
        //viewController를 루트뷰로 NavigationController 만들기
        let navigationController = UINavigationController(rootViewController: viewController)
        //ViewController의 present메서드 호출 및 navigationController전달
        present(navigationController, animated: true)
    }
    
    @objc func didCancelAdd(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    @objc func didChangeListStyle(_ sender: UISegmentedControl) {
        listStyle = ReminderListStyle(rawValue: sender.selectedSegmentIndex) ?? .today
        updateSnapshot()
    }
}
