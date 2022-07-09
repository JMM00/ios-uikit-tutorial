//
//  ReminderViewController.swift
//  ios-uikit-tutorial
//
//  Created by Jeon Jimin on 2022/07/09.
//

import UIKit

//미리 알림 세부 정보 목록을 배치하고 미리 알림 세부 정보 데이터와 함께 목록을 제공
class ReminderViewController: UICollectionViewController {
    
    //둘다 generic type
    //int및 row 일반 매개변수를 지정하여 데이터 소스가 row의 섹션 번호 및 인스턴스에 대해 int의 인스턴스를 사용하도록 컴파일러에 지시함
    private typealias DataSource = UICollectionViewDiffableDataSource<Section, Row>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Row>
    
    var reminder: Reminder
    private var dataSource: DataSource!
    
    init(reminder: Reminder) {
        self.reminder = reminder
        var listConfiguration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        listConfiguration.showsSeparators = false
        let listLayout = UICollectionViewCompositionalLayout.list(using: listConfiguration)
        super.init(collectionViewLayout: listLayout)
    }
    
    required init?(coder: NSCoder) {
        fatalError("Always initialize ReminderViewController using init(reminder:)")
    }
    //뷰가 로드된 후 데이터 소스를 생성
    override func viewDidLoad() {
        //생명 주기 함수를 재정의할 때 먼저 수퍼클래스가 자체 작업을 수행할 수 있도록 함
        super.viewDidLoad()
        let cellRegistration = UICollectionView.CellRegistration(handler: cellRegistrationHandler)
        dataSource = DataSource(collectionView: collectionView) { (collectionView: UICollectionView, indexPath: IndexPath, itemIdentifier:Row) in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
        }
        navigationItem.title = NSLocalizedString("Reminder", comment: "Reminder view controller title")
        //뷰 컨트롤러가 처음 로드될 때 이 목록에 데이터 스냅샷을 적용 시스템은 그에 따라 목록을 자동으로 구성
        updateSnapshot()
    }
    
    func cellRegistrationHandler(cell: UICollectionViewListCell, indexPath: IndexPath, row: Row) {
        var contentConfiguration = cell.defaultContentConfiguration()
        //데이터 제공
        contentConfiguration.text = text(for: row)
        //textStyle계산 변수 사용하여 글꼴 스타일 제공
        contentConfiguration.textProperties.font = UIFont.preferredFont(forTextStyle: row.textStyle)
        contentConfiguration.image = row.image
        cell.contentConfiguration = contentConfiguration
        cell.tintColor = .todayPrimaryTint
    }
    
    private func updateSnapshot() {
        var snapshot = Snapshot()
//        snapshot.appendSections([0])
//        snapshot.appendItems([.viewTitle, .viewDate, .viewTime, .viewNotes], toSection: 0)
        snapshot.appendSections([.view])
        snapshot.appendItems([.viewTitle, .viewDate, .viewTime, .viewNotes], toSection: .view)
        dataSource.apply(snapshot)
    }
    
    func text(for row: Row) -> String? {
        switch row {
        case .viewDate: return reminder.dueDate.dayText
        case .viewNotes: return reminder.notes
        case .viewTime: return reminder.dueDate.formatted(date: .omitted, time: .shortened)
        case .viewTitle: return reminder.title
        }
    }
}
