//
//  CreateEmployeeController.swift
//  CoreData Project
//
//  Created by Nuno Pereira on 28/01/2018.
//  Copyright © 2018 Nuno Pereira. All rights reserved.
//

import UIKit

protocol CreateEmployeeControllerDelegate {
    func didAddEmployee(employee: Employee)
}

class CreateEmployeeController: UIViewController {
    
    var company: Company?
    
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
    
    let birthdayLabel: UILabel = {
        let label = UILabel()
        label.text = "Birthday"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let birthdayTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "MM/dd/yyyy"
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    let employeeTypeSegmentedControll: UISegmentedControl = {
        let types = [
            EmployeeType.Executive.rawValue,
            EmployeeType.SeniorManagement.rawValue,
            EmployeeType.Staff.rawValue,
            EmployeeType.Intern.rawValue
        ]
        
        let sc = UISegmentedControl(items: types)
        sc.translatesAutoresizingMaskIntoConstraints = false
        sc.selectedSegmentIndex = 0
        sc.tintColor = .darkBlue
        
        return sc
    }()
    
    var delegate: CreateEmployeeControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .darkBlue
        
        navigationItem.title = "Create Employee"
        
        setupCancelButton()
        
        setupUI()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(handleSave))
    }
    
    @objc func handleSave() {
        guard let employeeName = nameTextField.text else {return}
        guard let company = self.company else {return}
        
        //turn birthdayTextField.text into a date object
        guard let birthdayText = birthdayTextField.text else {return}
        
        if birthdayText.isEmpty {
            showError(title: "Empty Birthday", message: "You have not entered a birthday!")
            return
        }
        
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        
        guard let birthdayDate = dateFormatter.date(from: birthdayText) else {
            showError(title: "Bad Date", message: "Birthday date entered not valid!")
            return
        }
        
        guard let employeeType = employeeTypeSegmentedControll.titleForSegment(at: employeeTypeSegmentedControll.selectedSegmentIndex) else {return}
        
        let tupple = CoreDataManager.shared.createEmployee(employeeName: employeeName, employeeType: employeeType, birthday: birthdayDate, company: company)
        
        if let error = tupple.1 {
            //show here some error that occures when saving an employee
            print(error)
        }
        else {
            dismiss(animated: true, completion: {
                self.delegate?.didAddEmployee(employee: tupple.0!)
            })
        }
    }
    
    private func showError(title: String, message: String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    func setupUI() {
        _ = setupLightBlueBackgroundView(height: 150)
        
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
        
        view.addSubview(birthdayLabel)
        birthdayLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor).isActive = true
        birthdayLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16).isActive = true
        birthdayLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
        birthdayLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        
        view.addSubview(birthdayTextField)
        birthdayTextField.topAnchor.constraint(equalTo: birthdayLabel.topAnchor).isActive = true
        birthdayTextField.bottomAnchor.constraint(equalTo: birthdayLabel.bottomAnchor).isActive = true
        birthdayTextField.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        birthdayTextField.leftAnchor.constraint(equalTo: birthdayLabel.rightAnchor).isActive = true
        
        view.addSubview(employeeTypeSegmentedControll)
        employeeTypeSegmentedControll.topAnchor.constraint(equalTo: birthdayLabel.bottomAnchor).isActive = true
        employeeTypeSegmentedControll.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16).isActive = true
        employeeTypeSegmentedControll.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16).isActive = true
        employeeTypeSegmentedControll.heightAnchor.constraint(equalToConstant: 34).isActive = true
    }
}
