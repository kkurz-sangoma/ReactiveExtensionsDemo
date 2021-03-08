//
//  TableViewController.swift
//  ReactiveExtensionsDemo
//
//  Created by Kyle Kurz on 3/5/21.
//

import UIKit
import RxSwift
import RxDataSources

// Some boilerplate for handling sectioning
public struct ContactSection {
    public var header: String
    public var items: [Item]
    
    public init(header: String, items: [Item]) {
        self.header = header
        self.items = items
    }
}

extension ContactSection: SectionModelType {
    public typealias Item = Any
    
    public init(original: ContactSection, items: [Item]) {
        self = original
        self.items = items
    }
}

class TableViewController: UITableViewController {
    let disposeBag = DisposeBag()
    @IBOutlet weak var sortOrder: UIBarButtonItem!
    
    func getSectionedContactList(from contacts: [Contact], sortedBy sortOrder: ContactSortOrder) -> [ContactSection] {
        let headers = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M",
                       "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "#" ]
        
        let sections: [String: ContactSection] =
            headers.map { header in
                ContactSection(header: header, items: contacts.filter { $0.sectionIndex(with: sortOrder) == header })
            }.reduce(into: [String: ContactSection]()) { $0[$1.header] = $1}
        
        // Put the octothorpe at the end of the list, even though it's technically the first
        return sections.values.filter { $0.items.count > 0 }.sorted { (lhs, rhs) -> Bool in
            // if either header is "#", it always goes after whatever the other one is
            if lhs.header == "#" {
                return false
            } else if rhs.header == "#" {
                return true
            }
            return lhs.header < rhs.header
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let delegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        // Important to allow Rx to feed the table data
        tableView.delegate = nil
        tableView.dataSource = nil
        
        // Build a data source that can feed the table view with a sectioned list
        let dataSource = RxTableViewSectionedReloadDataSource<ContactSection>(
            configureCell: { _, tableView, indexPath, item in
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "tableViewCell", for: indexPath)
                        as? TableViewCell,
                      let contact = item as? Contact else { return UITableViewCell() }
                cell.configure(with: contact)
                return cell
            },
            sectionIndexTitles: { dataSource in
                return ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U",
                        "V", "W", "X", "Y", "Z", "#" ]
            }
        )
        
        dataSource.titleForHeaderInSection = { dataSource, index in
            return dataSource.sectionModels[index].header
        }
        
        // Combine the list and the sort order to show the list correctly
        Observable.combineLatest(delegate.contactList, delegate.sortOrder)
            .map { self.getSectionedContactList(from: $0, sortedBy: $1) }
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        // When the button is tapped, change the sort order
        sortOrder.rx.tap
            .withLatestFrom(delegate.sortOrder) { ($0, $1) }
            .subscribe { (_, order) in
                switch order {
                case .firstName:
                    delegate.sortOrder.onNext(.lastName)
                case .lastName:
                    delegate.sortOrder.onNext(.firstName)
                }
            }.disposed(by: disposeBag)
        
        tableView.rx.modelSelected(Contact.self)
            .observe(on: MainScheduler.asyncInstance)
            .subscribe { event in
                if let contact = event.element {
                    let alert = UIAlertController(title: "\(contact.firstName) \(contact.lastName)",
                                                  message: "You selected the contact with number \(contact.number)",
                                                  preferredStyle: .alert)
                    let action = UIAlertAction.init(title: "OK", style: .default, handler: nil)
                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                }
            }.disposed(by: disposeBag)
    }
}
