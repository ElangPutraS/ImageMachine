//
//  MachinesMemStore.swift
//  ImageMachine
//
//  Created by Elang Putra Sartika on 04/08/21.
//

import Foundation

class MachinesMemStore: MachinesStoreProtocol, MachinesStoreUtilityProtocol
{
  // MARK: - Data
  
  static var machines = [
    MachineModel(id: "B91363CA-F4E1-11EB-9A03-0242AC130003", name: "Machine 1", type: "Sea", codeNumber: "1092345", updatedAt: Date(), image: nil),
    MachineModel(id: "B9136654-F4E1-11EB-9A03-0242AC130003", name: "Machine 2", type: "Mountain", codeNumber: "1092346", updatedAt: Date(), image: nil)
  ]
  
  // MARK: - CRUD operations - Optional error
  
  func fetchMachines(completionHandler: @escaping ([MachineModel], MachinesStoreError?) -> Void)
  {
    completionHandler(type(of: self).machines, nil)
  }
  
  func fetchMachine(id: String, completionHandler: @escaping (MachineModel?, MachinesStoreError?) -> Void)
  {
    if let index = indexOfMachineWithID(id: id) {
      let machine = type(of: self).machines[index]
      completionHandler(machine, nil)
    } else {
      completionHandler(nil, MachinesStoreError.CannotFetch("Cannot fetch machine with id \(id)"))
    }
  }
    
    func fetchMachine(code: String, completionHandler: @escaping (MachineModel?, MachinesStoreError?) -> Void)
    {
      if let index = indexOfMachineWithCode(code: code) {
        let machine = type(of: self).machines[index]
        completionHandler(machine, nil)
      } else {
        completionHandler(nil, MachinesStoreError.CannotFetch("Cannot fetch machine with code \(code)"))
      }
    }
  
  func createMachine(machineToCreate: MachineModel, completionHandler: @escaping (MachineModel?, MachinesStoreError?) -> Void)
  {
    var machine = machineToCreate
    generateMachineID(machine: &machine)
    type(of: self).machines.append(machine)
    completionHandler(machine, nil)
  }
  
  func updateMachine(machineToUpdate: MachineModel, completionHandler: @escaping (MachineModel?, MachinesStoreError?) -> Void)
  {
    if let index = indexOfMachineWithID(id: machineToUpdate.id) {
      type(of: self).machines[index] = machineToUpdate
      let machine = type(of: self).machines[index]
      completionHandler(machine, nil)
    } else {
      completionHandler(nil, MachinesStoreError.CannotUpdate("Cannot fetch machine with id \(String(describing: machineToUpdate.id)) to update"))
    }
  }
  
  func deleteMachine(id: String, completionHandler: @escaping (MachineModel?, MachinesStoreError?) -> Void)
  {
    if let index = indexOfMachineWithID(id: id) {
      let machine = type(of: self).machines.remove(at: index)
      completionHandler(machine, nil)
      return
    }
    completionHandler(nil, MachinesStoreError.CannotDelete("Cannot fetch machine with id \(id) to delete"))
  }
  
  // MARK: - CRUD operations - Generic enum result type
  
  func fetchMachines(completionHandler: @escaping MachinesStoreFetchMachinesCompletionHandler)
  {
    completionHandler(MachinesStoreResult.Success(result: type(of: self).machines))
  }
    
    func fetchMachine(id: String, completionHandler: @escaping MachinesStoreFetchMachineCompletionHandler)
    {
      let machine = type(of: self).machines.filter { (machine: MachineModel) -> Bool in
        return machine.id == id
        }.first
      if let machine = machine {
        completionHandler(MachinesStoreResult.Success(result: machine))
      } else {
        completionHandler(MachinesStoreResult.Failure(error: MachinesStoreError.CannotFetch("Cannot fetch machine with id \(id)")))
      }
    }
    
    func fetchMachine(code: String, completionHandler: @escaping MachinesStoreFetchMachineCompletionHandler)
    {
      let machine = type(of: self).machines.filter { (machine: MachineModel) -> Bool in
        return machine.codeNumber == code
        }.first
      if let machine = machine {
        completionHandler(MachinesStoreResult.Success(result: machine))
      } else {
        completionHandler(MachinesStoreResult.Failure(error: MachinesStoreError.CannotFetch("Cannot fetch machine with code \(code)")))
      }
    }
  
