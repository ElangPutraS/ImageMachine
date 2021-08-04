//
//  MachineRouter.swift
//  ImageMachine
//
//  Created by Elang Putra Sartika on 04/08/21.
//

import UIKit

protocol IMachineRouter {
    func pop()
    func pushToEdit(code: String)
    func pushToImageView(image: UIImage)
}

class MachineRouter: IMachineRouter {	
	weak var view: MachineViewController?
	
	init(view: MachineViewController?) {
		self.view = view
	}
    
    func pop() {
        view?.navigationController?.popViewController(animated: true)
    }
    
    func pushToEdit(code: String) {
        view?.navigate(type: .push, module: CRRoute.editMachine(code: code), completion: nil)
    }
    
    func pushToImageView(image: UIImage) {
        view?.navigate(type: .presentWithNavigation, module: CRRoute.imageView(image: image), completion: nil)
    }
}
