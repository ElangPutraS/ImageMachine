//
//  CMachineViewModel.swift
//  ImageMachine
//
//  Created by Elang Putra Sartika on 04/08/21.
//

import UIKit

protocol ICMachineDelegate {
    func didSuccessCreate()
    func didFailCreate()
    func didSuccessUpload()
    func didFailUpload()
}

class CMachineViewModel {
    var delegate: ICMachineDelegate?
    var name: String!
    var type: String!
    var qrCode: String!
    var date: Date!
    var data: MachineModel?
    var images: [UIImage?]
    var machineStore: MachinesCoreDataStore
    var machinesWorker: MachinesWorker
    
    init() {
        self.name = ""
        self.type = ""
        self.qrCode = ""
        self.date = Date()
        self.machineStore = MachinesCoreDataStore()
        self.machinesWorker = MachinesWorker(machinesStore: machineStore)
        self.images = []
    }

    // MARK: - Create machine
    
    func createMachine()
    {
      data = buildMachine()
      
        machinesWorker.createMachine(machineToCreate: data ?? MachineModel()) { (machine, err) in
        if err != nil {
            self.delegate?.didFailCreate()
        } else {
            self.delegate?.didSuccessCreate()
        }
      }
    }
    
    func createPhotos()
    {
        do {
            machineStore.privateManagedObjectContext.performAndWait {
              do {
                for image in self.images {
                    let imageContext = Image(context: self.machineStore.privateManagedObjectContext)
                    imageContext.id = data?.id
                    imageContext.img = image?.pngData()
                }
                try self.machineStore.privateManagedObjectContext.save()
              } catch {
                self.delegate?.didFailUpload()
              }
            }
            try self.machineStore.mainManagedObjectContext.save()
            delegate?.didSuccessUpload()
        } catch {
            delegate?.didFailUpload()
        }
    }
    
    // MARK: - Helper function
    
    private func buildMachine() -> MachineModel
    {
        return MachineModel(id: UUID().uuidString,
                            name: name, type: type,
                            codeNumber: qrCode,
                            updatedAt: date,
                            image: nil)
    }
}
