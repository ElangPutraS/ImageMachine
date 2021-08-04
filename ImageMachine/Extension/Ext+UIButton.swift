//
//  Ext+UIButton.swift
//  ImageMachine
//
//  Created by Elang Putra Sartika on 04/08/21.
//

import UIKit

extension UIButton {
    func touchUpInside(_ target: Any?, action: Selector) {
        addTarget(target, action: action, for: .touchUpInside)
    }
}
