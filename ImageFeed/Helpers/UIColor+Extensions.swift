//
//  UIColor+Extensions.swift
//  ImageFeed
//
//  Created by Анастасия on 10.10.2023.
//

import Foundation
import UIKit

extension UIColor {
    static var ypBlack: UIColor { UIColor(named: "YP Black") ?? UIColor.black }
    static var ypWhite: UIColor { UIColor(named: "YP White") ?? UIColor.white }
    static var ypWhiteAlpha: UIColor { UIColor(named: "YP White (Alpha 50)") ?? UIColor.white }
    static var ypBlue: UIColor { UIColor(named: "YP Blue") ?? UIColor.blue }
    static var ypGray: UIColor { UIColor(named: "YP Gray") ?? UIColor.gray }
    static var ypBackground: UIColor { UIColor(named: "YP Background") ?? UIColor.darkGray }
    static var ypRed: UIColor { UIColor(named: "YP Red") ?? UIColor.red }
}
