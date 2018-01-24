//
//  ViewController.swift
//  CoreData Project
//
//  Created by Nuno Pereira on 21/01/2018.
//  Copyright © 2018 Nuno Pereira. All rights reserved.
//

import UIKit
import CoreData

class CompaniesController: UITableViewController, CreateCompanyControllerDelegate {
    func didAddCompany(company: Company) {
        
        companies.append(company)
        
        let indexPath = IndexPath(row: companies.count - 1, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
    }
    
    
    let cellId = "cellId"
    
//    var companies: [Company] = [
//        Company(name: "Apple", founded: Date()),
//        Company(name: "Google", founded: Date()),
//        Company(name: "Facebook", founded: Date())
//    ]

    var companies = [Company]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchCompanies()
        
        view.backgroundColor = .white
        
        navigationItem.title = "Companies"
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "plus").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleAddCompany))
        
        tableView.backgroundColor = .darkBlue
        //Esconde o separador de celulas em toda a tabela
        tableView.separatorStyle = .none
        
        //Ao definir uma view simples para a tableFooterView, esconde o separador de celulas a baixo da tabela onde nao ha dados
        tableView.tableFooterView = UIView()
        tableView.separatorColor = .white
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        
    }
    
    fileprivate func fetchCompanies() {
        //attempt core data fetch
        
        let context = CoreDataManager.shared.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<Company>(entityName: "Company")
        
        do {
            let companies = try context.fetch(fetchRequest)
            companies.forEach({print($0.name ?? "")})
            
            self.companies = companies
            self.tableView.reloadData()
        }
        catch let fetchErr {
            print("Failed to fetch companies: ", fetchErr)
        }
    }

    @objc func handleAddCompany() {
        print("Adding company...")
        
        let createCompanyController = CreateCompanyController()
        
        createCompanyController.delegate = self
        
        let navController = CustomNavigationController(rootViewController: createCompanyController)
        present(navController, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return companies.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        cell.backgroundColor = .tealColor
        
        let company = companies[indexPath.row]
        
        cell.textLabel?.text = company.name
        cell.textLabel?.textColor = .white
        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor.rgb(red: 218, green: 235, blue: 243)
        return view
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            let company = self.companies[indexPath.row]
            print("Attempting to remove company ", company.name ?? "")
            
            //delete from table
            self.companies.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            
            //delete from core data
            let context = CoreDataManager.shared.persistentContainer.viewContext
            
            context.delete(company)
            
            do {
                try context.save()
            }
            catch let saveErr {
                print("Failed to delete company: ", saveErr)
            }
        }
        
        let editAction = UITableViewRowAction(style: .normal, title: "Edit") { (action, indexPath) in
            let company = self.companies[indexPath.row]
            print("Attempting to edit company ", company.name ?? "")
        }
        
        return [deleteAction, editAction]
    }
}

