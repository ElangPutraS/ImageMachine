//
//  CRRoute.swift
//  ImageMachine
//
//  Created by Elang Putra Sartika on 03/08/21.
//

import UIKit

enum CRRoute: IRouter {
    case home
    case listMachine
    case detailMachine(code: String)
    case createMachine
    case editMachine(code: String)
    case scanner
    case imageView(image: UIImage)
}

extension CRRoute {
    var module: UIViewController? {
        switch self {
        case .home:
            return HomeFactory.setup()
        case .listMachine:
            return ListMachineFactory.setup()
        case .detailMachine(let code):
            return MachineFactory.setup(code: code)
        case .createMachine:
            return CMachineFactory.setup()
        case .editMachine(let code):
            return EMachineFactory.setup(code: code)
        case .scanner:
            return ScannerFactory.setup()
        case .imageView(let image):
            return ImageViewController(image: image)
        }
    }
}
