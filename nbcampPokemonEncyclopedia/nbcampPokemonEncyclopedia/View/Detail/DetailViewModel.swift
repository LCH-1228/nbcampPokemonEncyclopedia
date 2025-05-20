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

final class DetailViewModel: BaseViewModel {
    
    private var disposeBag = DisposeBag()
    
    private let errorRelay = PublishRelay<Error>()
    
    private var url: URL
    
    init(url: URL) {
        self.url = url
    }
    
    func transform(_ input: Input) -> Output {
        let detail = input.initialFetch
            .withUnretained(self)
            .flatMap { vm, _ -> Observable<DetailResponse> in
                return vm.fetchDetailInfo(url: vm.url)
                    .catch { [weak self] error in
                        self?.errorRelay.accept(error)
                        return .empty()
                    }
            }
            .share()
        
        let imageInfo = detail
            .compactMap {
                URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/\($0.id).png")

            }
            .asDriver(onErrorDriveWith: .empty())
        
        let idAndNameInfo = detail
            .map {
                let koreanName = PokemonKoreanName.getKoreanName(for: $0.name)
                return "No.\($0.id) \(koreanName)"
            }
            .asDriver(onErrorDriveWith: .empty())
        
        let typeInfo = detail
            .compactMap {
                return $0.types.first
            }
            .compactMap {
                return $0.type.name
            }
            .compactMap {
                return PokemonKoreanType(rawValue: $0)?.displayName
            }
            .map {
                return "타입: \($0)"
            }
            .asDriver(onErrorDriveWith: .empty())
        
        let heightInfo = detail
            .map {
                let height = String(format: "%.1f m", Double($0.height) / 10)
                return "키: \(height)"
            }
            .asDriver(onErrorDriveWith: .empty())
        
        let weightInfo = detail
            .map {
                let weight = String(format: "%.1f kg", Double($0.weight) / 10)
                return "몸무게: \(weight)"
            }
            .asDriver(onErrorDriveWith: .empty())
        
        return Output(imageInfo: imageInfo,
                      idAndNameInfo: idAndNameInfo,
                      typeInfo: typeInfo,
                      heightInfo: heightInfo,
                      weightInfo: weightInfo,
                      error: errorRelay)
    }
    
    private func fetchDetailInfo(url: URL) -> Observable<DetailResponse> {
        return NetworkManager.shared.fetch(url: url).asObservable()
    }
}

extension DetailViewModel {
    struct Input {
        let initialFetch: Observable<Void>
    }
    
    struct Output {
        let imageInfo: Driver<URL>
        let idAndNameInfo: Driver<String>
        let typeInfo: Driver<String>
        let heightInfo: Driver<String>
        let weightInfo: Driver<String>
        let error: PublishRelay<Error>
    }
}
