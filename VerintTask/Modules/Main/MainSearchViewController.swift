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

    private var universitySearchProvider: UniversitySearchProvider! // Should be in interactor or presenter
    
    private var searchController: UISearchController?
    
    private var universities: [University] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    lazy var refreshControl: UIRefreshControl = {
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        refreshControl.tintColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        
        return refreshControl
    }()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        universitySearchProvider = UniversitySearchProvider(withUniversityService: UniversitySearchService())
    }
    
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
    
    // Better to use some kind of coordinator or App router for coordination between modules
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == StoryboardSegue.Main.showUniversityDetail.rawValue {
            let destController = segue.destination as! DetailViewController
            let tableViewCell = sender as! MainSearchControllerCell
            
            guard let index = tableView.indexPath(for: tableViewCell)?.row else {
                return
            }
            
            destController.university = universities[index]
            destController.image = tableViewCell.detailImageView.image
        }
    }
    
    @IBAction func unwindToMainSearchViewController(unwindSegue: UIStoryboardSegue) {
        let sourceViewcontroller = unwindSegue.source as! DetailViewController
        
        guard let university = sourceViewcontroller.university else {
            return
        }
        
        universitySearchProvider.updateUniversities(withUniversity: university)
    }
}

// MARK: - Table view delegate & data source methods

extension MainSearchViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return universities.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MainSearchControllerCell.xibName, for: indexPath) as? MainSearchControllerCell else {
            return UITableViewCell()
        }
        
        // Cell tuning with data from model better should be in presenter
        let row = indexPath.row
        let university = universities[row]
        let description = "country: \(university.country)\nweb page: \(university.webPages[safe: 0] ?? "no website")"
        let domain = university.domains[safe: 0] ?? ""
        
        cell.configureCell(withTitle: university.name, subtitle: description, image: Asset.emptyUniversity.image, isFavourite: university.isFavourite)
        
        // Allows to avoid unnecessary network operation
        guard university.logotype == nil else {
            cell.detailImageView.image = UIImage(data: university.logotype!)
            return cell
        }
        
        // It would be better to obtain and cache logos somwhere in DB to provide quick access without necessity to call network request
        cell.activityIndicatorView.startAnimating()
        universitySearchProvider.obtainLogo(byUniversityDomain: domain,
                                           onSuccess:
            { (image) in
                if row == indexPath.row {
                    // set logo image into cell
                    cell.detailImageView.image = image
                }
                
                cell.activityIndicatorView.stopAnimating()
            },
                                           onFailure:
            { (error) in
                cell.imageView?.image = Asset.emptyUniversity.image
                
                cell.activityIndicatorView.stopAnimating()
            })
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tableViewCell = tableView.cellForRow(at: indexPath)
        perform(segue: StoryboardSegue.Main.showUniversityDetail, sender: tableViewCell)
    }
}

// MARK: - Search delegate methods

extension MainSearchViewController: UISearchResultsUpdating, UISearchBarDelegate {
    
    func updateSearchResults(for searchController: UISearchController) {
        let text = searchController.searchBar.text ?? ""
        
        renewData(withPartialName: text)
    }
}

// MARK: - Action methods
extension MainSearchViewController {
    @objc func refresh(_ sender: UIRefreshControl?) {
        DispatchQueue.main.async { [weak self] in
            
            let name = self?.searchController?.searchBar.text ?? ""
            
            self?.renewData(withPartialName: name)
        }
    }
}

// MARK: - Configurators - better make outer configurator, implementing builder pattern
extension MainSearchViewController {
    
    // For UITesting
    func configure(withSearchService service: UniversitySearchServiceProtocol) {
        universitySearchProvider = UniversitySearchProvider(withUniversityService: service)
    }
    
    func configure(withSearchProvider provider: UniversitySearchProvider) {
        universitySearchProvider = provider
    }
}

// MARK: - helper methods
fileprivate extension MainSearchViewController {
    func renewData(withPartialName name: String) {
        
        guard !name.isEmpty else {
            universities = []
            tableView.reloadData()
            return
        }
            
        // This logic also should be somewhere in interactor or presenter
        universitySearchProvider.searchUniversities(byParticialName: name,
                                                   onSuccess:
            { [weak self] (results) in
                self?.universities = results
                self?.tableView.reloadData()
                self?.refreshControl.endRefreshing()
            },
                                                   onFailure:
            { [weak self] (error) in
                print(error)
                self?.refreshControl.endRefreshing()
            })
    }
}
