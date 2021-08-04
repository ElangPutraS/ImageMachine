//
//  MachinesCoreData.swift
//  ImageMachine
//
//  Created by Elang Putra Sartika on 04/08/21.
//

import CoreData

class MachinesCoreDataStore: MachinesStoreProtocol, MachinesStoreUtilityProtocol
{
  // MARK: - Managed object contexts
  
  var mainManagedObjectContext: NSManagedObjectContext
  var privateManagedObjectContext: NSManagedObjectContext
  
  // MARK: - Object lifecycle
  
  init()
  {
    // This resource is the same name as your xcdatamodeld contained in your project.
    guard let modelURL = Bundle.main.url(forResource: "ImageMachine", withExtension: "momd") else {
      fatalError("Error loading model from bundle")
    }
    
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    guard let mom = NSManagedObjectModel(contentsOf: modelURL) else {
      fatalError("Error initializing mom from: \(modelURL)")
    }
    
    let psc = NSPersistentStoreCoordinator(managedObjectModel: mom)
    mainManagedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    mainManagedObjectContext.persistentStoreCoordinator = psc
    
    let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    let docURL = urls[urls.endIndex-1]
    /* The directory the application uses to store the Core Data store file.
    This code uses a file named "DataModel.sqlite" in the application's documents directory.
    */
    let storeURL = docURL.appendingPathComponent("ImageMachine.sqlite")
    do {
      try psc.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: nil)
    } catch {
      fatalError("Error migrating store: \(error)")
    }
    
    privateManagedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
    privateManagedObjectContext.parent = mainManagedObjectContext
  }
  
  // MARK: - CRUD operations - Optional error
  
  func fetchMachines(completionHandler: @escaping ([MachineModel], MachinesStoreError?) -> Void)
  {
    privateManagedObjectContext.performAndWait {
      do {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Machine")
        let results = try self.privateManagedObjectContext.fetch(fetchRequest) as! [Machine]
        let machines = results.map { $0.toMachine() }
        completionHandler(machines, nil)
      } catch {
        completionHandler([], MachinesStoreError.CannotFetch("Cannot fetch machines"))
      }
    }
  }
  
  func fetchMachine(id: String, completionHandler: @escaping (MachineModel?, MachinesStoreError?) -> Void)
  {
    privateManagedObjectContext.performAndWait {
      do {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Machine")
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        let results = try self.privateManagedObjectContext.fetch(fetchRequest) as! [Machine]
        if let machine = results.first?.toMachine() {
          completionHandler(machine, nil)
        } else {
          completionHandler(nil, MachinesStoreError.CannotFetch("Cannot fetch machine with id \(id)"))
        }
      } catch {
        completionHandler(nil, MachinesStoreError.CannotFetch("Cannot fetch machine with id \(id)"))
      }
    }
  }
    
    func fetchMachine(code: String, completionHandler: @escaping (MachineModel?, MachinesStoreError?) -> Void)
    {
      privateManagedObjectContext.performAndWait {
        do {
          let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Machine")
          fetchRequest.predicate = NSPredicate(format: "codeNumber == %@", code)
          let results = try self.privateManagedObjectContext.fetch(fetchRequest) as! [Machine]
          if let machine = results.first?.toMachine() {
            completionHandler(machine, nil)
          } else {
            completionHandler(nil, MachinesStoreError.CannotFetch("Cannot fetch machine with code \(code)"))
          }
        } catch {
          completionHandler(nil, MachinesStoreError.CannotFetch("Cannot fetch machine with code \(code)"))
        }
      }
    }
  
  func createMachine(machineToCreate: MachineModel, completionHandler: @escaping (MachineModel?, MachinesStoreError?) -> Void)
  {
    privateManagedObjectContext.performAndWait {
      do {
        let managedMachine = NSEntityDescription.insertNewObject(forEntityName: "Machine", into: self.privateManagedObjectContext) as! Machine
        var machine = machineToCreate
        self.generateMachineID(machine: &machine)
        managedMachine.fromMachine(machine: machine)
        try self.privateManagedObjectContext.save()
        try self.mainManagedObjectContext.save()
        completionHandler(machine, nil)
      } catch {
        completionHandler(nil, MachinesStoreError.CannotCreate("Cannot create machine with id \(String(describing: machineToCreate.id))"))
      }
    }
  }
  
  func updateMachine(machineToUpdate: MachineModel, completionHandler: @escaping (MachineModel?, MachinesStoreError?) -> Void)
  {
    privateManagedObjectContext.performAndWait {
      do {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Machine")
        fetchRequest.predicate = NSPredicate(format: "id == %@", machineToUpdate.id!)
        let results = try self.privateManagedObjectContext.fetch(fetchRequest) as! [Machine]
        if let managedMachine = results.first {
          do {
            managedMachine.fromMachine(machine: machineToUpdate)
            let machine = managedMachine.toMachine()
            try self.privateManagedObjectContext.save()
            completionHandler(machine, nil)
          } catch {
            completionHandler(nil, MachinesStoreError.CannotUpdate("Cannot update machine with id \(String(describing: machineToUpdate.id))"))
          }
        }
      } catch {
        completionHandler(nil, MachinesStoreError.CannotUpdate("Cannot fetch machine with id \(String(describing: machineToUpdate.id)) to update"))
      }
    }
  }
  
  func deleteMachine(id: String, completionHandler: @escaping (MachineModel?, MachinesStoreError?) -> Void)
  {
    privateManagedObjectContext.performAndWait {
      do {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Machine")
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        let results = try self.privateManagedObjectContext.fetch(fetchRequest) as! [Machine]
        if let managedMachine = results.first {
          let machine = managedMachine.toMachine()
          self.privateManagedObjectContext.delete(managedMachine)
          do {
            try self.privateManagedObjectContext.save()
            try self.mainManagedObjectContext.save()
            completionHandler(machine, nil)
          } catch {
            completionHandler(nil, MachinesStoreError.CannotDelete("Cannot delete machine with id \(id)"))
          }
        } else {
          throw MachinesStoreError.CannotDelete("Cannot fetch machine with id \(id) to delete")
        }
      } catch {
        completionHandler(nil, MachinesStoreError.CannotDelete("Cannot fetch machine with id \(id) to delete"))
      }
    }
  }
  
  // MARK: - CRUD operations - Generic enum result type
  
  func fetchMachines(completionHandler: @escaping MachinesStoreFetchMachinesCompletionHandler)
  {
    privateManagedObjectContext.performAndWait {
      do {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Machine")
        let results = try self.privateManagedObjectContext.fetch(fetchRequest) as! [Machine]
        let machines = results.map { $0.toMachine() }
        completionHandler(MachinesStoreResult.Success(result: machines))
      } catch {
        completionHandler(MachinesStoreResult.Failure(error: MachinesStoreError.CannotFetch("Cannot fetch machines")))
      }
    }
  }
  
  func fetchMachine(id: String, completionHandler: @escaping MachinesStoreFetchMachineCompletionHandler)
  {
    privateManagedObjectContext.performAndWait {
      do {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Machine")
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        let results = try self.privateManagedObjectContext.fetch(fetchRequest) as! [Machine]
        if let machine = results.first?.toMachine() {
          completionHandler(MachinesStoreResult.Success(result: machine))
        } else {
          completionHandler(MachinesStoreResult.Failure(error: MachinesStoreError.CannotFetch("Cannot fetch machine with id \(id)")))
        }
      } catch {
        completionHandler(MachinesStoreResult.Failure(error: MachinesStoreError.CannotFetch("Cannot fetch machine with id \(id)")))
      }
    }
  }
    
    
    func fetchMachine(code: String, completionHandler: @escaping MachinesStoreFetchMachineCompletionHandler)
    {
      privateManagedObjectContext.performAndWait {
        do {
          let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Machine")
          fetchRequest.predicate = NSPredicate(format: "codeNumber == %@", code)
          let results = try self.privateManagedObjectContext.fetch(fetchRequest) as! [Machine]
          if let machine = results.first?.toMachine() {
            completionHandler(MachinesStoreResult.Success(result: machine))
          } else {
            completionHandler(MachinesStoreResult.Failure(error: MachinesStoreError.CannotFetch("Cannot fetch machine with code \(code)")))
          }
        } catch {
          completionHandler(MachinesStoreResult.Failure(error: MachinesStoreError.CannotFetch("Cannot fetch machine with code \(code)")))
        }
      }
    }
  
  func createMachine(machineToCreate: MachineModel, completionHandler: @escaping MachinesStoreCreateMachineCompletionHandler)
  {
    privateManagedObjectContext.performAndWait {
      do {
        let managedMachine = NSEntityDescription.insertNewObject(forEntityName: "Machine", into: self.privateManagedObjectContext) as! Machine
        var machine = machineToCreate
        self.generateMachineID(machine: &machine)
        managedMachine.fromMachine(machine: machine)
        try self.privateManagedObjectContext.save()
        try self.mainManagedObjectContext.save()
        completionHandler(MachinesStoreResult.Success(result: machine))
      } catch {
        let error = MachinesStoreError.CannotCreate("Cannot create machine with id \(String(describing: machineToCreate.id))")
        completionHandler(MachinesStoreResult.Failure(error: error))
      }
    }
  }
  
  func updateMachine(machineToUpdate: MachineModel, completionHandler: @escaping MachinesStoreUpdateMachineCompletionHandler)
  {
    privateManagedObjectContext.performAndWait {
      do {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Machine")
        fetchRequest.predicate = NSPredicate(format: "id == %@", machineToUpdate.id!)
        let results = try self.privateManagedObjectContext.fetch(fetchRequest) as! [Machine]
        if let managedMachine = results.first {
          do {
            managedMachine.fromMachine(machine: machineToUpdate)
            let machine = managedMachine.toMachine()
            try self.privateManagedObjectContext.save()
            completionHandler(MachinesStoreResult.Success(result: machine))
          } catch {
            completionHandler(MachinesStoreResult.Failure(error: MachinesStoreError.CannotUpdate("Cannot update machine with id \(String(describing: machineToUpdate.id))")))
          }
        }
      } catch {
        completionHandler(MachinesStoreResult.Failure(error: MachinesStoreError.CannotUpdate("Cannot fetch machine with id \(String(describing: machineToUpdate.id)) to update")))
      }
    }
  }
  
  func deleteMachine(id: String, completionHandler: @escaping MachinesStoreDeleteMachineCompletionHandler)
  {
    privateManagedObjectContext.performAndWait {
      do {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Machine")
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        let results = try self.privateManagedObjectContext.fetch(fetchRequest) as! [Machine]
        if let managedMachine = results.first {
          let machine = managedMachine.toMachine()
          self.privateManagedObjectContext.delete(managedMachine)
          do {
            try self.privateManagedObjectContext.save()
            try self.mainManagedObjectContext.save()
            completionHandler(MachinesStoreResult.Success(result: machine))
          } catch {
            completionHandler(MachinesStoreResult.Failure(error: MachinesStoreError.CannotDelete("Cannot delete machine with id \(id)")))
          }
        } else {
          completionHandler(MachinesStoreResult.Failure(error: MachinesStoreError.CannotDelete("Cannot fetch machine with id \(id) to delete")))
        }
      } catch {
        completionHandler(MachinesStoreResult.Failure(error: MachinesStoreError.CannotDelete("Cannot fetch machine with id \(id) to delete")))
      }
    }
  }
  
  // MARK: - CRUD operations - Inner closure
  
  func fetchMachines(completionHandler: @escaping (() throws -> [MachineModel]) -> Void)
  {
    privateManagedObjectContext.performAndWait {
      do {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Machine")
        let results = try self.privateManagedObjectContext.fetch(fetchRequest) as! [Machine]
        let machines = results.map { $0.toMachine() }
        completionHandler { return machines }
      } catch {
        completionHandler { throw MachinesStoreError.CannotFetch("Cannot fetch machines") }
      }
    }
  }
  
  func fetchMachine(id: String, completionHandler: @escaping (() throws -> MachineModel?) -> Void)
  {
    privateManagedObjectContext.performAndWait {
      do {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Machine")
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        let results = try self.privateManagedObjectContext.fetch(fetchRequest) as! [Machine]
        if let machine = results.first?.toMachine() {
          completionHandler { return machine }
        } else {
          throw MachinesStoreError.CannotFetch("Cannot fetch machine with id \(id)")
        }
      } catch {
        completionHandler { throw MachinesStoreError.CannotFetch("Cannot fetch machine with id \(id)") }
      }
    }
  }
    
    func fetchMachine(code: String, completionHandler: @escaping (() throws -> MachineModel?) -> Void)
    {
      privateManagedObjectContext.performAndWait {
        do {
          let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Machine")
          fetchRequest.predicate = NSPredicate(format: "codeNumber == %@", code)
          let results = try self.privateManagedObjectContext.fetch(fetchRequest) as! [Machine]
          if let machine = results.first?.toMachine() {
            completionHandler { return machine }
          } else {
            throw MachinesStoreError.CannotFetch("Cannot fetch machine with code \(code)")
          }
        } catch {
          completionHandler { throw MachinesStoreError.CannotFetch("Cannot fetch machine with code \(code)") }
        }
      }
    }
  
  func createMachine(machineToCreate: MachineModel, completionHandler: @escaping (() throws -> MachineModel?) -> Void)
  {
    privateManagedObjectContext.performAndWait {
      do {
        let managedMachine = NSEntityDescription.insertNewObject(forEntityName: "Machine", into: self.privateManagedObjectContext) as! Machine
        var machine = machineToCreate
        self.generateMachineID(machine: &machine)
        managedMachine.fromMachine(machine: machine)
        try self.privateManagedObjectContext.save()
        try self.mainManagedObjectContext.save()
        completionHandler { return machine }
      } catch {
        completionHandler { throw MachinesStoreError.CannotCreate("Cannot create machine with id \(String(describing: machineToCreate.id))") }
      }
    }
  }
  
  func updateMachine(machineToUpdate: MachineModel, completionHandler: @escaping (() throws -> MachineModel?) -> Void)
  {
    privateManagedObjectContext.performAndWait {
      do {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Machine")
        fetchRequest.predicate = NSPredicate(format: "id == %@", machineToUpdate.id!)
        let results = try self.privateManagedObjectContext.fetch(fetchRequest) as! [Machine]
        if let managedMachine = results.first {
          do {
            managedMachine.fromMachine(machine: machineToUpdate)
            let machine = managedMachine.toMachine()
            try self.privateManagedObjectContext.save()
            completionHandler { return machine }
          } catch {
            completionHandler { throw MachinesStoreError.CannotUpdate("Cannot update machine with id \(String(describing: machineToUpdate.id))") }
          }
        }
      } catch {
        completionHandler { throw MachinesStoreError.CannotUpdate("Cannot fetch machine with id \(String(describing: machineToUpdate.id)) to update") }
      }
    }
  }
  
  func deleteMachine(id: String, completionHandler: @escaping (() throws -> MachineModel?) -> Void)
  {
    privateManagedObjectContext.performAndWait {
      do {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Machine")
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        let results = try self.privateManagedObjectContext.fetch(fetchRequest) as! [Machine]
        if let managedMachine = results.first {
          let machine = managedMachine.toMachine()
          self.privateManagedObjectContext.delete(managedMachine)
          do {
            try self.privateManagedObjectContext.save()
            try self.mainManagedObjectContext.save()
            completionHandler { return machine }
          } catch {
            completionHandler { throw MachinesStoreError.CannotDelete("Cannot delete machine with id \(id)") }
          }
        } else {
          throw MachinesStoreError.CannotDelete("Cannot fetch machine with id \(id) to delete")
        }
      } catch {
        completionHandler { throw MachinesStoreError.CannotDelete("Cannot fetch machine with id \(id) to delete") }
      }
    }
  }
}
