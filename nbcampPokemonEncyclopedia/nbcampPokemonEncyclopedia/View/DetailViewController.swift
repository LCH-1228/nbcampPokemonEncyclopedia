//
//  DetailViewController.swift
//  nbcampPokemonEncyclopedia
//
//  Created by LCH on 5/10/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import Kingfisher

class DetailViewController: UIViewController {
    
    private var viewModel: DetailViewModel
    
    private let disposeBag = DisposeBag()
    
    private let layoutView: UIView = {
        let view = UIView()
        view.backgroundColor = .black.withAlphaComponent(0.4)
        view.layer.cornerRadius = 10
        return view
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 24, weight: .bold)
        return label
    }()
    
    private let typeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        return label
    }()
    
    private let heightLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        return label
    }()
    
    private let weightLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        return label
    }()
    
    private lazy var labelStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            nameLabel,
            typeLabel,
            heightLabel,
            weightLabel
        ])
        stackView.spacing = 8
        stackView.alignment = .center
        stackView.axis = .vertical
        return stackView
    }()
    
    init(viewModel: DetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.isNavigationBarHidden = false
        
        configureUI()
        setConstraints()
        bind()
    }
    
    private func configureUI() {
        
        view.backgroundColor = .mainRed
        
        [
            imageView,
            labelStackView
        ].forEach{ layoutView.addSubview($0) }
        
        [
            layoutView
        ].forEach{ view.addSubview($0) }
    }
    
    private func setConstraints() {
        
        imageView.snp.makeConstraints {
            $0.size.equalTo(200)
            $0.top.equalTo(layoutView.snp.top).inset(20)
            $0.centerX.equalTo(layoutView.snp.centerX)
        }
        
        labelStackView.snp.makeConstraints {
            $0.horizontalEdges.equalTo(layoutView.snp.horizontalEdges)
            $0.top.equalTo(imageView.snp.bottom).offset(12)
        }
        
        layoutView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.horizontalEdges.equalTo(view.snp.horizontalEdges).inset(40)
            $0.bottom.equalTo(labelStackView.snp.bottom).offset(20)
        }
    }
    
    private func bind() {
        let input = bindInput()
        bindOutput(with: input)
        BindUI(with: input)
    }
    
    // MARK: BindInput
    private func bindInput() -> DetailViewModel.Input {
        let input = DetailViewModel.Input(
            initialFetch: Observable.just(())
        )
        return input
    }
    
    // MARK: BindOutput
    private func bindOutput(with input: DetailViewModel.Input) {
        let output = viewModel.transform(input)
        
        output.imageInfo
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] url in
                guard let self else { return }
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
            }).disposed(by: disposeBag)
        
        output.error
            .subscribe(onNext: { [weak self] error in
                self?.showAlert(error: error)
            }).disposed(by: disposeBag)
    }
    
    // MARK: BindUI
    private func BindUI(with input: DetailViewModel.Input) {
        let output = viewModel.transform(input)
        
        output.idAndNameInfo
            .asDriver(onErrorDriveWith: .empty())
            .drive(nameLabel.rx.text)
            .disposed(by: disposeBag)
        
        output.typeInfo
            .asDriver(onErrorDriveWith: .empty())
            .drive(typeLabel.rx.text)
            .disposed(by: disposeBag)
        
        output.heightInfo
            .asDriver(onErrorDriveWith: .empty())
            .drive(heightLabel.rx.text)
            .disposed(by: disposeBag)
        
        output.weightInfo
            .asDriver(onErrorDriveWith: .empty())
            .drive(weightLabel.rx.text)
            .disposed(by: disposeBag)
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
