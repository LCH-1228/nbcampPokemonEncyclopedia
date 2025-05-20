//
//  MainViewController.swift
//  nbcampPokemonEncyclopedia
//
//  Created by LCH on 5/9/25.
//

import UIKit
import SnapKit
import RxSwift
import RxDataSources

final class MainViewController: BaseViewController {
    
    private let viewModel: MainViewModel
    
    lazy var collectionView = UICollectionView(frame: .zero,
                                               collectionViewLayout: makeCollectionViewLayout())
    
    init(viewModel: MainViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true
    }
    
    override func configureUI() {
        super.configureUI()
        
        view.backgroundColor = .mainRed
        [
            collectionView
        ].forEach { view.addSubview($0) }
    }
    
    override func setConstraints() {
        super.setConstraints()
        
        collectionView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide.snp.edges)
        }
    }
    
    override func bind() {
        super.bind()
        
        let input = bindInput()
        let output = viewModel.transform(input)
        bindOutput(with: output)
        bindCollectionView(with: output)
    }
    
    // MARK: - BindInput
    private func bindInput() -> MainViewModel.Input {
        let input = MainViewModel.Input(
            initialFetch: Observable.just(()),
            scrollFetch: collectionView.rx.contentOffset
                .filter { [weak self ] currentLocation in
                    guard let self else { return false }
                    let contentHeight = collectionView.contentSize.height
                    let frameHeight = collectionView.frame.height
                    guard contentHeight != 0 && frameHeight != 0 else { return false }
                    let endLocation =  contentHeight - frameHeight
                    let isEnd = currentLocation.y > endLocation ? true : false
                    return isEnd
                }
                .map { _ in return Void() }
                .throttle(.milliseconds(1500), scheduler: MainScheduler.instance)
        )
        
        return input
    }
    
    // MARK: BindOutput
    private func bindOutput(with output: MainViewModel.Output) {
        
        output.error
            .subscribe(onNext: { [weak self] error in
                self?.showAlert(error: error)
            }).disposed(by: disposeBag)
    }
    
    // MARK: BindUI
    private func bindCollectionView(with output: MainViewModel.Output) {
        
        output.collectionViewData
            .asDriver(onErrorDriveWith: .empty())
            .drive(collectionView.rx.items(dataSource: makeCollectionViewDataSource()))
            .disposed(by: disposeBag)
        
        collectionView.rx.itemSelected
            .withLatestFrom(output.collectionViewData) { indexPath, data in
                data[0].items[indexPath.row]
            }
            .subscribe(onNext: { [weak self] selectedData in
                guard let self else { return }
                let detailViewMode = DetailViewModel(url: selectedData.url)
                let detailView = DetailViewController(viewModel: detailViewMode)
                navigationController?.pushViewController(detailView, animated: true)
            }).disposed(by: disposeBag)
    }
    
    private func setCollectionView() {
        collectionView.register(ListCell.self,
                                forCellWithReuseIdentifier: String(describing: ListCell.self))
        collectionView.register(SectionHeaderView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: String(describing: SectionHeaderView.self))
        
        collectionView.backgroundColor = .darkRed
    }
    
    private func makeCollectionViewLayout() -> UICollectionViewCompositionalLayout {
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
    }
    
    private func makeCollectionViewDataSource() -> RxCollectionViewSectionedReloadDataSource<SectionOfCustomData> {
        let dataSource = RxCollectionViewSectionedReloadDataSource<SectionOfCustomData> {
            dataSource, collectionView, indexPath, item in
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: String(describing: ListCell.self),
                for: indexPath) as? ListCell else { return .init() }
            
            cell.configure(with: item)
            return cell
            
        } configureSupplementaryView: { dataSource, collectionView, kind, indexPath in
            
            guard let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: String(describing: SectionHeaderView.self),
                for: indexPath) as? SectionHeaderView else { return .init() }
            
            header.configure(with: .pokemonBall)
            return header
            
        }
        return dataSource
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
