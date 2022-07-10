//
//  UIView+PinnedSubview.swift
//  UIKit-tutorial-jimin
//
//  Created by Jeon Jimin on 2022/07/10.
//

import UIKit

extension UIView {
    func addPinnedSubview(_ subview: UIView, height: CGFloat? = nil, insets: UIEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)) {
        addSubview(subview)
        //자동 constraints 해제
        subview.translatesAutoresizingMaskIntoConstraints = false
        //constraints 정의 및 활성화
        subview.topAnchor.constraint(equalTo: topAnchor, constant: insets.top).isActive = true
        //child viw에 제공할 horizontal padding 값 정의
        subview.leadingAnchor.constraint(equalTo: leadingAnchor, constant: insets.left).isActive = true
        subview.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -1.0 * insets.right).isActive = true
        subview.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1.0 * insets.bottom).isActive = true
        
        //caller가 함수에 높이를 명시적으로 제공하는 경우 하위 뷰를 해당 높이로 제한
        if let height = height {
            subview.heightAnchor.constraint(equalToConstant: height).isActive = true
        }
        //subview가 superview의 상단과 하단에 고정되어있기 때문에 subview의 높이가 조정되면 superview의 높이도 조정해야함
    }
}
