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
}
