//
//  MainViewModel.swift
//  nbcampPokemonEncyclopedia
//
//  Created by LCH on 5/10/25.
//
import Foundation
import RxSwift
import RxCocoa

class MainViewModel {
    
    private let disposeBag = DisposeBag()
    
    let imageListRelay = BehaviorRelay(value: [ListResponse.Results]())
    let errorsubject = PublishSubject<Error>()
    
    init() {
        fetchImageList()
    }
    
    func fetchImageList() {
        guard let url = URL(string: "https://pokeapi.co/api/v2/pokemon?limit=20&offset=0") else { return }
        
        NetworkManager.shared.fetch(url: url)
            .subscribe(onSuccess: { [weak self] (listResponse: ListResponse) in
                self?.imageListRelay.accept(listResponse.results)
            }, onFailure: { [weak self] error in
                self?.errorsubject.onNext(error)
            }).disposed(by: disposeBag)
    }
}
