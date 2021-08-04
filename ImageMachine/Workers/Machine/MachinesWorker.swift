//
//  MachinesWorker.swift
//  ImageMachine
//
//  Created by Elang Putra Sartika on 04/08/21.
//

import Foundation

class MachinesWorker
{
  var machinesStore: MachinesStoreProtocol
  
  init(machinesStore: MachinesStoreProtocol)
  {
    self.machinesStore = machinesStore
  }
    
    func deleteMachine(id: String, completionHandler: @escaping (MachineModel?, MachinesStoreError?) -> Void)
    {
        machinesStore.deleteMachine(id: id) { (machine: MachineModel?, error: MachinesStoreError?) -> Void in
            do {
                guard let machine = machine else {
                    completionHandler(nil, error)
                    return
                }
              DispatchQueue.main.async {
                completionHandler(machine, nil)
              }
            }
        }
    }
    
    func fetchMachine(code: String, completionHandler: @escaping (MachineModel?, MachinesStoreError?) -> Void)
    {
      machinesStore.fetchMachine(code: code) { (machine: MachineModel?, error: MachinesStoreError?) -> Void in
        do {
            guard let machine = machine else {
                completionHandler(nil, error)
                return
            }
          DispatchQueue.main.async {
            completionHandler(machine, nil)
          }
        }
      }
    }
  
  func fetchMachines(completionHandler: @escaping ([MachineModel]) -> Void)
  {
    machinesStore.fetchMachines { (machines: () throws -> [MachineModel]) -> Void in
      do {
        let machines = try machines()
        DispatchQueue.main.async {
          completionHandler(machines)
        }
      } catch {
        DispatchQueue.main.async {
          completionHandler([])
        }
      }
    }
  }
  
  func createMachine(machineToCreate: MachineModel, completionHandler: @escaping (MachineModel?, MachinesStoreError?) -> Void)
  {
    machinesStore.createMachine(machineToCreate: machineToCreate) { (machine: MachineModel?, error: MachinesStoreError?) -> Void in
        do {
            guard let machine = machine else {
                completionHandler(nil, error)
                return
            }
          DispatchQueue.main.async {
            completionHandler(machine, nil)
          }
        }
    }
  }
  
  func updateMachine(machineToUpdate: MachineModel, completionHandler: @escaping (MachineModel?, MachinesStoreError?) -> Void)
  {
    machinesStore.updateMachine(machineToUpdate: machineToUpdate) { (machine: MachineModel?, error: MachinesStoreError?) -> Void in
        do {
            guard let machine = machine else {
                completionHandler(nil, error)
                return
            }
          DispatchQueue.main.async {
            completionHandler(machine, nil)
          }
        }
    }
  }
}

// MARK: - Machines store API

protocol MachinesStoreProtocol
{
  // MARK: CRUD operations - Optional error
  
  func fetchMachines(completionHandler: @escaping ([MachineModel], MachinesStoreError?) -> Void)
  func fetchMachine(id: String, completionHandler: @escaping (MachineModel?, MachinesStoreError?) -> Void)
  func fetchMachine(code: String, completionHandler: @escaping (MachineModel?, MachinesStoreError?) -> Void)
  func createMachine(machineToCreate: MachineModel, completionHandler: @escaping (MachineModel?, MachinesStoreError?) -> Void)
  func updateMachine(machineToUpdate: MachineModel, completionHandler: @escaping (MachineModel?, MachinesStoreError?) -> Void)
  func deleteMachine(id: String, completionHandler: @escaping (MachineModel?, MachinesStoreError?) -> Void)
  
  // MARK: CRUD operations - Generic enum result type
  
  func fetchMachines(completionHandler: @escaping MachinesStoreFetchMachinesCompletionHandler)
  func fetchMachine(id: String, completionHandler: @escaping MachinesStoreFetchMachineCompletionHandler)
  func fetchMachine(code: String, completionHandler: @escaping MachinesStoreFetchMachineCompletionHandler)
  func createMachine(machineToCreate: MachineModel, completionHandler: @escaping MachinesStoreCreateMachineCompletionHandler)
  func updateMachine(machineToUpdate: MachineModel, completionHandler: @escaping MachinesStoreUpdateMachineCompletionHandler)
  func deleteMachine(id: String, completionHandler: @escaping MachinesStoreDeleteMachineCompletionHandler)
  
  // MARK: CRUD operations - Inner closure
  
  func fetchMachines(completionHandler: @escaping (() throws -> [MachineModel]) -> Void)
  func fetchMachine(id: String, completionHandler: @escaping (() throws -> MachineModel?) -> Void)
  func fetchMachine(code: String, completionHandler: @escaping (() throws -> MachineModel?) -> Void)
  func createMachine(machineToCreate: MachineModel, completionHandler: @escaping (() throws -> MachineModel?) -> Void)
  func updateMachine(machineToUpdate: MachineModel, completionHandler: @escaping (() throws -> MachineModel?) -> Void)
  func deleteMachine(id: String, completionHandler: @escaping (() throws -> MachineModel?) -> Void)
}

protocol MachinesStoreUtilityProtocol {}

extension MachinesStoreUtilityProtocol
{
  func generateMachineID(machine: inout MachineModel)
  {
    guard machine.id == nil else { return }
    machine.id = UUID().uuidString
  }
}

// MARK: - Machines store CRUD operation results

typealias MachinesStoreFetchMachinesCompletionHandler = (MachinesStoreResult<[MachineModel]>) -> Void
typealias MachinesStoreFetchMachineCompletionHandler = (MachinesStoreResult<MachineModel>) -> Void
typealias MachinesStoreCreateMachineCompletionHandler = (MachinesStoreResult<MachineModel>) -> Void
typealias MachinesStoreUpdateMachineCompletionHandler = (MachinesStoreResult<MachineModel>) -> Void
typealias MachinesStoreDeleteMachineCompletionHandler = (MachinesStoreResult<MachineModel>) -> Void

enum MachinesStoreResult<U>
{
  case Success(result: U)
  case Failure(error: MachinesStoreError)
}

// MARK: - Machines store CRUD operation errors

enum MachinesStoreError: Equatable, Error
{
  case CannotFetch(String)
  case CannotCreate(String)
  case CannotUpdate(String)
  case CannotDelete(String)
}

func ==(lhs: MachinesStoreError, rhs: MachinesStoreError) -> Bool
{
  switch (lhs, rhs) {
  case (.CannotFetch(let a), .CannotFetch(let b)) where a == b: return true
  case (.CannotCreate(let a), .CannotCreate(let b)) where a == b: return true
  case (.CannotUpdate(let a), .CannotUpdate(let b)) where a == b: return true
  case (.CannotDelete(let a), .CannotDelete(let b)) where a == b: return true
  default: return false
  }
}
