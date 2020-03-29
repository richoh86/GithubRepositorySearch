//
//  MainSearchViewModel.swift
//  GithubRepositorySearch
//
//  Created by richoh86 on 2020/03/29.
//  Copyright © 2020 richoh86. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class MainSearchViewModel {
    
    let searchText = BehaviorRelay(value: "")
    
    lazy var data: Driver<[Repository]> = {
        return self.searchText.asObservable()
            .throttle(DispatchTimeInterval.seconds(Int(0.3)), latest: true, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .flatMapLatest(MainSearchViewModel.repositoriesBy)
            .asDriver(onErrorJustReturn: [])
    }()
    
    static func repositoriesBy(_ githubID: String) -> Observable<[Repository]> {
        guard !githubID.isEmpty,
            let url = URL(string: "https://api.github.com/users/\(githubID)/repos") else {
                return Observable.just([])
        }
        
        return URLSession.shared.rx.json(url: url)
//            .retry(3)
            .catchErrorJustReturn([])
            .map(parse)
    }
    
    static func parse(json: Any) -> [Repository] {
        guard let items = json as? [[String: Any]] else {
            return []
        }
        var repositories = [Repository]()
        items.forEach {
            guard let repoName = $0["name"] as? String,
                let repoURL = $0["html_url"] as? String else {
                    return
            }
            repositories.append(Repository(repoName: repoName, repoURL: repoURL))
        }
        return repositories
    }
    
}
