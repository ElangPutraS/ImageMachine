//
//  ImagesMemStore.swift
//  ImageMachine
//
//  Created by Elang Putra Sartika on 04/08/21.
//

import Foundation

class ImagesMemStore: ImagesStoreProtocol, ImagesStoreUtilityProtocol
{
  // MARK: - Data
  
  static var images = [
    ImageModel(id: "185F8C6C-F4E4-11EB-9A03-0242AC130003", img: Data(base64Encoded: "test-1"), machine: nil),
    ImageModel(id: "185F8FC8-F4E4-11EB-9A03-0242AC130003", img: Data(base64Encoded: "test-2"), machine: nil)
  ]
  
  // MARK: - CRUD operations - Optional error
  
  func fetchImages(completionHandler: @escaping ([ImageModel], ImagesStoreError?) -> Void)
  {
    completionHandler(type(of: self).images, nil)
  }
  
  func fetchImage(id: String, completionHandler: @escaping (ImageModel?, ImagesStoreError?) -> Void)
  {
    if let index = indexOfImageWithID(id: id) {
      let image = type(of: self).images[index]
      completionHandler(image, nil)
    } else {
      completionHandler(nil, ImagesStoreError.CannotFetch("Cannot fetch image with id \(id)"))
    }
  }
  
  func createImage(imageToCreate: ImageModel, completionHandler: @escaping (ImageModel?, ImagesStoreError?) -> Void)
  {
    var image = imageToCreate
    generateImageID(image: &image)
    type(of: self).images.append(image)
    completionHandler(image, nil)
  }
  
  func updateImage(imageToUpdate: ImageModel, completionHandler: @escaping (ImageModel?, ImagesStoreError?) -> Void)
  {
    if let index = indexOfImageWithID(id: imageToUpdate.id) {
      type(of: self).images[index] = imageToUpdate
      let image = type(of: self).images[index]
      completionHandler(image, nil)
    } else {
      completionHandler(nil, ImagesStoreError.CannotUpdate("Cannot fetch image with id \(String(describing: imageToUpdate.id)) to update"))
    }
  }
  
  func deleteImage(id: String, completionHandler: @escaping (ImageModel?, ImagesStoreError?) -> Void)
  {
    if let index = indexOfImageWithID(id: id) {
      let image = type(of: self).images.remove(at: index)
      completionHandler(image, nil)
      return
    }
    completionHandler(nil, ImagesStoreError.CannotDelete("Cannot fetch image with id \(id) to delete"))
  }
  
  // MARK: - CRUD operations - Generic enum result type
  
  func fetchImages(completionHandler: @escaping ImagesStoreFetchImagesCompletionHandler)
  {
    completionHandler(ImagesStoreResult.Success(result: type(of: self).images))
  }
  
  func fetchImage(id: String, completionHandler: @escaping ImagesStoreFetchImageCompletionHandler)
  {
    let image = type(of: self).images.filter { (image: ImageModel) -> Bool in
      return image.id == id
      }.first
    if let image = image {
      completionHandler(ImagesStoreResult.Success(result: image))
    } else {
      completionHandler(ImagesStoreResult.Failure(error: ImagesStoreError.CannotFetch("Cannot fetch image with id \(id)")))
    }
  }
  
  func createImage(imageToCreate: ImageModel, completionHandler: @escaping ImagesStoreCreateImageCompletionHandler)
  {
    var image = imageToCreate
    generateImageID(image: &image)
    type(of: self).images.append(image)
    completionHandler(ImagesStoreResult.Success(result: image))
  }
  
  func updateImage(imageToUpdate: ImageModel, completionHandler: @escaping ImagesStoreUpdateImageCompletionHandler)
  {
    if let index = indexOfImageWithID(id: imageToUpdate.id) {
      type(of: self).images[index] = imageToUpdate
      let image = type(of: self).images[index]
      completionHandler(ImagesStoreResult.Success(result: image))
    } else {
      completionHandler(ImagesStoreResult.Failure(error: ImagesStoreError.CannotUpdate("Cannot update image with id \(String(describing: imageToUpdate.id)) to update")))
    }
  }
  
  func deleteImage(id: String, completionHandler: @escaping ImagesStoreDeleteImageCompletionHandler)
  {
    if let index = indexOfImageWithID(id: id) {
      let image = type(of: self).images.remove(at: index)
      completionHandler(ImagesStoreResult.Success(result: image))
      return
    }
    completionHandler(ImagesStoreResult.Failure(error: ImagesStoreError.CannotDelete("Cannot delete image with id \(id) to delete")))
  }
  
  // MARK: - CRUD operations - Inner closure
  
  func fetchImages(completionHandler: @escaping (() throws -> [ImageModel]) -> Void)
  {
    completionHandler { return type(of: self).images }
  }
  
  func fetchImage(id: String, completionHandler: @escaping (() throws -> ImageModel?) -> Void)
  {
    if let index = indexOfImageWithID(id: id) {
      completionHandler { return type(of: self).images[index] }
    } else {
      completionHandler { throw ImagesStoreError.CannotFetch("Cannot fetch image with id \(id)") }
    }
  }
  
  func createImage(imageToCreate: ImageModel, completionHandler: @escaping (() throws -> ImageModel?) -> Void)
  {
    var image = imageToCreate
    generateImageID(image: &image)
    type(of: self).images.append(image)
    completionHandler { return image }
  }
  
  func updateImage(imageToUpdate: ImageModel, completionHandler: @escaping (() throws -> ImageModel?) -> Void)
  {
    if let index = indexOfImageWithID(id: imageToUpdate.id) {
      type(of: self).images[index] = imageToUpdate
      let image = type(of: self).images[index]
      completionHandler { return image }
    } else {
      completionHandler { throw ImagesStoreError.CannotUpdate("Cannot fetch image with id \(String(describing: imageToUpdate.id)) to update") }
    }
  }
  
  func deleteImage(id: String, completionHandler: @escaping (() throws -> ImageModel?) -> Void)
  {
    if let index = indexOfImageWithID(id: id) {
      let image = type(of: self).images.remove(at: index)
      completionHandler { return image }
    } else {
      completionHandler { throw ImagesStoreError.CannotDelete("Cannot fetch image with id \(id) to delete") }
    }
  }

  // MARK: - Convenience methods
  
  private func indexOfImageWithID(id: String?) -> Int?
  {
    return type(of: self).images.firstIndex { return $0.id == id }
  }
}
