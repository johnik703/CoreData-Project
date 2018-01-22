//
//  CreateCompanyController.swift
//  CoreData Project
//
//  Created by Nuno Pereira on 22/01/2018.
//  Copyright © 2018 Nuno Pereira. All rights reserved.
//

import UIKit

class CreateCompanyController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Create Company"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(handleCancel))
        view.backgroundColor = .darkBlue
    }
    
    @objc func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
}
