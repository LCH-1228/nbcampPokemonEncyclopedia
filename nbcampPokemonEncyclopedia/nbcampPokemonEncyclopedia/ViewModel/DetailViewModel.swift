//
//  DetailViewModel.swift
//  nbcampPokemonEncyclopedia
//
//  Created by LCH on 5/10/25.
//
import Foundation
import RxSwift
import RxCocoa
import Kingfisher

class DetailViewModel {
    
    struct Input {
        let initialFetch: Observable<Void>
    }
    
    struct Output {
        let imageInfo: PublishRelay<URL>
        let idAndNameInfo: PublishRelay<String>
        let typeInfo: PublishRelay<String>
        let heightInfo: PublishRelay<String>
        let weightInfo: PublishRelay<String>
        let error: PublishRelay<Error>
    }
    
    private let disposeBag = DisposeBag()
    
    private let imageInfo = PublishRelay<URL>()
    private let idAndNameInfoRelay = PublishRelay<String>()
    private let typeInfoRelay = PublishRelay<String>()
    private let heightInfoRelay = PublishRelay<String>()
    private let weightInfoRelay = PublishRelay<String>()
    private let errorRelay = PublishRelay<Error>()
    
    private var url: URL
    
    init(url: URL) {
        self.url = url
    }
    
    func transform(_ input: Input) -> Output {
        input.initialFetch
            .withUnretained(self)
            .flatMap { vm, _ -> Observable<DetailResponse> in
                return vm.fetchDetailInfo(url: vm.url)
            }
            .catch({ [weak self] error in
                guard let self else { return .empty() }
                errorRelay.accept(error)
                return .empty()
            })
            .subscribe(onNext: { [weak self] detailResponse in
                guard let self else { return }
                transformText(detailResponse: detailResponse)
            }, onError: { [weak self] error in
                guard let self else { return }
                errorRelay.accept(error)
            }).disposed(by: disposeBag)
        
        return Output(imageInfo: imageInfo,
                      idAndNameInfo: idAndNameInfoRelay,
                      typeInfo: typeInfoRelay,
                      heightInfo: heightInfoRelay,
                      weightInfo: weightInfoRelay,
                      error: errorRelay)
    }
    
    private func fetchDetailInfo(url: URL) -> Observable<DetailResponse> {
        return NetworkManager.shared.fetch(url: url).asObservable()
    }
    
    private func transformText(detailResponse: DetailResponse) {
        guard let type = detailResponse.types.first?.type.name else { return }
        guard let koreanType = PokemonKoreanType(rawValue: type)?.displayName else { return }
        guard let url = URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/\(detailResponse.id).png") else { return }
        let koreanName = PokemonKoreanName.getKoreanName(for: detailResponse.name)
        let height = String(format: "%.1f m", Double(detailResponse.height) / 10)
        let weight = String(format: "%.1f kg", Double(detailResponse.weight) / 10)
        
        imageInfo.accept(url)
        idAndNameInfoRelay.accept("No.\(detailResponse.id) \(koreanName)")
        typeInfoRelay.accept("타입: \(koreanType)")
        heightInfoRelay.accept("키: \(height)")
        weightInfoRelay.accept("몸무게: \(weight)")
    }
}
