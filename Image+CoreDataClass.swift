//
//  Image+CoreDataClass.swift
//  ImageMachine
//
//  Created by Elang Putra Sartika on 03/08/21.
//
//

import Foundation
import CoreData

@objc(Image)
public class Image: NSManagedObject {
    func toImage() -> ImageModel
    {
      
        return ImageModel(id: id,img: img, machine: machine)
    }
    
    func fromImage(image: ImageModel)
    {
        id = image.id
        img = image.img
        machine = image.machine
    }
}
