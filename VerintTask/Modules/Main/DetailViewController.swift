//
//  DetailViewController.swift
//  VerintTask
//
//  Created by astafeev on 2/12/19.
//  Copyright © 2019 astafeev. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    var image: UIImage?
    var university: University?
    
    @IBOutlet weak var detailImageView: UIImageView!
    @IBOutlet weak var universityNameLabel: UILabel!
    @IBOutlet weak var domainLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var favouriteSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        detailImageView.image = image
        if detailImageView.image == nil {
            detailImageView.image = university?.logotype != nil ? UIImage(data: (university?.logotype)!) : Asset.emptyUniversity.image
        }
        
        universityNameLabel.text = university?.name
        domainLabel.text = university?.domains[safe: 0]
        locationLabel.text = university?.country
        favouriteSwitch.isOn = university?.isFavourite ?? false
        
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(title: "❮ Back", style: UIBarButtonItem.Style.plain, target: self, action: #selector(back(sender:)))
        self.navigationItem.leftBarButtonItem = newBackButton
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @IBAction func favouriteValueChanged(_ sender: UISwitch) {
        university?.isFavourite = sender.isOn
    }
    
    @IBAction func visitSiteButtontapped(_ sender: Any) {
        guard let url = URL(string: university?.webPages[safe: 0] ?? "") else { return }
        UIApplication.shared.open(url)
    }
    
    @objc func back(sender: UIBarButtonItem) {
        perform(segue: StoryboardSegue.Main.unwindSegueToMainSearchViewController, sender: sender)
    }
}

