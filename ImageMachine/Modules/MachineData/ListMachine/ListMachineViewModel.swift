//
//  ListMachineViewModel.swift
//  ImageMachine
//
//  Created by Elang Putra Sartika on 03/08/21.
//

import Foundation

protocol ListMachineViewModelDelegate {
    func didSuccessGetList()
    func didFailGetList(errorMsg: String)
}

class ListMachineViewModel {
    var delegate: ListMachineViewModelDelegate?
    var list: [MachineModel] = []
    var machinesStore: MachinesCoreDataStore
    var machinesWorker: MachinesWorker?
    
    init() {
        self.machinesStore = MachinesCoreDataStore()
        self.machinesWorker = MachinesWorker(machinesStore: machinesStore)
    }
    
    func fetchMachines()
    {
        machinesWorker?.fetchMachines { (machines) -> Void in
            self.list = machines
            self.delegate?.didSuccessGetList()
        }
    }
}
