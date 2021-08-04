//
//  MachineFactory.swift
//  ImageMachine
//
//  Created by Elang Putra Sartika on 04/08/21.
//

import Foundation

struct MachineFactory {
    static func setup(code: String) -> MachineViewController {
        let viewModel = MachineViewModel(code: code)
        let controller = MachineViewController(viewModel: viewModel)
        let router = MachineRouter(view: controller)

        viewModel.delegate = controller
        controller.router = router
        return controller
    }
}
