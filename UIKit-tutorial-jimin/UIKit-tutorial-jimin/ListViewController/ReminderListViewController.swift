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
        updateSnapshot()
        //assign the data source to the collection view
        collectionView.dataSource = dataSource
    }
    
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        //indexPath의 item요소는 int이므로 적절한 알림을 검색하기 위해 배열 인덱스로 사용가능
        let id = reminders[indexPath.item].id
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
        listConfiguration.backgroundColor = .clear
        
        return UICollectionViewCompositionalLayout.list(using: listConfiguration)
    }


}

