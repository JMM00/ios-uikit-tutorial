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
    
    var reminder: Reminder {
        didSet {
            onChange(reminder)
        }
    }
    //사용자가 저장 또는 삭제를 선택할 때까지 편집 내용 저장
    var workingReminder: Reminder
    var onChange: (Reminder)->Void
    private var dataSource: DataSource!
    
    //클로저를 인수로 전달할 때 함수가 반환된 후에 호출되면 escaping처리로 레이블을 지정해야 함
    init(reminder: Reminder, onChange: @escaping (Reminder)->Void) {
        self.reminder = reminder
        self.workingReminder = reminder
        self.onChange = onChange
        var listConfiguration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        listConfiguration.showsSeparators = false
        listConfiguration.headerMode = .firstItemInSection
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
        navigationItem.rightBarButtonItem = editButtonItem
        //뷰 컨트롤러가 처음 로드될 때 이 목록에 데이터 스냅샷을 적용 시스템은 그에 따라 목록을 자동으로 구성
        updateSnapshotForViewing()
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        if editing {
//            updateSnapshotForEditing()
            prepareForEditing()
        }else {
//            updateSnapshotForViewing()
            prepareForViewing()
        }
    }
    
    func cellRegistrationHandler(cell: UICollectionViewListCell, indexPath: IndexPath, row: Row) {
        let section = section(for: indexPath)
        switch (section, row) {
        case (_, .header(let title)):
                //ReminderViewController+CellConfiguration으로 이동
            cell.contentConfiguration = headerConfiguration(for: cell, with: title)
        case (.view, _):
            //ReminderViewController+CellConfiguration로 이동
            cell.contentConfiguration = defaultConfiguration(for: cell, at: row)
        case (.title, .editText(let title)):
            cell.contentConfiguration = titleConfiguration(for: cell, with: title)
        case (.date, .editDate(let date)):
            cell.contentConfiguration = dateConfiguration(for: cell, with: date)
        case (.notes, .editText(let notes)):
            cell.contentConfiguration = notesConfiguration(for: cell, with: notes)
        default:
            fatalError("Unexpected combination of section and row. ")
        }
        cell.tintColor = .todayPrimaryTint
    }
    
    @objc func didCancelEdit() {
        //사용자가 cancel선택 시 temporary working reminder를 원래 상태로 reset
        workingReminder = reminder
        //편집모드일 때는 오른쪽 navigation bar item이 'Done'으로 view모드일 때는 'Edit'으로 표시
        setEditing(false, animated: true)
    }
    
    private func prepareForEditing() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didCancelEdit))
        updateSnapshotForEditing()
    }
    
    private func updateSnapshotForEditing() {
        var snapshot = Snapshot()
        snapshot.appendSections([.title, .date, .notes])
        snapshot.appendItems([.header(Section.title.name), .editText(reminder.title)], toSection: .title)
        snapshot.appendItems([.header(Section.date.name), .editDate(reminder.dueDate)], toSection: .date)
        snapshot.appendItems([.header(Section.notes.name), .editText(reminder.notes)], toSection: .notes)
        dataSource.apply(snapshot)
    }
    private func updateSnapshotForViewing() {
        var snapshot = Snapshot()
//        snapshot.appendSections([0])
//        snapshot.appendItems([.viewTitle, .viewDate, .viewTime, .viewNotes], toSection: 0)
        snapshot.appendSections([.view])
        snapshot.appendItems([.header(""), .viewTitle, .viewDate, .viewTime, .viewNotes], toSection: .view)
        dataSource.apply(snapshot)
    }
    //user가 editing mode에 들어가거나 나올때 수행하는 task정의
    private func prepareForViewing() {
        //prepareForViewing일 때 left bar button item제거
        navigationItem.leftBarButtonItem = nil
        if workingReminder != reminder {
            reminder = workingReminder
        }
        updateSnapshotForViewing()
    }
    
    private func section(for indexPath: IndexPath) -> Section {
        let sectionNumber = isEditing ? indexPath.section + 1 : indexPath.section
        guard let section = Section(rawValue: sectionNumber) else {
            fatalError("Unable to find matching section")
        }
        return section
    }
}
