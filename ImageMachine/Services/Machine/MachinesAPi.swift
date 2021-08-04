//
//  MachinesAPi.swift
//  ImageMachine
//
//  Created by Elang Putra Sartika on 04/08/21.
//

import Foundation

class MachinesAPI: MachinesStoreProtocol, MachinesStoreUtilityProtocol
{
  // MARK: - CRUD operations - Optional error
  
  func fetchMachines(completionHandler: @escaping ([MachineModel], MachinesStoreError?) -> Void)
  {
  }
  
  func fetchMachine(id: String, completionHandler: @escaping (MachineModel?, MachinesStoreError?) -> Void)
  {
  }
    
    func fetchMachine(code: String, completionHandler: @escaping (MachineModel?, MachinesStoreError?) -> Void)
    {
    }
  
  func createMachine(machineToCreate: MachineModel, completionHandler: @escaping (MachineModel?, MachinesStoreError?) -> Void)
  {
  }
  
  func updateMachine(machineToUpdate: MachineModel, completionHandler: @escaping (MachineModel?, MachinesStoreError?) -> Void)
  {
  }
  
  func deleteMachine(id: String, completionHandler: @escaping (MachineModel?, MachinesStoreError?) -> Void)
  {
  }
  
  // MARK: - CRUD operations - Generic enum result type
  
  func fetchMachines(completionHandler: @escaping MachinesStoreFetchMachinesCompletionHandler)
  {
  }
    
    func fetchMachine(id: String, completionHandler: @escaping MachinesStoreFetchMachineCompletionHandler)
    {
    }
    
    func fetchMachine(code: String, completionHandler: @escaping MachinesStoreFetchMachineCompletionHandler)
    {
    }
  
  func createMachine(machineToCreate: MachineModel, completionHandler: @escaping MachinesStoreCreateMachineCompletionHandler)
  {
  }
  
  func updateMachine(machineToUpdate: MachineModel, completionHandler: @escaping MachinesStoreUpdateMachineCompletionHandler)
  {
  }
  
  func deleteMachine(id: String, completionHandler: @escaping MachinesStoreDeleteMachineCompletionHandler)
  {
  }
  
  // MARK: - CRUD operations - Inner closure
  
  func fetchMachines(completionHandler: @escaping (() throws -> [MachineModel]) -> Void)
  {
  }
    
    func fetchMachine(id: String, completionHandler: @escaping (() throws -> MachineModel?) -> Void)
    {
    }
    
    func fetchMachine(code: String, completionHandler: @escaping (() throws -> MachineModel?) -> Void)
    {
    }
  
  func createMachine(machineToCreate: MachineModel, completionHandler: @escaping (() throws -> MachineModel?) -> Void)
  {
  }
  
  func updateMachine(machineToUpdate: MachineModel, completionHandler: @escaping (() throws -> MachineModel?) -> Void)
  {
  }
  
  func deleteMachine(id: String, completionHandler: @escaping (() throws -> MachineModel?) -> Void)
  {
  }
}
