//
//  CoreDataManager.swift
//  CoreData Project
//
//  Created by Nuno Pereira on 23/01/2018.
//  Copyright © 2018 Nuno Pereira. All rights reserved.
//

import CoreData

struct CoreDataManager {
    
    //Singleton que vai permitir que o objecto context continue a existir e nao seja destruido
    static let shared = CoreDataManager()
    
    let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CoreDataModel")
        
        container.loadPersistentStores(completionHandler: { (storeDescription, err) in
            if let err = err {
                fatalError("Loading of store failed: \(err)")
            }
        })
        return container
    }()
    
    func fetchCompanies() -> [Company]{
        //attempt core data fetch
        
        let context = persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<Company>(entityName: "Company")
        
        do {
            let companies = try context.fetch(fetchRequest)
            
            return companies
        }
        catch let fetchErr {
            print("Failed to fetch companies: ", fetchErr)
            return []
        }
    }
    
    func createEmployee(employeeName: String) -> (Employee?, Error?) {
        let context = persistentContainer.viewContext
        
        let employee = NSEntityDescription.insertNewObject(forEntityName: "Employee", into: context) as! Employee
        employee.setValue(employeeName, forKey: "name")
        
        do {
            try context.save()
            return (employee, nil)
        }
        catch let err {
            print("Failed to create Employee: ", err)
            return (nil, err)
        }
    }
}
