//
//  EMachineViewModel.swift
//  ImageMachine
//
//  Created by Elang Putra Sartika on 04/08/21.
//

import UIKit
import CoreData

protocol IEMachineDelegate {
    func didSuccessUpdate()
    func didFailUpdate()
    func didSuccessGetMachine()
    func didFailGetMachine()
    func didSuccessDeleteImages()
    func didFailDeleteImages()
    func didSuccessUpload()
    func didFailUpload()
    func didSuccessGetImages()
    func didFailGetImages()
}

class EMachineViewModel {
    var delegate: IEMachineDelegate?
    var code: String
    var data: MachineModel?
    var images: [UIImage]?
    var displayedImages: [ImageModel?]
    var machineStore: MachinesCoreDataStore
    var machinesWorker: MachinesWorker?
    
    init(code: String) {
        self.code = code
        self.machineStore = MachinesCoreDataStore()
        self.machinesWorker = MachinesWorker(machinesStore: machineStore)
        self.displayedImages = []
    }

    // MARK: - Create machine
    
    func updateMachine()
    {
        guard let updatedData = data else {
            return
        }
        machinesWorker?.updateMachine(machineToUpdate: updatedData) { (machine, err) in
        if err != nil {
            self.delegate?.didFailUpdate()
        } else {
            do {
                try self.machineStore.mainManagedObjectContext.save()
                self.delegate?.didSuccessUpdate()
            } catch  {
                self.delegate?.didFailUpdate()
            }
        }
      }
    }
    
    func getMachine()
    {
        machinesWorker?.fetchMachine(code: code) { (machine, err) -> Void in
            if err != nil {
                self.delegate?.didFailGetMachine()
            } else {
                self.data = machine
                self.delegate?.didSuccessGetMachine()
            }
            
        }
    }
    
    func getImages() {
        machineStore.privateManagedObjectContext.performAndWait {
          do {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Image")
            fetchRequest.predicate = NSPredicate(format: "id == %@", data?.id ?? "")
            let results = try self.machineStore.privateManagedObjectContext.fetch(fetchRequest) as! [Image]
            displayedImages = results.map { $0.toImage() }
            delegate?.didSuccessGetImages()
          } catch {
            delegate?.didFailGetImages()
          }
        }
    }
    
    func deleteImages() {
        do {
            machineStore.privateManagedObjectContext.performAndWait {
              do {
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Image")
                fetchRequest.predicate = NSPredicate(format: "id == %@", data?.id ?? "")
                let results = try self.machineStore.privateManagedObjectContext.fetch(fetchRequest) as! [Image]
                for item in results {
                    self.machineStore.privateManagedObjectContext.delete(item)
                }
                try self.machineStore.privateManagedObjectContext.save()
              } catch {
                self.delegate?.didFailDeleteImages()
              }
            }
            try self.machineStore.mainManagedObjectContext.save()
            self.delegate?.didSuccessDeleteImages()
          } catch {
            self.delegate?.didFailDeleteImages()
          }
    }
    
    func createPhotos()
    {
        do {
            machineStore.privateManagedObjectContext.performAndWait {
              do {
                for image in self.images ?? [] {
                    let imageContext = Image(context: self.machineStore.privateManagedObjectContext)
                    imageContext.id = data?.id
                    imageContext.img = image.pngData()
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
}
