//
//  ViewController.swift
//  CoreDataTraining
//
//  Created by Siyu Liu on 13/5/18.
//  Copyright © 2018 Siyu Liu. All rights reserved.
//

import UIKit

class CompaniesTableViewController: UITableViewController {
    private let cellId = "cellId"
    private var tableViewDataSource: UITableViewDataSource?
    private let model = CompaniesModel()
    weak var coordinator: Coorinator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavigationItem()
        setUpTableView()

    }
    
    private func setUpTableView() {
        tableView.backgroundColor = ColourScheme.tableViewBackgroundColour
        tableView.register(CompanyTableViewCell.self, forCellReuseIdentifier: cellId)
        tableView.tableFooterView = UIView()
        navigationController?.navigationBar.prefersLargeTitles = true
        model.fetchCompanies()
    }
    
    private func setUpNavigationItem() {
        view.backgroundColor = .white
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.onAddPressed))
        navigationItem.title = "Companies"
        
    }
    
    
    @objc private func onAddPressed() {
        guard coordinator != nil else { return }
        coordinator?.createCompany(delegate: self)
    }

}

extension CompaniesTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.numberOfCompanies
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! CompanyTableViewCell
        if let company = model.getCompany(index: indexPath.row) {
            cell.loadCompany(company)
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        return view
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { (_, indexPath) in
            self.model.deleteCompany(index: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
        let editAction = UITableViewRowAction(style: .normal, title: "Edit") { (_, indexPath) in
            guard let companies = self.model.companies else { return }
            let company = companies[indexPath.row]
            let tempCompany = TempCompany(name: company.name!, date: company.founded!)
            self.coordinator?.editCompany(delegate: self, tempCompany: tempCompany, companyIndex: indexPath.row)
        }
        
        return [deleteAction, editAction]
    }
}

extension CompaniesTableViewController: CreateCompanyDelegate {
    func didAddCompany(in object: TempCompany) {
        model.insertCompany(in: object)
        tableView.insertRows(at: [IndexPath(row: model.numberOfCompanies - 1, section: 0)], with: .automatic)
    }
    
    func didEditCompany(atIndex index: Int, newData: TempCompany) {
        model.updateCompany(atIndex: index, newData: newData)
        tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .middle)
    }
}

