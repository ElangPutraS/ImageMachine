//
//  ListMachineFactory.swift
//  ImageMachine
//
//  Created by Elang Putra Sartika on 03/08/21.
//

import Foundation

class ListMachineFactory {
    static func setup() -> ListMachineViewController {
        let viewModel = ListMachineViewModel()
        let controller = ListMachineViewController(viewModel: viewModel)
        let router = ListMachineRouter(view: controller)

        viewModel.delegate = controller
        controller.router = router
        return controller
    }
}
