//
//  DetailViewController.swift
//  nbcampPokemonEncyclopedia
//
//  Created by LCH on 5/10/25.
//

import UIKit
import SnapKit
import RxSwift

class DetailViewController: UIViewController {
    
    private var viewModel: DetailViewModel?
    
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
    
    private let textView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = .clear
        return textView
    }()
    
    init(url: URL) {
        viewModel = DetailViewModel(url: url)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        setConstraints()
        bind()
    }
    
    private func configureUI() {
        
        view.backgroundColor = .mainRed
        
        [
            imageView,
            textView
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
        
        textView.snp.makeConstraints {
            $0.height.equalTo(120)
            $0.horizontalEdges.equalTo(layoutView.snp.horizontalEdges)
            $0.top.equalTo(imageView.snp.bottom)
        }
        
        layoutView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.horizontalEdges.equalTo(view.snp.horizontalEdges).inset(24)
            $0.bottom.equalTo(textView.snp.bottom).offset(20)
        }
    }
    
    private func bind() {
        guard let viewModel else { return }
        viewModel.detailInfoSubject
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] info in
                guard let url = URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/\(info[0].id).png") else { return }
                DispatchQueue.main.async { [weak self] in
                    self?.imageView.kf.setImage(
                        with: url,
                        options: [.cacheOriginalImage]
                    )
                    self?.configureText(with: info[0])
                }
            }).disposed(by: disposeBag)
    }
    
    private func configureText(with input: DetailResponse) {
        
        guard let koreanType = PokemonKoreanType(rawValue: input.types[0].type.name)?.displayName else { return }
        
        let koreanName = PokemonKoreanName.getKoreanName(for: input.name)
        
        let height = String(format: "%.1f m", Double(input.height) / 10)
        let weight = String(format: "%.1f kg", Double(input.weight) / 10)
        let text = """
            No.\(input.id) \(koreanName)
            타입: \(koreanType)
            키: \(height)
            몸무게: \(weight)
            """
        
        let highlightedText = ["No.\(input.id) \(koreanName)"]
        
        let attributedString = NSMutableAttributedString(string: text)
        
        let normalFont = UIFont.systemFont(ofSize: 16, weight: .semibold)
        let hilightedFont = UIFont.systemFont(ofSize: 24, weight: .bold)
        
        let textStyle = NSMutableParagraphStyle()
        textStyle.alignment = .center
        textStyle.lineSpacing = 8
        
        let range = NSRange(location: 0, length: attributedString.length)
        attributedString.addAttribute(.font, value: normalFont, range: range)
        attributedString.addAttribute(.foregroundColor, value: UIColor.white, range: range)
        attributedString.addAttribute(.paragraphStyle, value: textStyle, range: range)
        
        for word in highlightedText {
            let range = (text as NSString).range(of: word)
            attributedString.addAttribute(.font, value: hilightedFont, range: range)
        }
        
        textView.attributedText = attributedString
    }
}
