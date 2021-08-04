//
//  ListMachineRouter.swift
//  ImageMachine
//
//  Created by Elang Putra Sartika on 03/08/21.
//

import Foundation

protocol IListMachineRouter: AnyObject {
    func showMachine(code: String)
    func createMachine()
}

class ListMachineRouter: IListMachineRouter {
    weak var view: ListMachineViewController?

    init(view: ListMachineViewController?) {
        self.view = view
    }
    
    func showMachine(code: String) {
        let module = CRRoute.detailMachine(code: code)
        view?.navigate(type: .push, module: module, completion: nil)
    }
    
    func createMachine() {
        view?.navigate(type: .push, module: CRRoute.createMachine, completion: nil)
    }
}
