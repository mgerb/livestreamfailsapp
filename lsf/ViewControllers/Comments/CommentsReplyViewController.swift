//
//  CommentsReplyViewController.swift
//  lsf
//
//  Created by Mitchell Gerber on 7/1/19.
//  Copyright © 2019 Mitchell Gerber. All rights reserved.
//

import UIKit
import SnapKit
import Eureka

class CommentsReplyViewController: FormViewController {
    
    private let parentName: String
    private var parentComment: RedditComment?
    var commentBodyView: CommentsBodyView?
    var section: Section?;
    var textAreaRow: TextAreaRow?
    var success: ((_ newComment: RedditComment) -> Void)?
    
    required init(parentName: String, parentComment: RedditComment?) {
        self.parentName = parentName
        self.parentComment = parentComment
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(saveTapped))

        form +++ Section() { section in
                if let comment = self.parentComment {
                    var header = HeaderFooterView<CommentsBodyView>(.class)
                    header.height = {UITableViewAutomaticDimension}
                    header.onSetupView = { view, _ in
                            view.backgroundColor = Config.colors.white
                            view.setRedditComment(comment: comment)
                    }
                    section.header = header
                    self.section = section
                }
            }
            <<< TextAreaRow("textAreaRow") {
                $0.placeholder = "Reply..."
                self.textAreaRow = $0
            }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.textAreaRow?.cell.textView.becomeFirstResponder()
    }

    @objc func cancelTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func saveTapped() {

        self.textAreaRow?.cell.textView.resignFirstResponder()
        if let text = self.textAreaRow?.cell.textView.text {
            RedditService.shared.comment(name: self.parentName, text: text, completion: { success, newComment in
                if success, let c = newComment {
                    // depth isn't returned so we need to set based on parent - set to 0 if link is parent
                    newComment?.depth = (self.parentComment?.depth ?? -1) + 1
                    self.success?(c)
                    self.dismiss(animated: true, completion: nil)
                } else {
                    MyNavigation.shared.presentAlert(title: "Error", message: "Unable to leave a comment at this time.")
                }
            })
        }
    }
}
