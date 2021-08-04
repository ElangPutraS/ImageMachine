//
//  Image.swift
//  ImageMachine
//
//  Created by Elang Putra Sartika on 04/08/21.
//

import Foundation

struct ImageModel: Equatable
{
    var id: String?
    var img: Data?
    var machine: Machine?
}

func ==(lhs: ImageModel, rhs: ImageModel) -> Bool
{
  return lhs.id == rhs.id
    && lhs.img == rhs.img
    && lhs.machine == rhs.machine
}

