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
    
    private let disposeBad = DisposeBag()
    
    let detailInfoSubject = PublishRelay<[DetailResponse]>()
    let errorSubject = PublishSubject<Error>()
    
    init(url: URL) {
        fetchDetailInfo(url: url)
    }
    
    private func fetchDetailInfo(url: URL) {
        NetworkManager.shared.fetch(url: url)
            .subscribe(onSuccess: { [weak self] (detailResponse: DetailResponse) in
                self?.detailInfoSubject.accept([detailResponse])
            }, onFailure: { [weak self] error in
                self?.errorSubject.onNext(error)
            }).disposed(by: disposeBad)
    }
}
