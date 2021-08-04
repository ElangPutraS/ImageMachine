//
//  MachineViewModel.swift
//  ImageMachine
//
//  Created by Elang Putra Sartika on 04/08/21.
//

import UIKit
import CoreData

protocol IMachineDelegate {
    func didSuccessGetMachine()
    func didSuccessDeleteMachine()
    func didFailDeleteMachine()
    func didSuccessGetImages()
    func didFailGetImages()
    func didSuccessDeleteImages()
    func didFailDeleteImages()
}

class MachineViewModel {
    var machinesStore: MachinesCoreDataStore
    var machinesWorker: MachinesWorker?
    var delegate: IMachineDelegate?
    var code: String!
    var images: [ImageModel?]
    var data: MachineModel?
    
    init(code: String) {
        self.code = code
        self.machinesStore = MachinesCoreDataStore()
        self.machinesWorker = MachinesWorker(machinesStore: machinesStore)
        self.images = []
    }
    
    func getMachine()
    {
        machinesWorker?.fetchMachine(code: code) { (machine, err) -> Void in
            self.data = machine
            
            self.delegate?.didSuccessGetMachine()
        }
    }
    
    func getImages() {
        machinesStore.privateManagedObjectContext.performAndWait {
          do {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Image")
            fetchRequest.predicate = NSPredicate(format: "id == %@", data?.id ?? "")
            let results = try self.machinesStore.privateManagedObjectContext.fetch(fetchRequest) as! [Image]
            images = results.map { $0.toImage() }
            delegate?.didSuccessGetImages()
          } catch {
            delegate?.didFailGetImages()
          }
        }
    }
    
    func deleteMachine()
    {
        machinesWorker?.deleteMachine(id: data?.id ?? "") { (machine, err) -> Void in
            if err != nil {
                self.delegate?.didFailDeleteMachine()
            } else {
                self.delegate?.didSuccessDeleteMachine()
            }
        }
    }
    
    func deleteImages() {
        do {
            machinesStore.privateManagedObjectContext.performAndWait {
              do {
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Image")
                fetchRequest.predicate = NSPredicate(format: "id == %@", data?.id ?? "")
                let results = try self.machinesStore.privateManagedObjectContext.fetch(fetchRequest) as! [Image]
                images = results.map { $0.toImage() }
                for item in results {
                    self.machinesStore.privateManagedObjectContext.delete(item)
                }
                try self.machinesStore.privateManagedObjectContext.save()
              } catch {
                self.delegate?.didFailDeleteImages()
              }
            }
            try self.machinesStore.mainManagedObjectContext.save()
            self.delegate?.didSuccessDeleteImages()
          } catch {
            self.delegate?.didFailDeleteImages()
          }
    }
}
