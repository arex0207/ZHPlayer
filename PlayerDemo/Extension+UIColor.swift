//
//  Extension+UIColor.swift
//  PlayerDemo
//
//  Created by Arex on 2020/11/27.
//  Copyright © 2020 Arex. All rights reserved.
//

import UIKit

import Foundation

extension UIColor {

    static let system = UIColor(hex: 0x035d9a)
    static let background = UIColor(hex: 0xf4f5f7)
    static let systemGray = UIColor(hex: 0xe2e2e2)
    
    public class func colorWithHex(rgb:Int) -> UIColor {
        return colorWithHex(rgb: rgb, alpha: 1)
    }
    
    public class func colorWithHex(rgb:Int, alpha: CGFloat) -> UIColor {
        return UIColor(red: ((CGFloat)((rgb & 0xFF0000) >> 16))/255.0, green: ((CGFloat)((rgb & 0xFF00) >> 8))/255.0, blue: ((CGFloat)(rgb & 0xFF)) / 255.0, alpha: alpha)
    }
    
    convenience init(hex: Int) {
        self.init(red: CGFloat((hex >> 16) & 0xff), green: CGFloat((hex >> 8) & 0xff), blue: CGFloat(hex & 0xff), alpha: 1)
    }
    
    convenience init(hex: Int,alpha:Int) {
        self.init(red: CGFloat((hex >> 16) & 0xff), green: CGFloat((hex >> 8) & 0xff), blue: CGFloat(hex & 0xff), alpha: CGFloat(alpha))
    }
    
    // 随机颜色
    class var randomColor:UIColor {
        get {
            let red = CGFloat(arc4random()%256)/255.0
            let green = CGFloat(arc4random()%256)/255.0
            let blue = CGFloat(arc4random()%256)/255.0
            return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
        }
    }
}
