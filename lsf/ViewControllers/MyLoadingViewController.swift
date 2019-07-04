//
//  MyLoadingViewController.swift
//  lsf
//
//  Created by Mitchell Gerber on 7/4/19.
//  Copyright © 2019 Mitchell Gerber. All rights reserved.
//

import UIKit
import SnapKit

class MyLoadingViewController: UIViewController {
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        self.modalTransitionStyle = .crossDissolve
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1)
        
        let loadingIndicator = UIActivityIndicatorView()
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorView.Style.gray
        loadingIndicator.startAnimating();
        loadingIndicator.color = Config.colors.white
        
        let container = UIView()
        container.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        container.layer.cornerRadius = 5
        self.view.addSubview(container)
        container.addSubview(loadingIndicator)
        
        container.snp.makeConstraints { make in
            make.width.height.equalTo(60)
            make.center.equalToSuperview()
        }
        
        loadingIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}
