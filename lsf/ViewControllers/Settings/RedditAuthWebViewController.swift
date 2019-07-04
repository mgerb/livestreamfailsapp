//
//  reddit-auth.swift
//  lsf
//
//  Created by Mitchell Gerber on 6/5/19.
//  Copyright © 2019 Mitchell Gerber. All rights reserved.
//

import UIKit
import WebKit

class RedditAuthWebViewController: UIViewController, WKNavigationDelegate, WKUIDelegate {
    
    var loginSuccess: (() -> Void)?
    
    lazy var webview: WKWebView = {
        let view = WKWebView(frame: self.view.frame)
        if let url = URL(string: RedditService.shared.redditAuth.user_oauth_url()) {
            view.load(URLRequest(url: url))
        }
        view.navigationDelegate = self
        view.uiDelegate = self
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(self.webview)
        self.webview.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = webView.url, url.absoluteString.hasPrefix(RedditService.shared.redditAuth.redirect_uri) {
            let urlComponents = URLComponents(string: url.absoluteString)
            if let code = urlComponents?.queryItems?.first(where: { $0.name == "code" })?.value {
                RedditService.shared.login(code: code) { success in
                    if success {
                        self.navigationController?.popViewController(animated: true)
                        self.loginSuccess?()
                    }
                }
            }
        }
        
        decisionHandler(.allow)
    }
    
}
