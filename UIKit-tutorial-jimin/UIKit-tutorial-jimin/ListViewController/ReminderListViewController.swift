//
//  ViewController.swift
//  ios-uikit-tutorial
//
//  Created by Jeon Jimin on 2022/07/09.
//

import UIKit

class ReminderListViewController: UICollectionViewController {

    //connect the cells diffable data source
//    typealias DataSource = UICollectionViewDiffableDataSource<Int, String>
//    typealias Snapshot = NSDiffableDataSourceSnapshot<Int, String>
    
    var dataSource: DataSource!
    var reminders: [Reminder] = Reminder.sampleData
    //주어진 list style에 대한 미리 알림 모음을 반환하는 계산속성
    //filter메서드는 컬렉션을 반복하고 조건을 충족하는 요소만 포함하는 배열 반환
    //sorted메서드는 주어진 조건에 대해 배열의 순서 정렬
    var filteredReminders: [Reminder] {
        return reminders.filter { listStyle.shouldInclude(date: $0.dueDate)}.sorted {$0.dueDate < $1.dueDate}
    }
    var listStyle: ReminderListStyle = .today
    //list style의 name으로 UISegmentedControl을 초기화하고 저장
    let listStyleSegmentedControl = UISegmentedControl(items: [
        ReminderListStyle.today.name, ReminderListStyle.future.name, ReminderListStyle.all.name])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let listLayout = listLayout()
        //set cell's content and appearance
        collectionView.collectionViewLayout = listLayout
        
        //controller + DataSource 의 함수로 변경 후 삭제
        //viewController 동작과 data source동작을 구분
        /*
        let cellRegistration = UICollectionView.CellRegistration{ (cell: UICollectionViewListCell, indexPath: IndexPath, itemIdentifier: String) in
            let reminder = Reminder.sampleData[indexPath.item]
            var contentConfiguration = cell.defaultContentConfiguration()
            contentConfiguration.text = reminder.title
            cell.contentConfiguration = contentConfiguration
        }
         */
        let cellRegistration = UICollectionView.CellRegistration(handler: cellRegistrationHandler)
        
        //initialized the data source
        dataSource = DataSource(collectionView: collectionView){(collectionView: UICollectionView, indexPath: IndexPath, itemIdentifier: Reminder.ID) in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
        }
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didPressAddButton(_:)))
        addButton.accessibilityLabel = NSLocalizedString("Add reminder", comment: "Add button accessibility label")
        navigationItem.rightBarButtonItem = addButton
        
        //선택한 세그먼트의 인덱스 번호를 할당
        listStyleSegmentedControl.selectedSegmentIndex = listStyle.rawValue
        //ReminderListViewController에서 분할된 컨트롤을 위한 타겟 객체와 액션 설정
        listStyleSegmentedControl.addTarget(self, action: #selector(didChangeListStyle(_:)), for: .valueChanged)
        //navigation 아이템의 titleView에 list style의 segmentedControl할당
        navigationItem.titleView = listStyleSegmentedControl
        
        updateSnapshot()
        //assign the data source to the collection view
        collectionView.dataSource = dataSource
    }
    
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        //indexPath의 item요소는 int이므로 적절한 알림을 검색하기 위해 배열 인덱스로 사용가능
//        let id = reminders[indexPath.item].id
        let id = filteredReminders[indexPath.item].id
        //네비게이션 스택에 상세 뷰 컨트롤러를 추가하여 상세 뷰가 화면에 푸시되도록 함
        showDetail(for: id)

        //사용자가 탭한 항목을 선택한 것으로 표시하지 않으므로 false반환 대신 해당 목록 항목에 대한 세부 정보 보기로 전환
        return false
    }
    
    func showDetail(for id: Reminder.ID) {
        let reminder = reminder(for: id)
        //미리알림 편집할 때마다 ReminderViewController에서 수행할 작업 정의
        let viewController = ReminderViewController(reminder: reminder) { [weak self] reminder in
            ///data source의 reminder와 user interface를 reminder가 변경될 때마다 update해야함
            self?.update(reminder, with: reminder.id)
            //updating snapshot은 reminder의 배열에 의존하기 때문에, reminder배열을 먼저 update해야함
            self?.updateSnapshot(reloading: [reminder.id])
        }
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func listLayout() -> UICollectionViewCompositionalLayout {
        
        var listConfiguration = UICollectionLayoutListConfiguration(appearance: .grouped)
        listConfiguration.showsSeparators = false
        listConfiguration.trailingSwipeActionsConfigurationProvider = makeSwipeActions
        listConfiguration.backgroundColor = .clear
        
        return UICollectionViewCompositionalLayout.list(using: listConfiguration)
    }
    
    private func makeSwipeActions(for indexPath: IndexPath?) -> UISwipeActionsConfiguration? {
        guard let indexPath = indexPath, let id = dataSource.itemIdentifier(for: indexPath) else { return nil }
        //delete action -> 작업이 데이터 삭제이므로 style = .destructive
        let deleteActionTitle = NSLocalizedString("Delete", comment: "Delete action title")
        let deleteAction = UIContextualAction(style: .destructive, title: deleteActionTitle) { [weak self] _, _, completion in
            //해당하는 알림 삭제
            self?.deleteReminder(with: id)
            self?.updateSnapshot()
            completion(false)
        }
        //새 swipe action configuration반환 -> 왜?
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }


}

