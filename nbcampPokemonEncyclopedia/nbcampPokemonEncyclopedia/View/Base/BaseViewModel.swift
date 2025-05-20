//
//  BaseViewModel.swift
//  nbcampPokemonEncyclopedia
//
//  Created by LCH on 5/19/25.
//

import RxSwift

protocol BaseViewModel {
    associatedtype Input
    associatedtype Output
    
    func transform(_ input: Input) -> Output
}