  func createMachine(machineToCreate: MachineModel, completionHandler: @escaping MachinesStoreCreateMachineCompletionHandler)
  {
    var machine = machineToCreate
    generateMachineID(machine: &machine)
    type(of: self).machines.append(machine)
    completionHandler(MachinesStoreResult.Success(result: machine))
  }
  
  func updateMachine(machineToUpdate: MachineModel, completionHandler: @escaping MachinesStoreUpdateMachineCompletionHandler)
  {
    if let index = indexOfMachineWithID(id: machineToUpdate.id) {
      type(of: self).machines[index] = machineToUpdate
      let machine = type(of: self).machines[index]
      completionHandler(MachinesStoreResult.Success(result: machine))
    } else {
      completionHandler(MachinesStoreResult.Failure(error: MachinesStoreError.CannotUpdate("Cannot update machine with id \(String(describing: machineToUpdate.id)) to update")))
    }
  }
  
  func deleteMachine(id: String, completionHandler: @escaping MachinesStoreDeleteMachineCompletionHandler)
  {
    if let index = indexOfMachineWithID(id: id) {
      let machine = type(of: self).machines.remove(at: index)
      completionHandler(MachinesStoreResult.Success(result: machine))
      return
    }
    completionHandler(MachinesStoreResult.Failure(error: MachinesStoreError.CannotDelete("Cannot delete machine with id \(id) to delete")))
  }
  
  // MARK: - CRUD operations - Inner closure
  
  func fetchMachines(completionHandler: @escaping (() throws -> [MachineModel]) -> Void)
  {
    completionHandler { return type(of: self).machines }
  }
    
    func fetchMachine(id: String, completionHandler: @escaping (() throws -> MachineModel?) -> Void)
    {
      if let index = indexOfMachineWithID(id: id) {
        completionHandler { return type(of: self).machines[index] }
      } else {
        completionHandler { throw MachinesStoreError.CannotFetch("Cannot fetch machine with id \(id)") }
      }
    }
    
    func fetchMachine(code: String, completionHandler: @escaping (() throws -> MachineModel?) -> Void)
    {
      if let index = indexOfMachineWithCode(code: code) {
        completionHandler { return type(of: self).machines[index] }
      } else {
        completionHandler { throw MachinesStoreError.CannotFetch("Cannot fetch machine with code \(code)") }
      }
    }
  
  func createMachine(machineToCreate: MachineModel, completionHandler: @escaping (() throws -> MachineModel?) -> Void)
  {
    var machine = machineToCreate
    generateMachineID(machine: &machine)
    type(of: self).machines.append(machine)
    completionHandler { return machine }
  }
  
  func updateMachine(machineToUpdate: MachineModel, completionHandler: @escaping (() throws -> MachineModel?) -> Void)
  {
    if let index = indexOfMachineWithID(id: machineToUpdate.id) {
      type(of: self).machines[index] = machineToUpdate
      let machine = type(of: self).machines[index]
      completionHandler { return machine }
    } else {
      completionHandler { throw MachinesStoreError.CannotUpdate("Cannot fetch machine with id \(String(describing: machineToUpdate.id)) to update") }
    }
  }
  
  func deleteMachine(id: String, completionHandler: @escaping (() throws -> MachineModel?) -> Void)
  {
    if let index = indexOfMachineWithID(id: id) {
      let machine = type(of: self).machines.remove(at: index)
      completionHandler { return machine }
    } else {
      completionHandler { throw MachinesStoreError.CannotDelete("Cannot fetch machine with id \(id) to delete") }
    }
  }

  // MARK: - Convenience methods
  
  private func indexOfMachineWithID(id: String?) -> Int?
  {
    return type(of: self).machines.firstIndex { return $0.id == id }
  }
    
    private func indexOfMachineWithCode(code: String?) -> Int?
    {
      return type(of: self).machines.firstIndex { return $0.codeNumber == code }
    }
}
