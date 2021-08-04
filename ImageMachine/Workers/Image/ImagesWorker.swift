//
//  ImagesWorker.swift
//  ImageMachine
//
//  Created by Elang Putra Sartika on 04/08/21.
//

import Foundation

class ImagesWorker
{
  var imagesStore: ImagesStoreProtocol
  
  init(imagesStore: ImagesStoreProtocol)
  {
    self.imagesStore = imagesStore
  }
  
  func fetchImages(completionHandler: @escaping ([ImageModel]) -> Void)
  {
    imagesStore.fetchImages { (images: () throws -> [ImageModel]) -> Void in
      do {
        let images = try images()
        DispatchQueue.main.async {
          completionHandler(images)
        }
      } catch {
        DispatchQueue.main.async {
          completionHandler([])
        }
      }
    }
  }
  
  func createImage(imageToCreate: ImageModel, completionHandler: @escaping (ImageModel?) -> Void)
  {
    imagesStore.createImage(imageToCreate: imageToCreate) { (image: () throws -> ImageModel?) -> Void in
      do {
        let image = try image()
        DispatchQueue.main.async {
          completionHandler(image)
        }
      } catch {
        DispatchQueue.main.async {
          completionHandler(nil)
        }
      }
    }
  }
  
  func updateImage(imageToUpdate: ImageModel, completionHandler: @escaping (ImageModel?) -> Void)
  {
    imagesStore.updateImage(imageToUpdate: imageToUpdate) { (image: () throws -> ImageModel?) in
      do {
        let image = try image()
        DispatchQueue.main.async {
          completionHandler(image)
        }
      } catch {
        DispatchQueue.main.async {
          completionHandler(nil)
        }
      }
    }
  }
}

// MARK: - Images store API

protocol ImagesStoreProtocol
{
  // MARK: CRUD operations - Optional error
  
  func fetchImages(completionHandler: @escaping ([ImageModel], ImagesStoreError?) -> Void)
  func fetchImage(id: String, completionHandler: @escaping (ImageModel?, ImagesStoreError?) -> Void)
  func createImage(imageToCreate: ImageModel, completionHandler: @escaping (ImageModel?, ImagesStoreError?) -> Void)
  func updateImage(imageToUpdate: ImageModel, completionHandler: @escaping (ImageModel?, ImagesStoreError?) -> Void)
  func deleteImage(id: String, completionHandler: @escaping (ImageModel?, ImagesStoreError?) -> Void)
  
  // MARK: CRUD operations - Generic enum result type
  
  func fetchImages(completionHandler: @escaping ImagesStoreFetchImagesCompletionHandler)
  func fetchImage(id: String, completionHandler: @escaping ImagesStoreFetchImageCompletionHandler)
  func createImage(imageToCreate: ImageModel, completionHandler: @escaping ImagesStoreCreateImageCompletionHandler)
  func updateImage(imageToUpdate: ImageModel, completionHandler: @escaping ImagesStoreUpdateImageCompletionHandler)
  func deleteImage(id: String, completionHandler: @escaping ImagesStoreDeleteImageCompletionHandler)
  
  // MARK: CRUD operations - Inner closure
  
  func fetchImages(completionHandler: @escaping (() throws -> [ImageModel]) -> Void)
  func fetchImage(id: String, completionHandler: @escaping (() throws -> ImageModel?) -> Void)
  func createImage(imageToCreate: ImageModel, completionHandler: @escaping (() throws -> ImageModel?) -> Void)
  func updateImage(imageToUpdate: ImageModel, completionHandler: @escaping (() throws -> ImageModel?) -> Void)
  func deleteImage(id: String, completionHandler: @escaping (() throws -> ImageModel?) -> Void)
}

protocol ImagesStoreUtilityProtocol {}

extension ImagesStoreUtilityProtocol
{
    func generateImageID(image: inout ImageModel)
    {
      guard image.id == nil else { return }
        image.id = UUID().uuidString
    }
}

// MARK: - Images store CRUD operation results

typealias ImagesStoreFetchImagesCompletionHandler = (ImagesStoreResult<[ImageModel]>) -> Void
typealias ImagesStoreFetchImageCompletionHandler = (ImagesStoreResult<ImageModel>) -> Void
typealias ImagesStoreCreateImageCompletionHandler = (ImagesStoreResult<ImageModel>) -> Void
typealias ImagesStoreUpdateImageCompletionHandler = (ImagesStoreResult<ImageModel>) -> Void
typealias ImagesStoreDeleteImageCompletionHandler = (ImagesStoreResult<ImageModel>) -> Void

enum ImagesStoreResult<U>
{
  case Success(result: U)
  case Failure(error: ImagesStoreError)
}

// MARK: - Images store CRUD operation errors

enum ImagesStoreError: Equatable, Error
{
  case CannotFetch(String)
  case CannotCreate(String)
  case CannotUpdate(String)
  case CannotDelete(String)
}

func ==(lhs: ImagesStoreError, rhs: ImagesStoreError) -> Bool
{
  switch (lhs, rhs) {
  case (.CannotFetch(let a), .CannotFetch(let b)) where a == b: return true
  case (.CannotCreate(let a), .CannotCreate(let b)) where a == b: return true
  case (.CannotUpdate(let a), .CannotUpdate(let b)) where a == b: return true
  case (.CannotDelete(let a), .CannotDelete(let b)) where a == b: return true
  default: return false
  }
}
