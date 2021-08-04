//
//  EMachineFactory.swift
//  ImageMachine
//
//  Created by Elang Putra Sartika on 04/08/21.
//

import Foundation

struct EMachineFactory {
    static func setup(code: String) -> EMachineViewController {
        let viewModel = EMachineViewModel(code: code)
        let controller = EMachineViewController(viewModel: viewModel)
        let router = EMachineRouter(view: controller)

        viewModel.delegate = controller
        controller.router = router
        return controller
    }
}
