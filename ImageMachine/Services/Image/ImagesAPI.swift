//
//  ImagesAPI.swift
//  ImageMachine
//
//  Created by Elang Putra Sartika on 04/08/21.
//

import Foundation

class ImagesAPI: ImagesStoreProtocol, ImagesStoreUtilityProtocol
{
  // MARK: - CRUD operations - Optional error
  
  func fetchImages(completionHandler: @escaping ([ImageModel], ImagesStoreError?) -> Void)
  {
  }
  
  func fetchImage(id: String, completionHandler: @escaping (ImageModel?, ImagesStoreError?) -> Void)
  {
  }
  
  func createImage(imageToCreate: ImageModel, completionHandler: @escaping (ImageModel?, ImagesStoreError?) -> Void)
  {
  }
  
  func updateImage(imageToUpdate: ImageModel, completionHandler: @escaping (ImageModel?, ImagesStoreError?) -> Void)
  {
  }
  
  func deleteImage(id: String, completionHandler: @escaping (ImageModel?, ImagesStoreError?) -> Void)
  {
  }
  
  // MARK: - CRUD operations - Generic enum result type
  
  func fetchImages(completionHandler: @escaping ImagesStoreFetchImagesCompletionHandler)
  {
  }
  
  func fetchImage(id: String, completionHandler: @escaping ImagesStoreFetchImageCompletionHandler)
  {
  }
  
  func createImage(imageToCreate: ImageModel, completionHandler: @escaping ImagesStoreCreateImageCompletionHandler)
  {
  }
  
  func updateImage(imageToUpdate: ImageModel, completionHandler: @escaping ImagesStoreUpdateImageCompletionHandler)
  {
  }
  
  func deleteImage(id: String, completionHandler: @escaping ImagesStoreDeleteImageCompletionHandler)
  {
  }
  
  // MARK: - CRUD operations - Inner closure
  
  func fetchImages(completionHandler: @escaping (() throws -> [ImageModel]) -> Void)
  {
  }
  
  func fetchImage(id: String, completionHandler: @escaping (() throws -> ImageModel?) -> Void)
  {
  }
  
  func createImage(imageToCreate: ImageModel, completionHandler: @escaping (() throws -> ImageModel?) -> Void)
  {
  }
  
  func updateImage(imageToUpdate: ImageModel, completionHandler: @escaping (() throws -> ImageModel?) -> Void)
  {
  }
  
  func deleteImage(id: String, completionHandler: @escaping (() throws -> ImageModel?) -> Void)
  {
  }
}
