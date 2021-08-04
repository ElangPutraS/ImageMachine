//
//  Machine+CoreDataClass.swift
//  ImageMachine
//
//  Created by Elang Putra Sartika on 03/08/21.
//
//

import Foundation
import CoreData

@objc(Machine)
public class Machine: NSManagedObject {
    func toMachine() -> MachineModel
    {
      
      return MachineModel(id: id, name: name, type: type, codeNumber: codeNumber, updatedAt: updatedAt, image: image)
    }
    
    func fromMachine(machine: MachineModel)
    {
        id = machine.id
        name = machine.name
        type = machine.type
        codeNumber = machine.codeNumber
        updatedAt = machine.updatedAt
    }
}
