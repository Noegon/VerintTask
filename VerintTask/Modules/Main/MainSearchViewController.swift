//
//  ViewController.swift
//  VerintTask
//
//  Created by astafeev on 2/12/19.
//  Copyright © 2019 astafeev. All rights reserved.
//

import UIKit

class MainSearchViewController: UIViewController {

    private var searchBar: UISearchBar?
    private var searchController: UISearchController?
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // table view setup
        tableView.delegate = self as? UITableViewDelegate
        tableView.dataSource = self as? UITableViewDataSource
        tableView.estimatedRowHeight = 3000 // Some big number for automatic cell height tuning
        
        // search bar setup
        searchController = UISearchController()
        searchController?.searchResultsUpdater = self as? UISearchResultsUpdating
        searchController?.searchBar.delegate = self as? UISearchBarDelegate
        
        searchController?.dimsBackgroundDuringPresentation = false
        searchController?.searchBar.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        searchController?.searchBar.selectedScopeButtonIndex = 0
        tableView.tableHeaderView = searchController?.searchBar
        definesPresentationContext = true
        
        searchController?.searchBar.sizeToFit()
        
        tableView.register(UINib(nibName: MainSearchControllerCell.xibName, bundle: nil),
                           forCellReuseIdentifier: MainSearchControllerCell.xibName)
    }
}

// MARK: - Table view delegate & data source methods

extension MainSearchViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3 // TODO: Stub
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MainSearchControllerCell.xibName, for: indexPath) as? MainSearchControllerCell else {
            return UITableViewCell()
        }
        
        cell.configureCell(withTitle: "Harvard", subtitle: "Cool place. But boring.\nVery boooooooooooring.\nI don't want to go to school! I just want to break the rule!", image: Asset.emptyUniversity.image)
        
        return cell
    }
}

// MARK: - Search delegate methods

extension MainSearchViewController: UISearchResultsUpdating, UISearchBarDelegate {
    
    func updateSearchResults(for searchController: UISearchController) {
        
    }
}
