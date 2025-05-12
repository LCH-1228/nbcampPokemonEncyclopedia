//
//  ImageCell.swift
//  nbcampPokemonEncyclopedia
//
//  Created by LCH on 5/10/25.
//

import UIKit
import SnapKit
import Kingfisher

class ImageCell: UICollectionViewCell {
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .backgroundWhite
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        ImageCache.default.memoryStorage.config.totalCostLimit = 20 * 1024 * 1024
        configureUI()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
    
    private func configureUI() {
        [
            imageView
        ].forEach{ contentView.addSubview($0) }
    }
    
    private func setConstraints() {
        imageView.snp.makeConstraints {
            $0.edges.equalTo(contentView.snp.edges)
        }
    }
    
    func configure(with data: ListResponse.Results) {
        let id = data.url.path()
            .replacingOccurrences(of: "/api/v2/pokemon", with: "")
            .replacingOccurrences(of: "/", with: "")
        guard let url = URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/\(id).png") else { return }
        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(
            with: url,
            options: [
                .processor(DownsamplingImageProcessor(size: imageView.bounds.size)),
                .scaleFactor(UIScreen.main.scale),
                .cacheOriginalImage,
                .diskCacheExpiration(.never),
                .keepCurrentImageWhileLoading
            ]
        )
    }
}
