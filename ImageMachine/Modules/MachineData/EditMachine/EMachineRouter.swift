//
//  EMachineRouter.swift
//  ImageMachine
//
//  Created by Elang Putra Sartika on 04/08/21.
//

import UIKit

protocol IEMachineRouter {
    func pop()
    func toRoot()
    func pushToImageView(image: UIImage)
}

class EMachineRouter: IEMachineRouter {	
	weak var view: EMachineViewController?
	
	init(view: EMachineViewController?) {
		self.view = view
	}
    
    func pop() {
        view?.navigationController?.popViewController(animated: true)
    }
    
    func toRoot() {
        view?.navigationController?.popToRootViewController(animated: true)
    }
    
    func pushToImageView(image: UIImage) {
        view?.navigate(type: .presentWithNavigation, module: CRRoute.imageView(image: image), completion: nil)
    }
}
