//
//  TextFieldContentView.swift
//  UIKit-tutorial-jimin
//
//  Created by Jeon Jimin on 2022/07/10.
//

import UIKit

class TextFieldContentView: UIView, UIContentView {
    
    //TextFieldContentView.Configuration 타입을 사용하여 configuration및 view를 customize함
    struct Configuration: UIContentConfiguration {
        var text: String? = ""
        var onChange: (String)->Void = { _ in }
        
        //UIContentConfiguration protocol을 준수하기 위해 포함해야하는 최종 동작
        func makeContentView() -> UIView & UIContentView {
            return TextFieldContentView(self)
        }
        
    }
    
    let textField = UITextField()
    //configuration이 변경될때마다 uesr interface update
    var configuration: UIContentConfiguration {
        didSet{
            configure(configuration: configuration)
        }
    }
    //intrinsic고유의 content size를 고정시키기
    override var intrinsicContentSize: CGSize {
        CGSize(width: 0, height: 44)
    }
    
    init(_ configuration: UIContentConfiguration) {
        self.configuration = configuration
        super.init(frame: .zero)
        //텍스트필드 고정 및 horizontal padding 제공
        //top, bottom이 0이면 텍스트 필드가 super view 전체 높이에 걸쳐있게 됨
        addPinnedSubview(textField, insets: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16))
        //.editing Changed event에 대한 target and action 설정
        textField.addTarget(self, action: #selector(didChange(_:)), for: .editingChanged)
        //텍스트 필드에 내용이 있을 경우 빠르게 제거할 수 있게 clear button을 표시
        textField.clearButtonMode = .whileEditing
    }
    //UIView의 subclass는 custom initializer구현 시 required initializer도 구현해야함
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(configuration: UIContentConfiguration) {
        guard let configuration = configuration as? Configuration else {return}
        textField.text = configuration.text
    }
    
    @objc private func didChange(_ sender: UITextField) {
        //Configuration이 textField에 대해 만든 onChange handler를 호출하는지 확인
        guard let configuration = configuration as? TextFieldContentView.Configuration else { return }
        configuration.onChange(textField.text ?? "")
    }
}

//custom TextFieldContentView와 쌍을 이루는 custom configuration을 반환
extension UICollectionViewListCell {
    func textFieldConfiguration() -> TextFieldContentView.Configuration {
        TextFieldContentView.Configuration()
    }
}
