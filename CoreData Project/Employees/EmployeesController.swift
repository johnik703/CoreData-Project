//
//  EmployeesController.swift
//  CoreData Project
//
//  Created by Nuno Pereira on 28/01/2018.
//  Copyright © 2018 Nuno Pereira. All rights reserved.
//

import UIKit
import CoreData

class IndentedLabel: UILabel {
    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        let customRect = UIEdgeInsetsInsetRect(rect, insets)
        super.drawText(in: customRect)
    }
}

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
    
    
    var allEmployees = [[Employee]]()
    
    let employeeTypes = [
        EmployeeType.Intern.rawValue,
        EmployeeType.Executive.rawValue,
        EmployeeType.SeniorManagement.rawValue,
        EmployeeType.Staff.rawValue
    ]
    
    func fetchEmployees() {

        guard let companyEmployees = company?.employees?.allObjects as? [Employee] else {return}

        allEmployees.removeAll()
//        let executives = companyEmployees.filter { (employee) -> Bool in
//            return employee.type == EmployeeType.Executive.rawValue
//        }
//
//        let seniorManagement = companyEmployees.filter {$0.type == EmployeeType.SeniorManagement.rawValue}
//
//        let staff = companyEmployees.filter {$0.type == EmployeeType.Staff.rawValue}
//
//        allEmployees = [executives, seniorManagement, staff]
        
        employeeTypes.forEach { (employeeType) in
            allEmployees.append(
                companyEmployees.filter { $0.type == employeeType }
            )
        }
    }
    
    func didAddEmployee(employee: Employee) {
//        self.employees.append(employee)
//        fetchEmployees()
//        self.tableView.reloadData()
        
        guard let section = employeeTypes.index(of: employee.type!) else {return}
        
        let row = allEmployees[section].count
        
        let insertionIndexPath = IndexPath(row: row, section: section)
        
        allEmployees[section].append(employee)
        
        tableView.insertRows(at: [insertionIndexPath], with: .middle)
    }
    
    @objc func handleAdd() {
        let createEmployeeController = CreateEmployeeController()
        createEmployeeController.delegate = self
        createEmployeeController.company = company
        let navController = UINavigationController(rootViewController: createEmployeeController)
        present(navController, animated: true, completion: nil)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return allEmployees.count
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = IndentedLabel()
//        if section == 0 {
//        label.text = EmployeeType.Executive.rawValue
//        }
//        else if section == 1{
//            label.text = EmployeeType.SeniorManagement.rawValue
//        }
//        else {
//            label.text = EmployeeType.Staff.rawValue
//        }
        
        label.text = employeeTypes[section]
        
        label.backgroundColor = .lightBlue
        label.textColor = .darkBlue
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if section == 0 {
//            return shortNameEmployees.count
//        }
//        return longNameEmployees.count
        return allEmployees[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        
        let employee = allEmployees[indexPath.section][indexPath.row]
        
//        if let taxId = employee.employeeInformation?.taxId {
//            cell.textLabel?.text = "\(employee.name ?? "" )   \(taxId)";
//        }
        if let birthday = employee.employeeInformation?.birthday {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM dd yyyy"
            
            cell.textLabel?.text = "\(employee.fullName ?? "" )   \(dateFormatter.string(from: birthday))";
        }
        else {
            cell.textLabel?.text = employee.fullName
        }
        cell.backgroundColor = .tealColor
        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        cell.textLabel?.textColor = .white
        return cell
    }
}
