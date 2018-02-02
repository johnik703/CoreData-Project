//
//  CompaniesController+CreateCompany.swift
//  CoreData Project
//
//  Created by Nuno Pereira on 28/01/2018.
//  Copyright © 2018 Nuno Pereira. All rights reserved.
//

import UIKit

extension CompaniesController: CreateCompanyControllerDelegate {
    func didEditCompany(company: Company) {
        //update tableView
        let row = companies.index(of: company)
        
        let reloadIndexPath = IndexPath(row: row!, section: 0)
        
        tableView.reloadRows(at: [reloadIndexPath], with: .middle)
    }
    
    func didAddCompany(company: Company) {
        
        companies.append(company)
        
        let indexPath = IndexPath(row: companies.count - 1, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
    }
}
