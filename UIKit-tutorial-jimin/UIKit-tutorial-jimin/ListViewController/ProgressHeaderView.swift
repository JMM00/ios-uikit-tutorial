//
//  ProgressHeaderView.swift
//  UIKit-tutorial-jimin
//
//  Created by Jeon Jimin on 2022/07/14.
//

import UIKit

class ProgressHeaderView: UICollectionReusableView {
    static var elementKind: String { UICollectionView.elementKindSectionHeader}
    
    var progress: CGFloat = 0 {
        //진행률 값이 변경될 때 높이 제약조건을 업데이트하는 관찰자를 진행률 속성에 추가
        didSet {
            //진행상황이 변경될 때마다 progress view를 업데이트
            setNeedsLayout()
            heightConstraint?.constant = progress * bounds.height
            UIView.animate(withDuration: 0.2) { [weak self] in
                // layoutIfNeed메서드는 위쪽 및 아래쪽 보기의 높이 변겨엥 애니메이션 적용하여 view layout즉시 업데이트
                self?.layoutIfNeeded()
            }
        }
    }
    
    private let upperView = UIView(frame:  .zero)
    private let lowerView = UIView(frame: .zero)
    private let containerView = UIView(frame: .zero)
    private var heightConstraint: NSLayoutConstraint?
    private var valueFormat: String { NSLocalizedString("%d percent", comment: "progress percentage value format")}
    
    override init(frame: CGRect){
        super.init(frame: frame)
        prepareSubview()
        
        //해당 요소가 assistive technoloty가 접근할 수 있는 요소인지 접근성 여부를 나타냄 / 표준 UIKit 컨트롤은 기본적으로 값 활성화
        isAccessibilityElement = true
        accessibilityLabel = NSLocalizedString("Progress", comment: "Progress view accessibility label")
        accessibilityTraits.update(with: .updatesFrequently)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //cornerRadius를 사용하여 원 만듦, 크기가 변경될 때마다 cornerRadius 조정할 수 있도록 layout동작을 사용자 정의
    override func layoutSubviews() {
        super.layoutSubviews()
        //접근성 값에 progress값과 valueFormat값을 사용하여 새 문자열 할당
        accessibilityValue = String(format: valueFormat, Int(progress * 100.0))
        heightConstraint?.constant = progress * bounds.height
        containerView.layer.masksToBounds = true
        containerView.layer.cornerRadius = 0.5 * containerView.bounds.width
    }
    
    // 뷰를 초기화할 때 이 메서드를 호출
    private func prepareSubview() {
        containerView.addSubview(upperView)
        containerView.addSubview(lowerView)
        addSubview(containerView)
        
        //subview의 제약조건을 수정할 수 있도록 traslateAutoresizingMaskIntoConstraints비활성화
        //true인 경우 크기와 위치를 자동으로 지정
        upperView.translatesAutoresizingMaskIntoConstraints = false
        lowerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        //supter viw, container view에 대해 1:1 고정 종횡비를 유지
        heightAnchor.constraint(equalTo: widthAnchor, multiplier: 1).isActive = true
        containerView.heightAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 1).isActive = true
        
        //레이아웃 프레임에서 컨테이너 보기를 가로 및 세로 중앙에 배치
        containerView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        //container view를 super view 크긱의 85%로 조정
        //containverview에 대해 고정 종횡비를 이미 설정했기 때문에 하나의 축에 대해서만 multiplier를 설정해야함
        containerView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.85).isActive = true
        
        upperView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        upperView.bottomAnchor.constraint(equalTo: lowerView.topAnchor).isActive = true
        lowerView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        //subview를 수직으로 제한
        upperView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        upperView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        lowerView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        lowerView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        //adjustable height 제약 생성, height anchor 시작 크기 0으로 지정
        //이 제약조건이 증가 시 높이는 반비례
        heightConstraint = lowerView.heightAnchor.constraint(equalToConstant: 0)
        heightConstraint?.isActive = true
        
        backgroundColor = .clear
        containerView.backgroundColor = .clear
        upperView.backgroundColor = .todayProgressUpperBackground
        lowerView.backgroundColor = .todayProgressLowerBackground
        
        
    }
}
