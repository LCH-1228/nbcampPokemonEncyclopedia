//
//  DetailViewModel.swift
//  nbcampPokemonEncyclopedia
//
//  Created by LCH on 5/10/25.
//
import Foundation
import RxSwift
import RxCocoa

class DetailViewModel {
    
    struct Input {
        let initialFetch: Observable<Void>
    }
    
    struct Output {
        let infoList: PublishRelay<[DetailResponse]>
        let error: PublishSubject<Error>
    }
    
    private var url: URL
    
    private let disposeBag = DisposeBag()
    
    private let detailInfoSubject = PublishRelay<[DetailResponse]>()
    private let errorSubject = PublishSubject<Error>()
    
    init(url: URL) {
        self.url = url
    }
    
    func transform(_ input: Input) -> Output {
        input.initialFetch
            .subscribe(onNext: { [weak self] url in
                guard let self else { return }
                fetchDetailInfo(url: self.url)
            }).disposed(by: disposeBag)
        
        return Output(
            infoList: detailInfoSubject,
            error: errorSubject
        )
    }
    
    private func fetchDetailInfo(url: URL) {
        NetworkManager.shared.fetch(url: url)
            .subscribe(onSuccess: { [weak self] (detailResponse: DetailResponse) in
                self?.detailInfoSubject.accept([detailResponse])
            }, onFailure: { [weak self] error in
                self?.errorSubject.onNext(error)
            }).disposed(by: disposeBag)
    }
}
