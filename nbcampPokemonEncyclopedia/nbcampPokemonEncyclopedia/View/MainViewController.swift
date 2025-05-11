//
//  MainViewController.swift
//  nbcampPokemonEncyclopedia
//
//  Created by LCH on 5/9/25.
//

import UIKit
import SnapKit
import RxSwift

class MainViewController: UIViewController {
    
    private let dispoaseBag = DisposeBag()
    
    private let viewModel = MainViewModel()
    
    private var imageList = [ListResponse.Results]()
    
    private lazy var collectionView: UICollectionView = {
        
        let layout: UICollectionViewCompositionalLayout = {
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1/3),
                heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalWidth(1/3))
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: groupSize,
                subitems: [item])
            group.interItemSpacing = .fixed(8)
            group.contentInsets = .init(top: 0, leading: 8, bottom: 0, trailing: 8)
            
            let headerSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1/5))
            let header = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top)
            
            let section = NSCollectionLayoutSection(group: group)
            section.boundarySupplementaryItems = [header]
            section.interGroupSpacing = 8
            section.contentInsets = .init(top: 8, leading: 0, bottom: 8, trailing: 0)
            
            return UICollectionViewCompositionalLayout(section: section)
        }()
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(ImageCell.self,
                                forCellWithReuseIdentifier: String(describing: ImageCell.self))
        collectionView.register(SectionHeaderView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: String(describing: SectionHeaderView.self))
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.backgroundColor = .darkRed
        
        return collectionView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidload")
        
        configureUI()
        setConstraints()
        bind()
    }
    
    private func configureUI() {
        view.backgroundColor = .mainRed
        
        [
            collectionView
        ].forEach { view.addSubview($0) }
    }
    
    private func setConstraints() {
        
        collectionView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide.snp.edges)
        }
    }
    
    private func bind() {
        viewModel.imageListRelay
            .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] list in
                self?.imageList.append(contentsOf: list)
                self?.collectionView.reloadData()
            }).disposed(by: dispoaseBag)
        
        viewModel.errorsubject
            .subscribe(onNext: { [weak self] error in
                self?.showAlert(error: error)
            }).disposed(by: dispoaseBag)
    }
    
    private func showAlert(error: Error) {
        let alert = UIAlertController(title: "경고",
                                      message: error.localizedDescription,
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { action in
        }))
        
        self.present(alert, animated: true)
    }
}

extension MainViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let url = imageList[indexPath.row].url
        
        let detailView = DetailViewController(url: url)
        
        navigationController?.pushViewController(detailView, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if indexPath.row == imageList.count - 1 {
            viewModel.fetchImageList()
        }
    }
}

extension MainViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ImageCell.self), for: indexPath) as? ImageCell else { return .init() }
        
        cell.configure(with: imageList[indexPath.row])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
            return .init()
        }
        
        guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                               withReuseIdentifier: String(describing: SectionHeaderView.self),
                                                                               for: indexPath) as? SectionHeaderView else {
            return .init()
        }
        
        headerView.configure(with: .pokemonBall)
        
        return headerView
    }
}
