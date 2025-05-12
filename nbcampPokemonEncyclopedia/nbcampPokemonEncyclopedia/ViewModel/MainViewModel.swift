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
    
    struct Input {
        let initialFetch: Observable<Void>
        let scrollFetch: Observable<Void>
    }
    
    struct Output {
        let imageList: BehaviorRelay<[ListResponse.Results]>
        let error: PublishSubject<Error>
    }
    
    
    private let disposeBag = DisposeBag()
    
    private let imageListRelay = BehaviorRelay(value: [ListResponse.Results]())
    private let errorSubject = PublishSubject<Error>()
    
    private var offset = 0
    private var isLoading = false
    
    func transform(_ input: Input) -> Output {
        
        let mergeStream = Observable.merge(input.initialFetch, input.scrollFetch)
        
        mergeStream
            .subscribe(onNext: { [weak self] in
                self?.fetchImageList()
            }).disposed(by: disposeBag)
        
        return Output(
            imageList: imageListRelay,
            error: errorSubject
        )
    }
    
    private func fetchImageList() {
        guard !isLoading else { return }
        isLoading = true
        
        guard let url = URL(string: "https://pokeapi.co/api/v2/pokemon?limit=20&offset=\(offset)") else {
            errorSubject.onNext(CustomError.InvalidURL)
            return
        }
        
        NetworkManager.shared.fetch(url: url)
            .subscribe(onSuccess: { [weak self] (listResponse: ListResponse) in
                guard let self else { return }
                var priviousData = imageListRelay.value
                priviousData.append(contentsOf: listResponse.results)
                imageListRelay.accept(priviousData)
                offset += 20
                isLoading = false
            }, onFailure: { [weak self] error in
                self?.errorSubject.onNext(error)
                self?.isLoading = false
            }).disposed(by: disposeBag)
    }
}
