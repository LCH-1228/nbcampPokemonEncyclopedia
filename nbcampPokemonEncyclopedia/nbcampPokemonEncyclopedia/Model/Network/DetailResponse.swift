//
//  DetailResponse.swift
//  nbcampPokemonEncyclopedia
//
//  Created by LCH on 5/10/25.
//
import Foundation

struct DetailResponse: Decodable {
    let height: Int
    let id: Int
    let name: String
    let types: [Types]
    let weight: Int
}

extension DetailResponse {
    
    struct Types: Decodable {
        let slot: Int
        let type: TypeReulst
    }
}

extension DetailResponse.Types {
    
    struct TypeReulst: Decodable {
        let name: String
    }
}
