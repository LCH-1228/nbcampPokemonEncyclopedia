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
    
    private var offset = 0
    private var isLoading = false
    
    init() {
        fetchImageList()
    }
    
    func fetchImageList() {
        guard !isLoading else { return }
        isLoading = true
        
        guard let url = URL(string: "https://pokeapi.co/api/v2/pokemon?limit=20&offset=\(offset)") else { return }
        
        NetworkManager.shared.fetch(url: url)
            .subscribe(onSuccess: { [weak self] (listResponse: ListResponse) in
                self?.imageListRelay.accept(listResponse.results)
                self?.offset += 20
                self?.isLoading = false
            }, onFailure: { [weak self] error in
                self?.errorsubject.onNext(error)
            }).disposed(by: disposeBag)
    }
}
