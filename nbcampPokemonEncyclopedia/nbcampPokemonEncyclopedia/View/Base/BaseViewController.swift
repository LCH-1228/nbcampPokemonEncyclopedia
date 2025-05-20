//
//  BaseViewController.swift
//  nbcampPokemonEncyclopedia
//
//  Created by LCH on 5/19/25.
//

import UIKit
import RxSwift

class BaseViewController: UIViewController {
    
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        setConstraints()
        bind()
    }
    
    func configureUI() {
        
    }
    
    func setConstraints() {
        
    }
    
    func bind() {
        
    }
}
