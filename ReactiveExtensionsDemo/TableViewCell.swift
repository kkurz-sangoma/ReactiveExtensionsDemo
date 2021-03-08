//
//  TableViewCell.swift
//  ReactiveExtensionsDemo
//
//  Created by Kyle Kurz on 3/7/21.
//

import Foundation
import UIKit
import SDWebImage

class TableViewCell: UITableViewCell {
    @IBOutlet weak var nameOutlet: UILabel!
    @IBOutlet weak var numberOutlet: UILabel!
    @IBOutlet weak var emailOutlet: UILabel!
    @IBOutlet weak var pictureOutlet: UIImageView!
    
    func configure(with contact: Contact) {
        nameOutlet.text = "\(contact.firstName) \(contact.lastName)"
        numberOutlet.text = String(contact.number)
        emailOutlet.text = contact.email
        if let picture = contact.picture, let url = URL(string: picture) {
            pictureOutlet?.sd_setImage(with: url, completed: nil)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        nameOutlet.text = nil
        numberOutlet.text = nil
        emailOutlet.text = nil
        pictureOutlet.image = nil
    }
}
