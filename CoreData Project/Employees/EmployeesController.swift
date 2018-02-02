//
//  EmployeesController.swift
//  CoreData Project
//
//  Created by Nuno Pereira on 28/01/2018.
//  Copyright © 2018 Nuno Pereira. All rights reserved.
//

import UIKit
import CoreData

class EmployeesController: UITableViewController, CreateEmployeeControllerDelegate {
    
    var company: Company?
    var employees = [Employee]()
    
    let cellId = "cellId"
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = company?.name
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .darkBlue
        
        setupPlusButtonInNavBar(selector: #selector(handleAdd))
        
        fetchEmployees()

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
    }
    
    func fetchEmployees() {

        guard let companyEmployees = company?.employees?.allObjects as? [Employee] else {return}
        self.employees = companyEmployees
//        let context = CoreDataManager.shared.persistentContainer.viewContext
//
//        let request = NSFetchRequest<Employee>(entityName: "Employee")
//
//        do {
//            self.employees = try context.fetch(request)
//        }
//        catch let err {
//            print("Error fetching Employees from core data", err)
//        }
    }
    
    func didAddEmployee(employee: Employee) {
        self.employees.append(employee)
        self.tableView.reloadData()
    }
    
    @objc func handleAdd() {
        let createEmployeeController = CreateEmployeeController()
        createEmployeeController.delegate = self
        createEmployeeController.company = company
        let navController = UINavigationController(rootViewController: createEmployeeController)
        present(navController, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return employees.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        let employee = employees[indexPath.row]
        
        if let taxId = employee.employeeInformation?.taxId {
            cell.textLabel?.text = "\(employee.name ?? "" )   \(taxId)";
        }
        else {
            cell.textLabel?.text = employee.name
        }
        cell.backgroundColor = .tealColor
        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        cell.textLabel?.textColor = .white
        return cell
    }
}
