//
//  Machine.swift
//  ImageMachine
//
//  Created by Elang Putra Sartika on 04/08/21.
//

import Foundation

struct MachineModel: Equatable
{
    var id: String?
    var name: String?
    var type: String?
    var codeNumber: String?
    var updatedAt: Date?
    var image: NSSet?
}

func ==(lhs: MachineModel, rhs: MachineModel) -> Bool
{
  return lhs.id == rhs.id
    && lhs.name == rhs.name
    && lhs.type == rhs.type
    && lhs.codeNumber == rhs.codeNumber
    && lhs.updatedAt == rhs.updatedAt
    && lhs.image == rhs.image
}

