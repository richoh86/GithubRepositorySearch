//
//  MainSearchViewController.swift
//  GithubRepositorySearch
//
//  Created by richoh86 on 2020/03/29.
//  Copyright © 2020 richoh86. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class MainSearchViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    let searchController = UISearchController(searchResultsController: nil)
    var searchBar: UISearchBar { return searchController.searchBar }
    
    var viewModel = MainSearchViewModel()
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSearchController()
        
        viewModel.data
            .drive(tableView.rx.items(cellIdentifier: "Cell")) { _, repository, cell in
                cell.textLabel?.text = repository.repoName
                cell.detailTextLabel?.text = repository.repoURL
        }
        .disposed(by: disposeBag)
        
        searchBar.rx.text.orEmpty
            .bind(to: viewModel.searchText)
            .disposed(by: disposeBag)
        
        viewModel.data.asDriver()
            .map { "\($0.count) Repositories" }
            .drive(navigationItem.rx.title)
            .disposed(by: disposeBag)
    }
    
    func configureSearchController() {
        searchController.obscuresBackgroundDuringPresentation = false
        searchBar.showsCancelButton = true
        searchBar.text = "richoh86"
        searchBar.placeholder = "Enter GitHub ID, e.g., \"richoh86\""
        tableView.tableHeaderView = searchController.searchBar
        definesPresentationContext = true
    }
}

