//
//  CollectionViewData.swift
//  nbcampPokemonEncyclopedia
//
//  Created by LCH on 5/13/25.
//

import UIKit
import RxDataSources

struct CollectionViewData {
    let name: String
    let url: URL
}

struct SectionOfCustomData {
    var header: UIImage
    var items: [CollectionViewData]
}

extension SectionOfCustomData: SectionModelType {
    typealias Item = CollectionViewData
    
    init(original: SectionOfCustomData, items: [CollectionViewData]) {
        self = original
        self.items = items
    }
}
