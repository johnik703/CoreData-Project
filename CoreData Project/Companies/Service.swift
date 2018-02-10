//
//  Service.swift
//  CoreData Project
//
//  Created by Nuno Pereira on 07/02/2018.
//  Copyright © 2018 Nuno Pereira. All rights reserved.
//

import UIKit
import CoreData

struct Service: Decodable {
    
    static let shared = Service()
    
    let urlString = "https://api.letsbuildthatapp.com/intermediate_training/companies"
    
    func downloadCompaniesFromServer() {
        print("Attempting to download companies...")
        
        guard let url = URL(string: urlString) else {return}
    
        URLSession.shared.dataTask(with: url) { (data, resp, err) in
            if let err = err {
                print("Error fetching data from web...", err)
                return
            }
            guard let data = data else {return}
            
            do {
                let jsonDecoder = try JSONDecoder().decode([JSONCompany].self, from: data)
            
                //Uma vez que a URLSession corre numa background thread, tem que se criar um background context para o CoreData
                let privateContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
                
                //Como a tableView do NSFetch opera no mainContext, e necessario definir o parent como o main Context
                privateContext.parent = CoreDataManager.shared.persistentContainer.viewContext
                
                jsonDecoder.forEach({ (jsonCompany) in
                    
                    let company = Company(context: privateContext)
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "MM/dd/yyyy"
                    let foundedDate = dateFormatter.date(from: jsonCompany.founded ?? "")
                    
                    company.name = jsonCompany.name
                    company.founded = foundedDate
                    
                    jsonCompany.employees?.forEach({ (jsonEmployee) in
                        
                        let employee = Employee(context: privateContext)
                        employee.fullName = jsonEmployee.name
                        employee.type = jsonEmployee.type
                        
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "MM/dd/yyyy"
                        let birthday = dateFormatter.date(from: jsonEmployee.birthday)
                        
                        let employeeInformation = EmployeeInformation(context: privateContext)
                        employeeInformation.birthday = birthday
                        
                        employee.employeeInformation = employeeInformation
                        employee.company = company
                    })
                    
                    do {
                        try privateContext.save()
                        try privateContext.parent?.save()
                    }
                    catch let saveErr {
                        print("Failed do save companies and employees: ", saveErr)
                    }
                })
                 
            }
            catch let jsonDecodeErr {
                print("Failed to decode...", jsonDecodeErr)
            }
            
        }.resume()
        
    }
}

struct JSONCompany: Decodable {
    let name: String?
    let founded: String?
    let employees: [JSONEmployee]?
}

struct JSONEmployee: Decodable {
    let name: String
    let birthday: String
    let type: String
}
