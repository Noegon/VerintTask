//
//  DetailViewController.swift
//  VerintTask
//
//  Created by astafeev on 2/12/19.
//  Copyright © 2019 astafeev. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    // var model...
    
    @IBOutlet weak var detailImageView: UIImageView!
    @IBOutlet weak var universityNameLabel: UILabel!
    @IBOutlet weak var domainLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var favouriteSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @IBAction func favouriteValueChanged(_ sender: UISwitch) {
        let isFavourite = sender.isOn
        // TODO: Add logic here
    }
    
    @IBAction func visitSiteButtontapped(_ sender: Any) {
        // TODO: Handle gesture - link to "safari"
    }
}

