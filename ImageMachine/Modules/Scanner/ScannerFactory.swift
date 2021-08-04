//
//  ScannerFactory.swift
//  ImageMachine
//
//  Created by Elang Putra Sartika on 03/08/21.
//

import Foundation

struct ScannerFactory {
    static func setup() -> ScannerViewController {
        let viewModel = ScannerViewModel()
        let controller = ScannerViewController(viewModel: viewModel)
        let router = ScannerRouter(view: controller)
        
        viewModel.delegate = controller
        controller.router = router
        return controller
    }
}
