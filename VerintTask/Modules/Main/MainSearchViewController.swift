//
//  ViewController.swift
//  VerintTask
//
//  Created by astafeev on 2/12/19.
//  Copyright © 2019 astafeev. All rights reserved.
//

import UIKit

// Better not to use MVC but this project is too small and there is too less time to provide something more complex like MVP or VIP
class MainSearchViewController: UIViewController {

    private let universitySearchService: UniversitySearchService = UniversitySearchService() // Should be in interactor or presenter
    
    private var searchController: UISearchController?
    
    @IBOutlet weak var tableView: UITableView!
    
    lazy var refreshControl: UIRefreshControl = {
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        refreshControl.tintColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = L10n.mainControllerNavigationBarTitle
        
        // table view setup
        tableView.delegate = self as UITableViewDelegate
        tableView.dataSource = self as UITableViewDataSource
        tableView.estimatedRowHeight = 3000 // Some big number for automatic cell height tuning
        
        // search bar setup
        searchController = UISearchController(searchResultsController: nil)
        searchController?.searchResultsUpdater = self as UISearchResultsUpdating
        searchController?.searchBar.delegate = self as UISearchBarDelegate
        
        searchController?.dimsBackgroundDuringPresentation = false
        searchController?.searchBar.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        searchController?.searchBar.selectedScopeButtonIndex = 0
        tableView.tableHeaderView = searchController?.searchBar
        definesPresentationContext = true
        
        searchController?.searchBar.sizeToFit()
        searchController?.searchBar.placeholder = L10n.mainControllerSearchBarPlaceholder
        
        tableView.register(UINib(nibName: MainSearchControllerCell.xibName, bundle: nil),
                           forCellReuseIdentifier: MainSearchControllerCell.xibName)
        
        tableView.addSubview(refreshControl)
    }
}

// MARK: - Navigation

extension MainSearchViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // TODO: set model or model id here
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        perform(segue: StoryboardSegue.Main.showUniversityDetail)
    }
}

// MARK: - Search delegate methods

extension MainSearchViewController: UISearchResultsUpdating, UISearchBarDelegate {
    
    func updateSearchResults(for searchController: UISearchController) {
        // TODO: Cache obtained data here
        tableView.reloadData()
    }
}

// MARK: - Action methods
extension MainSearchViewController {
    @objc open func refresh(_ sender: UIRefreshControl?) {
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData() // Stub - update model here
            self?.refreshControl.endRefreshing()
        }
    }
}
