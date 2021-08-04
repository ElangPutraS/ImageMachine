//
//  Image+CoreDataProperties.swift
//  ImageMachine
//
//  Created by Elang Putra Sartika on 03/08/21.
//
//

import Foundation
import CoreData


extension Image {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Image> {
        return NSFetchRequest<Image>(entityName: "Image")
    }

    @NSManaged public var id: String?
    @NSManaged public var img: Data?
    @NSManaged public var machine: Machine?

}
