//
//  TableViewController.swift
//  ReactiveExtensionsDemo
//
//  Created by Kyle Kurz on 3/5/21.
//

import UIKit
import RxSwift
import RxDataSources

class TableViewController: UITableViewController {
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let delegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        // Important to allow Rx to feed the table data
        tableView.delegate = nil
        tableView.dataSource = nil
        
        // Subscribe to the contact list and bind it to the table data
        delegate.contactList
            .observe(on: MainScheduler.asyncInstance)
            .bind(to: self.tableView.rx.items(cellIdentifier: "tableViewCell", cellType: TableViewCell.self)) { (_, contact, cell) in
                cell.configure(with: contact)
            }.disposed(by: disposeBag)
    }


}

