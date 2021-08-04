//
//  Machine+CoreDataProperties.swift
//  ImageMachine
//
//  Created by Elang Putra Sartika on 03/08/21.
//
//

import Foundation
import CoreData


extension Machine {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Machine> {
        return NSFetchRequest<Machine>(entityName: "Machine")
    }

    @NSManaged public var id: String?
    @NSManaged public var name: String?
    @NSManaged public var type: String?
    @NSManaged public var codeNumber: String?
    @NSManaged public var updatedAt: Date?
    @NSManaged public var image: NSSet?

}

// MARK: Generated accessors for image
extension Machine {

    @objc(addImageObject:)
    @NSManaged public func addToImage(_ value: Image)

    @objc(removeImageObject:)
    @NSManaged public func removeFromImage(_ value: Image)

    @objc(addImage:)
    @NSManaged public func addToImage(_ values: NSSet)

    @objc(removeImage:)
    @NSManaged public func removeFromImage(_ values: NSSet)

}
