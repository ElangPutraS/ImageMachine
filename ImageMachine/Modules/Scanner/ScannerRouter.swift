//
//  ScannerRouter.swift
//  ImageMachine
//
//  Created by Elang Putra Sartika on 03/08/21.
//

import Foundation

protocol IScannerRouter: AnyObject {
    func pushToMachineDetail(code: String)
}

class ScannerRouter: IScannerRouter {
    weak var view: ScannerViewController?

    init(view: ScannerViewController?) {
        self.view = view
    }

    func pushToMachineDetail(code: String) {
        let module = CRRoute.detailMachine(code: code)
        view?.navigationController?.popToRootViewController(animated: true)
        view?.navigate(type: .push, module: module, completion: nil)
    }
}
