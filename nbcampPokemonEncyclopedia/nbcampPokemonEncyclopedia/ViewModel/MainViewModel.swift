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
        let collectionViewData: BehaviorRelay<SectionOfCustomData>
        let error: PublishRelay<Error>
    }
    
    private let disposeBag = DisposeBag()
    
    private let collectionViewRelay = BehaviorRelay(value: SectionOfCustomData(header: .pokemonBall,
                                                                               items: [CollectionViewData]()))
    private let errorRelay = PublishRelay<Error>()
    
    private var offset = 0
    private var isLoading = false
    
    func transform(_ input: Input) -> Output {
        
        let mergeStream = Observable.merge(input.initialFetch, input.scrollFetch)
        
        mergeStream
            .subscribe(onNext: { [weak self] in
                self?.fetchImageList()
            }).disposed(by: disposeBag)
        
        return Output(
            collectionViewData: collectionViewRelay,
            error: errorRelay
        )
    }
    
    private func fetchImageList() {
        guard !isLoading else { return }
        isLoading = true
        
        guard let url = URL(string: "https://pokeapi.co/api/v2/pokemon?limit=20&offset=\(offset)") else {
            errorRelay.accept(CustomError.InvalidURL)
            return
        }
        
        NetworkManager.shared.fetch(url: url)
            .map { (listResponse: ListResponse) -> [CollectionViewData] in
                return listResponse.results.map{ CollectionViewData(name: $0.name, url: $0.url) }
            }
            .subscribe(onSuccess: { [weak self] result in
                guard let self else { return }
                let header = collectionViewRelay.value.header
                var priviousItems = collectionViewRelay.value.items
                priviousItems.append(contentsOf: result)
                let data = SectionOfCustomData(header: header, items: priviousItems)
                collectionViewRelay.accept(data)
                offset += 20
                isLoading = false
            }, onFailure: { [weak self] error in
                guard let self else { return }
                errorRelay.accept(error)
                isLoading = false
            }).disposed(by: disposeBag)
    }
}
