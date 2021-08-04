//
//  CMachineFactory.swift
//  ImageMachine
//
//  Created by Elang Putra Sartika on 04/08/21.
//

import Foundation

struct CMachineFactory {
    static func setup() -> CMachineViewController {
        let viewModel = CMachineViewModel()
        let controller = CMachineViewController(viewModel: viewModel)
        let router = CMachineRouter(view: controller)

        viewModel.delegate = controller
        controller.router = router
        return controller
    }
}
