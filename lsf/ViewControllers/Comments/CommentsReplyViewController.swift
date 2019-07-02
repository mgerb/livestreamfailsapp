//
//  CommentsReplyViewController.swift
//  lsf
//
//  Created by Mitchell Gerber on 7/1/19.
//  Copyright © 2019 Mitchell Gerber. All rights reserved.
//

import UIKit
import SnapKit

class CommentsReplyViewController: UIViewController {
    
    lazy var scrollView = UIScrollView()
    lazy var stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 10
        view.distribution = UIStackView.Distribution.fill
        return view
    }()
    
    lazy var commentBodyView = CommentsBodyView()
    lazy var textView: UITextView = {
        let view = UITextView()
        view.font = Config.regularFont
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(title: "Cancel", style: .done, target: self, action: #selector(self.cancel(sender:)))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "Save", style: .done, target: self, action: #selector(self.save(sender:)))
        self.view.backgroundColor = .white
        

        self.view.addSubview(self.scrollView)
        self.stackView.addArrangedSubview(self.commentBodyView)
        self.stackView.addArrangedSubview(self.textView)
        self.scrollView.addSubview(self.stackView)
        
        self.setupConstraints()
    }
    
    private func setupConstraints() {
//        self.scrollView.backgroundColor = .red
        self.stackView.backgroundColor = .blue
        self.scrollView.snp.makeConstraints { make in
//            make.edges.equalTo(self.view.safeAreaLayoutGuide)
            make.edges.equalToSuperview()
        }
        
        self.stackView.snp.makeConstraints { make in
            make.height.equalToSuperview()
            make.left.right.equalTo(self.view)
//            make.top.bottom.equalTo(self.scrollView)
//            make.left.right.equalTo(self.view)
        }
        
        self.textView.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(20)
        }
    }
    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        print("did layout")
//        print(self.commentBodyView.frame.height)
//        self.scrollView.contentSize = CGSize(width: self.scrollView.frame.width, height: self.view.frame.height + self.commentBodyView.frame.height)
//    }
    
    func setRedditComment(comment: RedditComment) {
        self.commentBodyView.setRedditComment(comment: comment)
        
    }
    
    @objc func cancel(sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func save(sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
}
