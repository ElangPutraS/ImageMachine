//
//  ScannerViewModel.swift
//  ImageMachine
//
//  Created by Elang Putra Sartika on 03/08/21.
//

import Foundation

protocol IScannerDelegate {
    func didSuccessGetMachine(code: String)
    func didFailGetMachine(err: String)
}

class ScannerViewModel {
    var machinesStore: MachinesCoreDataStore
    var machinesWorker: MachinesWorker?
    var delegate: IScannerDelegate?
    
    init() {
        self.machinesStore = MachinesCoreDataStore()
        self.machinesWorker = MachinesWorker(machinesStore: machinesStore)
    }

    func getMachine(code: String)
    {
        machinesWorker?.fetchMachine(code: code) { (machine, err) -> Void in
            if err != nil {
                self.delegate?.didFailGetMachine(err: "Invalid code \(code)")
            } else {
                self.delegate?.didSuccessGetMachine(code: code)
            }
        }
    }
}
