//
//  MainViewModel.swift
//  nbcampPokemonEncyclopedia
//
//  Created by LCH on 5/10/25.
//
import Foundation
import UIKit
import RxSwift
import RxCocoa

final class MainViewModel: BaseViewModel {
    
    private var disposeBag = DisposeBag()
    
    private let collectionViewRelay = BehaviorRelay<[SectionOfCustomData]>(value: [])
    private let errorRelay = PublishRelay<Error>()
    
    private var offset = 0
    private var isLoading = false
    
    func transform(_ input: Input) -> Output {
        
        let mergeStream = Observable.merge(input.initialFetch, input.scrollFetch)
        
        mergeStream
            .withUnretained(self)
            .filter { vm, _ in !vm.isLoading }
            .flatMap { vm, _ in
                vm.isLoading = true
                return vm.fetchListInfo()
            }
            .map { (listResponse: ListResponse) -> [CollectionViewData] in
                let test = listResponse.results.map{ CollectionViewData(name: $0.name, url: $0.url) }
                return test
            }
            .subscribe(onNext: { [weak self] data in
                guard let self else { return }
                let firstHeader = UIImage.pokemonBall
                var firstItems = [CollectionViewData]()
                if let previousItem = collectionViewRelay.value.first?.items {
                    firstItems = previousItem
                } else {
                    firstItems = [CollectionViewData]()
                }
                firstItems.append(contentsOf: data)
                let firstSection = SectionOfCustomData(header: firstHeader, items: firstItems)
                let sectionData: [SectionOfCustomData] = [
                    firstSection
                ]
                self.collectionViewRelay.accept(sectionData)
                offset += 20
                isLoading = false
            }, onError: { [weak self] error in
                guard let self else { return }
                self.errorRelay.accept(error)
            })
            .disposed(by: disposeBag)
        
        
        return Output(
            collectionViewData: collectionViewRelay,
            error: errorRelay
        )
    }
    
    private func fetchListInfo() -> Observable<ListResponse> {
        guard let url = URL(string: "https://pokeapi.co/api/v2/pokemon?limit=20&offset=\(offset)") else {
            errorRelay.accept(CustomError.InvalidURL)
            return .empty()
        }
        return NetworkManager.shared.fetch(url: url).asObservable()
    }
}

extension MainViewModel {
    struct Input {
        let initialFetch: Observable<Void>
        let scrollFetch: Observable<Void>
    }
    
    struct Output {
        let collectionViewData: BehaviorRelay<[SectionOfCustomData]>
        let error: PublishRelay<Error>
    }
}
