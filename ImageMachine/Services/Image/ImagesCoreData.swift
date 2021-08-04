//
//  ImagesCoreData.swift
//  ImageMachine
//
//  Created by Elang Putra Sartika on 04/08/21.
//

import CoreData

class ImagesCoreDataStore: ImagesStoreProtocol, ImagesStoreUtilityProtocol
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
  
  deinit
  {
    do {
      try self.mainManagedObjectContext.save()
    } catch {
      fatalError("Error deinitializing main managed object context")
    }
  }
  
  // MARK: - CRUD operations - Optional error
  
  func fetchImages(completionHandler: @escaping ([ImageModel], ImagesStoreError?) -> Void)
  {
    privateManagedObjectContext.perform {
      do {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Image")
        let results = try self.privateManagedObjectContext.fetch(fetchRequest) as! [Image]
        let images = results.map { $0.toImage() }
        completionHandler(images, nil)
      } catch {
        completionHandler([], ImagesStoreError.CannotFetch("Cannot fetch images"))
      }
    }
  }
  
  func fetchImage(id: String, completionHandler: @escaping (ImageModel?, ImagesStoreError?) -> Void)
  {
    privateManagedObjectContext.perform {
      do {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Image")
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        let results = try self.privateManagedObjectContext.fetch(fetchRequest) as! [Image]
        if let image = results.first?.toImage() {
          completionHandler(image, nil)
        } else {
          completionHandler(nil, ImagesStoreError.CannotFetch("Cannot fetch image with id \(id)"))
        }
      } catch {
        completionHandler(nil, ImagesStoreError.CannotFetch("Cannot fetch image with id \(id)"))
      }
    }
  }
  
  func createImage(imageToCreate: ImageModel, completionHandler: @escaping (ImageModel?, ImagesStoreError?) -> Void)
  {
    privateManagedObjectContext.perform {
      do {
        let managedImage = NSEntityDescription.insertNewObject(forEntityName: "Image", into: self.privateManagedObjectContext) as! Image
        var image = imageToCreate
        self.generateImageID(image: &image)
        managedImage.fromImage(image: image)
        try self.privateManagedObjectContext.save()
        completionHandler(image, nil)
      } catch {
        completionHandler(nil, ImagesStoreError.CannotCreate("Cannot create image with id \(String(describing: imageToCreate.id))"))
      }
    }
  }
  
  func updateImage(imageToUpdate: ImageModel, completionHandler: @escaping (ImageModel?, ImagesStoreError?) -> Void)
  {
    privateManagedObjectContext.perform {
      do {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Image")
        fetchRequest.predicate = NSPredicate(format: "id == %@", imageToUpdate.id!)
        let results = try self.privateManagedObjectContext.fetch(fetchRequest) as! [Image]
        if let managedImage = results.first {
          do {
            managedImage.fromImage(image: imageToUpdate)
            let image = managedImage.toImage()
            try self.privateManagedObjectContext.save()
            completionHandler(image, nil)
          } catch {
            completionHandler(nil, ImagesStoreError.CannotUpdate("Cannot update image with id \(String(describing: imageToUpdate.id))"))
          }
        }
      } catch {
        completionHandler(nil, ImagesStoreError.CannotUpdate("Cannot fetch image with id \(String(describing: imageToUpdate.id)) to update"))
      }
    }
  }
  
  func deleteImage(id: String, completionHandler: @escaping (ImageModel?, ImagesStoreError?) -> Void)
  {
    privateManagedObjectContext.perform {
      do {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Image")
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        let results = try self.privateManagedObjectContext.fetch(fetchRequest) as! [Image]
        if let managedImage = results.first {
          let image = managedImage.toImage()
          self.privateManagedObjectContext.delete(managedImage)
          do {
            try self.privateManagedObjectContext.save()
            completionHandler(image, nil)
          } catch {
            completionHandler(nil, ImagesStoreError.CannotDelete("Cannot delete image with id \(id)"))
          }
        } else {
          throw ImagesStoreError.CannotDelete("Cannot fetch image with id \(id) to delete")
        }
      } catch {
        completionHandler(nil, ImagesStoreError.CannotDelete("Cannot fetch image with id \(id) to delete"))
      }
    }
  }
  
  // MARK: - CRUD operations - Generic enum result type
  
  func fetchImages(completionHandler: @escaping ImagesStoreFetchImagesCompletionHandler)
  {
    privateManagedObjectContext.perform {
      do {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Image")
        let results = try self.privateManagedObjectContext.fetch(fetchRequest) as! [Image]
        let images = results.map { $0.toImage() }
        completionHandler(ImagesStoreResult.Success(result: images))
      } catch {
        completionHandler(ImagesStoreResult.Failure(error: ImagesStoreError.CannotFetch("Cannot fetch images")))
      }
    }
  }
  
  func fetchImage(id: String, completionHandler: @escaping ImagesStoreFetchImageCompletionHandler)
  {
    privateManagedObjectContext.perform {
      do {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Image")
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        let results = try self.privateManagedObjectContext.fetch(fetchRequest) as! [Image]
        if let image = results.first?.toImage() {
          completionHandler(ImagesStoreResult.Success(result: image))
        } else {
          completionHandler(ImagesStoreResult.Failure(error: ImagesStoreError.CannotFetch("Cannot fetch image with id \(id)")))
        }
      } catch {
        completionHandler(ImagesStoreResult.Failure(error: ImagesStoreError.CannotFetch("Cannot fetch image with id \(id)")))
      }
    }
  }
  
  func createImage(imageToCreate: ImageModel, completionHandler: @escaping ImagesStoreCreateImageCompletionHandler)
  {
    privateManagedObjectContext.perform {
      do {
        let managedImage = NSEntityDescription.insertNewObject(forEntityName: "Image", into: self.privateManagedObjectContext) as! Image
        var image = imageToCreate
        self.generateImageID(image: &image)
        managedImage.fromImage(image: image)
        try self.privateManagedObjectContext.save()
        completionHandler(ImagesStoreResult.Success(result: image))
      } catch {
        let error = ImagesStoreError.CannotCreate("Cannot create image with id \(String(describing: imageToCreate.id))")
        completionHandler(ImagesStoreResult.Failure(error: error))
      }
    }
  }
  
  func updateImage(imageToUpdate: ImageModel, completionHandler: @escaping ImagesStoreUpdateImageCompletionHandler)
  {
    privateManagedObjectContext.perform {
      do {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Image")
        fetchRequest.predicate = NSPredicate(format: "id == %@", imageToUpdate.id!)
        let results = try self.privateManagedObjectContext.fetch(fetchRequest) as! [Image]
        if let managedImage = results.first {
          do {
            managedImage.fromImage(image: imageToUpdate)
            let image = managedImage.toImage()
            try self.privateManagedObjectContext.save()
            completionHandler(ImagesStoreResult.Success(result: image))
          } catch {
            completionHandler(ImagesStoreResult.Failure(error: ImagesStoreError.CannotUpdate("Cannot update image with id \(String(describing: imageToUpdate.id))")))
          }
        }
      } catch {
        completionHandler(ImagesStoreResult.Failure(error: ImagesStoreError.CannotUpdate("Cannot fetch image with id \(String(describing: imageToUpdate.id)) to update")))
      }
    }
  }
  
  func deleteImage(id: String, completionHandler: @escaping ImagesStoreDeleteImageCompletionHandler)
  {
    privateManagedObjectContext.perform {
      do {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Image")
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        let results = try self.privateManagedObjectContext.fetch(fetchRequest) as! [Image]
        if let managedImage = results.first {
          let image = managedImage.toImage()
          self.privateManagedObjectContext.delete(managedImage)
          do {
            try self.privateManagedObjectContext.save()
            completionHandler(ImagesStoreResult.Success(result: image))
          } catch {
            completionHandler(ImagesStoreResult.Failure(error: ImagesStoreError.CannotDelete("Cannot delete image with id \(id)")))
          }
        } else {
          completionHandler(ImagesStoreResult.Failure(error: ImagesStoreError.CannotDelete("Cannot fetch image with id \(id) to delete")))
        }
      } catch {
        completionHandler(ImagesStoreResult.Failure(error: ImagesStoreError.CannotDelete("Cannot fetch image with id \(id) to delete")))
      }
    }
  }
  
  // MARK: - CRUD operations - Inner closure
  
  func fetchImages(completionHandler: @escaping (() throws -> [ImageModel]) -> Void)
  {
    privateManagedObjectContext.perform {
      do {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Image")
        let results = try self.privateManagedObjectContext.fetch(fetchRequest) as! [Image]
        let images = results.map { $0.toImage() }
        completionHandler { return images }
      } catch {
        completionHandler { throw ImagesStoreError.CannotFetch("Cannot fetch images") }
      }
    }
  }
  
  func fetchImage(id: String, completionHandler: @escaping (() throws -> ImageModel?) -> Void)
  {
    privateManagedObjectContext.perform {
      do {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Image")
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        let results = try self.privateManagedObjectContext.fetch(fetchRequest) as! [Image]
        if let image = results.first?.toImage() {
          completionHandler { return image }
        } else {
          throw ImagesStoreError.CannotFetch("Cannot fetch image with id \(id)")
        }
      } catch {
        completionHandler { throw ImagesStoreError.CannotFetch("Cannot fetch image with id \(id)") }
      }
    }
  }
  
  func createImage(imageToCreate: ImageModel, completionHandler: @escaping (() throws -> ImageModel?) -> Void)
  {
    privateManagedObjectContext.perform {
      do {
        let managedImage = NSEntityDescription.insertNewObject(forEntityName: "Image", into: self.privateManagedObjectContext) as! Image
        var image = imageToCreate
        self.generateImageID(image: &image)
        managedImage.fromImage(image: image)
        try self.privateManagedObjectContext.save()
        completionHandler { return image }
      } catch {
        completionHandler { throw ImagesStoreError.CannotCreate("Cannot create image with id \(String(describing: imageToCreate.id))") }
      }
    }
  }
  
  func updateImage(imageToUpdate: ImageModel, completionHandler: @escaping (() throws -> ImageModel?) -> Void)
  {
    privateManagedObjectContext.perform {
      do {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Image")
        fetchRequest.predicate = NSPredicate(format: "id == %@", imageToUpdate.id!)
        let results = try self.privateManagedObjectContext.fetch(fetchRequest) as! [Image]
        if let managedImage = results.first {
          do {
            managedImage.fromImage(image: imageToUpdate)
            let image = managedImage.toImage()
            try self.privateManagedObjectContext.save()
            completionHandler { return image }
          } catch {
            completionHandler { throw ImagesStoreError.CannotUpdate("Cannot update image with id \(String(describing: imageToUpdate.id))") }
          }
        }
      } catch {
        completionHandler { throw ImagesStoreError.CannotUpdate("Cannot fetch image with id \(String(describing: imageToUpdate.id)) to update") }
      }
    }
  }
  
  func deleteImage(id: String, completionHandler: @escaping (() throws -> ImageModel?) -> Void)
  {
    privateManagedObjectContext.perform {
      do {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Image")
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        let results = try self.privateManagedObjectContext.fetch(fetchRequest) as! [Image]
        if let managedImage = results.first {
          let image = managedImage.toImage()
          self.privateManagedObjectContext.delete(managedImage)
          do {
            try self.privateManagedObjectContext.save()
            completionHandler { return image }
          } catch {
            completionHandler { throw ImagesStoreError.CannotDelete("Cannot delete image with id \(id)") }
          }
        } else {
          throw ImagesStoreError.CannotDelete("Cannot fetch image with id \(id) to delete")
        }
      } catch {
        completionHandler { throw ImagesStoreError.CannotDelete("Cannot fetch image with id \(id) to delete") }
      }
    }
  }
}
