//
//  Buttons.swift
//  ContentAnimationUIKit
//
//  Created by Lea Marolt Sonnenschein on 05/08/2023.
//

import Foundation
import UIKit

enum ButtonStyle {
    case primary
    case primaryCorrect
    case primaryIncorrect
    case primaryDeemphasized
    case secondary
    case tertiary
    
    var bgColor: UIColor {
        switch self {
        case .primary:
            return .gray900
        case .secondary:
            return .white
        case .tertiary:
            return .clear
        case .primaryDeemphasized:
            return .black100
        case .primaryCorrect:
            return .green500
        case .primaryIncorrect:
            return .gray900
        }
    }
    
    var disabledBgColor: UIColor {
        return .black100
    }
    
    var fontColor: UIColor {
        switch self {
        case .primary, .primaryCorrect, .primaryIncorrect:
            return .white
        case .secondary, .tertiary, .primaryDeemphasized:
            return .black
        }
    }
    
    var disabledFontColor: UIColor {
        return .gray500
    }
    
    var borderWidth: CGFloat {
        switch self {
        case .primary, .tertiary, .primaryDeemphasized, .primaryCorrect, .primaryIncorrect:
            return 0
        case .secondary:
            return 2.0
        }
    }
    
    var borderColor: UIColor {
        switch self {
        case .primary, .tertiary, .primaryDeemphasized, .primaryCorrect, .primaryIncorrect:
            return .clear
        case .secondary:
            return .gray200
        }
    }
    
    var font: UIFont {
        return .semiBold(17)
    }
    
    var height: CGFloat {
        return 48.0
    }
    
    var cornerRadius: CGFloat {
        return 26.0
    }
}

class BitsButton: UIButton {
    
    var buttonStyle: ButtonStyle = .primary {
        didSet {
            backgroundColor = buttonStyle.bgColor
            layer.borderWidth = buttonStyle.borderWidth
            layer.borderColor = buttonStyle.borderColor.cgColor
            titleLabel?.font = buttonStyle.font
            setTitleColor(buttonStyle.fontColor, for: .normal)
            layer.cornerRadius = buttonStyle.cornerRadius
        }
    }
    
    override var isEnabled: Bool {
        didSet {
            UIView.animate(withDuration: 0.05) {
                if self.isEnabled {
                    self.backgroundColor = self.buttonStyle.bgColor
                    self.setTitleColor(self.buttonStyle.fontColor, for: .normal)
                } else {
                    self.backgroundColor = self.buttonStyle.disabledBgColor
                    self.setTitleColor(self.buttonStyle.disabledFontColor, for: .normal)
                }
            }
        }
    }
    
    static func create(withStyle style: ButtonStyle, title: String) -> BitsButton {
        let button = BitsButton()
        button.buttonStyle = style
        button.backgroundColor = style.bgColor
        button.layer.borderWidth = style.borderWidth
        button.layer.borderColor = style.borderColor.cgColor
        button.titleLabel?.font = style.font
        button.setTitleColor(style.fontColor, for: .normal)
        button.setTitle(title, for: .normal)
        button.layer.cornerRadius = style.cornerRadius
                
        return button
    }
}
