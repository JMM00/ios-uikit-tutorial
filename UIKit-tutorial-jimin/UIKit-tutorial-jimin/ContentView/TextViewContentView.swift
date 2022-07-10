//
//  TextViewContentView.swift
//  UIKit-tutorial-jimin
//
//  Created by Jeon Jimin on 2022/07/10.
//

import UIKit


//multiple lines of text
class TextViewContentView: UIView, UIContentView {
    struct Configuration: UIContentConfiguration {
        var text: String? = ""
        var onChange: (String) -> Void = { _ in }

        func makeContentView() -> UIView & UIContentView {
            return TextViewContentView(self)
        }
    }
    //textView는 스크롤view -> 고정 높이를 지정해도 사용자가 더 많은 텍스트 입력 시 자동으로 스크롤 적용
    let textView = UITextView()
    //configuration이 변경될때마다 uesr interface update
    var configuration: UIContentConfiguration {
        didSet{
            configure(configuration: configuration)
        }
    }
    
    override var intrinsicContentSize: CGSize {
        CGSize(width: 0, height: 44)
    }
    
    init(_ configuration: UIContentConfiguration) {
        self.configuration = configuration
        super.init(frame: .zero)
        addPinnedSubview(textView, height: 200)
        textView.backgroundColor = nil
        ///content view to be the delegate of the text view control
        /// user interaction에 대한 text view control을 monitor하고 응답함
        textView.delegate = self
        textView.font = UIFont.preferredFont(forTextStyle: .body)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(configuration: UIContentConfiguration) {
        guard let configuration = configuration as? Configuration else { return }
        textView.text = configuration.text
    }
}

extension UICollectionViewListCell {
    func textViewConfiguration() -> TextViewContentView.Configuration {
        TextViewContentView.Configuration()
    }
}
///helper object or delegate
///textView delegate 할당하거나 UITextViewDelegate프로토콜 준수하는 개채는 textView가 사용자 상호작용을 감지할 때 개입할 수 있음
extension TextViewContentView: UITextViewDelegate {
    //text view's delegate는 user interaction을 감지할 때 마다 함수 호출
    func textViewDidChange(_ textView: UITextView) {
        //cast configuration as a TextViewContentView.Configuration
        guard let configuration = configuration as? TextViewContentView.Configuration else { return }
        //call onChange handler
        configuration.onChange(textView.text)
    }
}
