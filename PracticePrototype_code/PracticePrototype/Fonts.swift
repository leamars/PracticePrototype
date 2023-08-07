//
//  Fonts.swift
//  ContentAnimationUIKit
//
//  Created by Lea Marolt Sonnenschein on 05/08/2023.
//

import Foundation
import UIKit

extension UIFont {
    
    static func book(_ size: CGFloat) -> UIFont {
        return UIFont(name: "Soleil-Book", size: size) ?? .systemFont(ofSize: size)
    }

    static func regular(_ size: CGFloat) -> UIFont {
        return UIFont(name: "Soleil-Regular", size: size) ?? .systemFont(ofSize: size)
    }

    static func light(_ size: Double) -> UIFont {
        return UIFont(name: "Soleil-Light", size: CGFloat(size)) ?? .systemFont(ofSize: CGFloat(size), weight: .light)
    }
    
    static func semiBold(_ size: Double) -> UIFont {
        return UIFont(name: "SoleilW02-SemiBold", size: CGFloat(size)) ?? .systemFont(ofSize: CGFloat(size), weight: .semibold)
    }

    static func bold(_ size: Double) -> UIFont {
        return UIFont(name: "Soleil-Bold", size: CGFloat(size)) ?? .boldSystemFont(ofSize: CGFloat(size))
    }
    
    static func katex_main_regular(_ size: Double) -> UIFont {
        return UIFont(name: "KaTeX_Main-Regular", size: CGFloat(size)) ?? .monospacedSystemFont(ofSize: CGFloat(size), weight: .regular)
    }
}
