/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation
import UIKit
import WebKit

class WKWebViewController: OstBaseViewController, WKNavigationDelegate {
    let webView: WKWebView = {
        let view = WKWebView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var urlString: String = ""
    
    override func getNavBarTitle() -> String {
        return urlString
    }
    
    override func addSubviews() {
        super.addSubviews()
        
        addSubview(webView)
        
        guard let url = URL(string: urlString) else {return}
        webView.load(URLRequest(url: url))
        webView.allowsBackForwardNavigationGestures = true
    }
    
    override func addLayoutConstraints() {
        super.addLayoutConstraints()
        
        webView.topAlignWithParent()
        webView.applyBlockElementConstraints( horizontalMargin: 0)
        webView.bottomAlignWithParent()
    }
}
