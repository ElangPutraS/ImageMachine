//
//  ToastView.swift
//  ImageMachine
//
//  Created by Elang Putra Sartika on 03/08/21.
//

import UIKit

class ToastView: CustomXIBView {
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var subView: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    
    override func setupComponent() {
        contentView.fixInView(self)
    }
}
