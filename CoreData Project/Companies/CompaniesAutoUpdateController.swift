//
//  CompaniesAutoUpdateController.swift
//  CoreData Project
//
//  Created by Nuno Pereira on 04/02/2018.
//  Copyright © 2018 Nuno Pereira. All rights reserved.
//

import UIKit
import CoreData

class CompaniesAutoUpdateController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    let cellId = "cellId"
    
    lazy var fetchedResultsController: NSFetchedResultsController<Company> = {
        let context = CoreDataManager.shared.persistentContainer.viewContext;
        let request: NSFetchRequest<Company> = Company.fetchRequest()
        
        //Definicao da key name significa que e com base nesta que ira ser feita a ordenacao
        request.sortDescriptors = [
            NSSortDescriptor(key: "name", ascending: true)
        ]
        
        let frc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: "name", cacheName: nil)
        
        frc.delegate = self
        
        do {
            try frc.performFetch()
        }
        catch let err {
            print(err)
        }
        return frc
    }()
    
    
    //E chamado antes do save
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        case .move:
            break
        case .update:
            break
        }
    }
    
    //E chamado sempre que ha um alteracao no CoreData seja, insercao, remocao, alteracao, movimentacao
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .fade)
        case .move:
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }
    
    //E chamado depois do save
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, sectionIndexTitleForSectionName sectionName: String) -> String? {
        return sectionName
    }
    
    @objc func handleAdd() {
        
        let context = CoreDataManager.shared.persistentContainer.viewContext
        let company = Company(context: context)
        
        company.name = "BMW"
        
        do {
            try context.save()
        }
        catch let err {
            print("Failed to sabe: ", err)
        }
    }
    
    @objc func handleDelete() {
        
        let request: NSFetchRequest<Company> = Company.fetchRequest()
//        request.predicate = NSPredicate(format: "name CONTAINS %@", "B")
        
        let context = CoreDataManager.shared.persistentContainer.viewContext
        
        do {
            let companiesWithB = try context.fetch(request)
            
            companiesWithB.forEach({ (company) in
                context.delete(company)
            })
            
            do {
                try context.save()
            }
            catch let err {
                print("Failed to delete companies with predicate: ", err)
            }
        }
        catch let err {
            print("Failed fetching companies with predicate: ", err)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .darkBlue
        
        navigationItem.leftBarButtonItems = [
            UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(handleAdd)),
            UIBarButtonItem(title: "Delete", style: .plain, target: self, action: #selector(handleDelete))
        ]
        
        navigationItem.title = "Company Auto Updates!"
        
        tableView.register(CompanyCell.self, forCellReuseIdentifier: cellId)
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        refreshControl.tintColor = .white
        
        self.refreshControl = refreshControl
    }
    
    @objc func handleRefresh() {
       Service.shared.downloadCompaniesFromServer()
        refreshControl?.endRefreshing()
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = IndentedLabel()
        label.backgroundColor = .lightBlue
        label.text = fetchedResultsController.sectionIndexTitles[section]
        return label
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //A propriedade retorna um array das seccoes e em cada posicao o numero de objectos
        return fetchedResultsController.sections![section].numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! CompanyCell
        
        let company = fetchedResultsController.object(at: indexPath)
        
        cell.company = company
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let employeesListController = EmployeesController()
        employeesListController.company = fetchedResultsController.object(at: indexPath)
        navigationController?.pushViewController(employeesListController, animated: true)
    }
}
