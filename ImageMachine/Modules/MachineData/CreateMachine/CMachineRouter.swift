//
//  CMachineRouter.swift
//  ImageMachine
//
//  Created by Elang Putra Sartika on 04/08/21.
//

import UIKit

protocol ICMachineRouter {
	func pop()
}

class CMachineRouter: ICMachineRouter {	
	weak var view: CMachineViewController?
	
	init(view: CMachineViewController?) {
		self.view = view
	}
    
    func pop() {
        view?.navigationController?.popViewController(animated: true)
    }
}
