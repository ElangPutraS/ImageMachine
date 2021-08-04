//
//  HomeRouter.swift
//  ImageMachine
//
//  Created by Elang Putra Sartika on 03/08/21.
//

import Foundation

protocol IHomeRouter: AnyObject {
    func pushToListMachine()
    func pushToScanner()
}

class HomeRouter: IHomeRouter {
    weak var view: HomeViewController?

    init(view: HomeViewController?) {
        self.view = view
    }

    func pushToListMachine() {
        view?.navigate(type: .push, module: CRRoute.listMachine, completion: nil)
    }
    
    func pushToScanner() {
        view?.navigate(type: .push, module: CRRoute.scanner, completion: nil)
    }
}
