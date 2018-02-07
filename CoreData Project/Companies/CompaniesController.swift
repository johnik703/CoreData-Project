//
//  ViewController.swift
//  CoreData Project
//
//  Created by Nuno Pereira on 21/01/2018.
//  Copyright © 2018 Nuno Pereira. All rights reserved.
//

import UIKit
import CoreData

class CompaniesController: UITableViewController {

    let cellId = "cellId"

    var companies = [Company]()
    
    @objc func doWork() {
        print("Trying to do work...")

        CoreDataManager.shared.persistentContainer.performBackgroundTask { (backgroundContext) in
            (0...10).forEach { (value) in
                print(value)
                let company = Company(context: backgroundContext)
                company.name = String(value)
            }
            do {
                try backgroundContext.save()
                
                DispatchQueue.main.async {
                    self.companies = CoreDataManager.shared.fetchCompanies()
                    self.tableView.reloadData()
                }
            }
            catch let err {
                print("Failed to save: ", err)
            }
        }
    }
    
    @objc func doUpdates() {
        print("Trying to update companies on background context...")
        
        CoreDataManager.shared.persistentContainer.performBackgroundTask { (backgroundContext) in
            
            //Tem que se especificar o tipo NSFetchRequest e o objecto senao da erro que se trata de um fetchRequest muito generico
            let request: NSFetchRequest<Company> = Company.fetchRequest()
            
            do {
                //Nao se pode utilizar as self.companies pois estas foram adquiridas noutro contexto neste caso na main thread e por isso tem que ser feito outro fetch request
                let companies = try backgroundContext.fetch(request)
                
                companies.forEach({ (company) in
                    print(company.name ?? "")
                    company.name = "C: \(company.name ?? "")"
                    
                    do {
                        try backgroundContext.save()
                        
                        DispatchQueue.main.async {
                            
                            //reset will forget all of the objects you've fetch before
                            CoreDataManager.shared.persistentContainer.viewContext.reset()
                            self.companies = CoreDataManager.shared.fetchCompanies()
                            self.tableView.reloadData()
                        }
                    }
                    catch let err {
                        print("Failed to save companies on background: ", err)
                    }
                })
            }
            catch let err {
                print("Failed to fetch companies on background: ", err)
            }
        }
    }
    
    @objc func doNestedUpdates() {
        print("trying to perform nested updades")
        
        DispatchQueue.global(qos: .background).async {
            //Going to try to perform our updates
            
            //first construct a custom MOC
            //Utiliza-se o private queue por estar a ser utilizado um backgroundContext
            let privateContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
            
            //Definir o parent
            privateContext.parent = CoreDataManager.shared.persistentContainer.viewContext
            
            //Executar os updates no privateContext
            let request: NSFetchRequest<Company> = Company.fetchRequest()
            //Reduzir o limite de objectos retornado pelo request
            request.fetchLimit = 1
            
            do {
                let companies = try privateContext.fetch(request)
                
                companies.forEach({ (company) in
                    print(company.name ?? "")
                    company.name = "D: \(company.name ?? "")"
                })
                
                do {
                    try privateContext.save()
                    
                    DispatchQueue.main.async {
                        
                        do {
                            let context = CoreDataManager.shared.persistentContainer.viewContext
                            //Validacao necessaria para evitar que o CoreData tenha trabalho desnecessario
                            if context.hasChanges {
                                try context.save()
                            }
                        }
                        catch let finalSaveErr {
                            print("Failed to save main context: ", finalSaveErr)
                        }
                        self.tableView.reloadData()
                    }
                }
                catch let saveErr {
                    print("Failed to save on private context: ", saveErr)
                }
            }
            catch let err {
                print("Failed to fetch on private context: ", err)
            }
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.companies = CoreDataManager.shared.fetchCompanies()
        
        view.backgroundColor = .white
        
        navigationItem.title = "Companies"
//        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "plus").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleAddCompany))
//        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Reset", style: .plain, target: self, action: #selector(handleReset))
        
        
        navigationItem.leftBarButtonItems = [
            UIBarButtonItem(title: "Reset", style: .plain, target: self, action: #selector(handleReset)),
            UIBarButtonItem(title: "Nested Updates", style: .plain, target: self, action: #selector(doNestedUpdates))
        ]
        
        
        setupPlusButtonInNavBar(selector: #selector(handleAddCompany))
        
        tableView.backgroundColor = .darkBlue
        //Esconde o separador de celulas em toda a tabela
        tableView.separatorStyle = .none
        
        //Ao definir uma view simples para a tableFooterView, esconde o separador de celulas a baixo da tabela onde nao ha dados
        tableView.tableFooterView = UIView()
        tableView.separatorColor = .white
        
        tableView.register(CompanyCell.self, forCellReuseIdentifier: cellId)
        
    }
    
    @objc func handleReset() {
        let context = CoreDataManager.shared.persistentContainer.viewContext
        
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: Company.fetchRequest())
        
        do {
            try context.execute(batchDeleteRequest)
            //No animation
//            companies.removeAll()
//            tableView.reloadData()
            
            var indexPathsToRemove = [IndexPath]()
            for (index, _) in companies.enumerated() {
                let indexPath = IndexPath(row: index, section: 0)
                indexPathsToRemove.append(indexPath)
            }
            companies.removeAll()
            tableView.deleteRows(at: indexPathsToRemove, with: .left)
        }
        catch let delErr {
            print("Failed to delete objects from Core Data: ", delErr)
        }
    }
    


    @objc func handleAddCompany() {
        print("Adding company...")
        
        let createCompanyController = CreateCompanyController()
        
        createCompanyController.delegate = self
        
        let navController = CustomNavigationController(rootViewController: createCompanyController)
        present(navController, animated: true, completion: nil)
    }
}

