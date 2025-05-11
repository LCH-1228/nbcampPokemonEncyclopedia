//
//  ListResponse.swift
//  nbcampPokemonEncyclopedia
//
//  Created by LCH on 5/10/25.
//
import Foundation

struct ListResponse: Decodable {
    let count: Int
    let next: URL?
    let previous: URL?
    let results: [Results]
}

extension ListResponse {
    
    struct Results: Decodable {
        let name: String
        let url : URL
    }
}
