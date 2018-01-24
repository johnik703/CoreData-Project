//
//  CreateCompanyController.swift
//  CoreData Project
//
//  Created by Nuno Pereira on 22/01/2018.
//  Copyright © 2018 Nuno Pereira. All rights reserved.
//

import UIKit
import CoreData

protocol CreateCompanyControllerDelegate {
    func didAddCompany(company: Company)
}

class CreateCompanyController: UIViewController {
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Name"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter text"
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
//    var companiesController: CompaniesController?
    var delegate: CreateCompanyControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        navigationItem.title = "Create Company"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(handleCancel))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(handleSave))
        
        view.backgroundColor = .darkBlue
    }
    
    fileprivate func setupUI() {
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = .lightBlue
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(backgroundView)
        
        backgroundView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        backgroundView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        backgroundView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        backgroundView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        
        view.addSubview(nameLabel)
        nameLabel.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        nameLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16).isActive = true
        nameLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
        nameLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        
        view.addSubview(nameTextField)
        nameTextField.topAnchor.constraint(equalTo: nameLabel.topAnchor).isActive = true
        nameTextField.bottomAnchor.constraint(equalTo: nameLabel.bottomAnchor).isActive = true
        nameTextField.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        nameTextField.leftAnchor.constraint(equalTo: nameLabel.rightAnchor).isActive = true
    }
    
    @objc func handleSave() {
        
        //Initialization of CoreData Stack
        //o nome do container tem que ser igual ao nome do ficheiro do modelo criado
//        let persistentContainter = NSPersistentContainer(name: "CoreDataModel")
//
//        persistentContainter.loadPersistentStores { (storeDescription, err) in
//            if let err = err {
//                fatalError("Loading of store failed: \(err)")
//            }
//        }
//
//        let context = persistentContainter.viewContext
        
        let context = CoreDataManager.shared.persistentContainer.viewContext
        
        let company = NSEntityDescription.insertNewObject(forEntityName: "Company", into: context)
        
        company.setValue(nameTextField.text, forKey: "name")
        
        //perform the save
        do {
            try context.save()
            
            //Success on saving data on CoreData
            dismiss(animated: true, completion: {
                self.delegate?.didAddCompany(company: company as! Company)
            })
        }
        catch let saveErr {
            print("Error to save company: ", saveErr)
        }
    }
    
    @objc func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
}
