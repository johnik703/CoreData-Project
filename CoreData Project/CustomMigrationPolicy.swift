//
//  CustomMigrationPolicy.swift
//  CoreData Project
//
//  Created by Nuno Pereira on 10/02/2018.
//  Copyright © 2018 Nuno Pereira. All rights reserved.
//

import CoreData

class CustomMigrationPolicy: NSEntityMigrationPolicy {
    
    @objc func transformNumEmployees(forNum: NSNumber) -> String {
        if forNum.intValue < 150 {
            return "small"
        }
        else {
            return "very large"
        }
    }
}
