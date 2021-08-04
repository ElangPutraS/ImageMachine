//
//  HomeFactory.swift
//  ImageMachine
//
//  Created by Elang Putra Sartika on 03/08/21.
//

import Foundation

class HomeFactory {
    static func setup() -> HomeViewController {
        let viewModel = HomeViewModel()
        let controller = HomeViewController(viewModel: viewModel)
        let router = HomeRouter(view: controller)

        controller.router = router
        return controller
    }
}
