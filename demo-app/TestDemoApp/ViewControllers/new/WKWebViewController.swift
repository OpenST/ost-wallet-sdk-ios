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

class WKWebViewController: OstBaseViewController  {
    let webView: WKWebView = {
        let view = WKWebView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let progressView: UIProgressView = {
        let view = UIProgressView(progressViewStyle: .default)
        view.progressTintColor = UIColor.color(22, 141, 193)
        view.trackTintColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
 
    
    //MARK: - Veriables
    var finishedLoading: Bool = false
    var myTimer: Timer? = nil
    
    var urlString: String = ""
    
    private var estimatedProgressObserver: NSKeyValueObservation?
    
    deinit {
       estimatedProgressObserver = nil
    }
    
    override func getNavBarTitle() -> String {
        return title ?? ""
    }
    
    override func addSubviews() {
        super.addSubviews()
        
        addSubview(webView)
        addSubview(progressView)
        
        guard let url = URL(string: urlString) else {return}
        webView.load(URLRequest(url: url))
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        
        setupEstimatedProgressObserver()
    }
    
    override func addLayoutConstraints() {
        super.addLayoutConstraints()
        
        progressView.topAlignWithParent(multiplier: 1, constant: 0)
        progressView.leftAlignWithParent(multiplier: 1, constant: 0)
        progressView.rightAlignWithParent(multiplier: 1, constant: 0)
        progressView.setFixedHeight(multiplier: 1, constant: 4)
        
        webView.topAlignWithParent()
        webView.applyBlockElementConstraints( horizontalMargin: 0)
        webView.bottomAlignWithParent()
        
    }
   
    private func setupEstimatedProgressObserver() {
        estimatedProgressObserver = webView.observe(\.estimatedProgress, options: [.new]) { [weak self] webView, _ in
            self?.progressView.progress = Float(webView.estimatedProgress)
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            progressView.progress = Float(webView.estimatedProgress)
        }
    }
}

extension WKWebViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
       
    }
    
    func webView(_: WKWebView, didStartProvisionalNavigation _: WKNavigation!) {
        if progressView.isHidden {
            progressView.isHidden = false
        }
        
        UIView.animate(withDuration: 0.3,  animations: {
            self.progressView.alpha = 1.0
        })
    }
    
    func webView(_: WKWebView, didFinish _: WKNavigation!) {
        UIView.animate(withDuration: 0.3, animations: {
                        self.progressView.alpha = 0.0
        }, completion: { isFinished in
            self.progressView.isHidden = isFinished
        })
    }
}
