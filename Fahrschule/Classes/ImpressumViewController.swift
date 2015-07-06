//
//  ImpressumViewController.swift
//  Fahrschule
//
//  Created on 06.07.15.
//  Copyright (c) 2015. All rights reserved.
//

import UIKit

class ImpressumViewController: UIViewController, UIWebViewDelegate {
    
//    MARK: - Type
//    MARK: Outlets
    @IBOutlet weak var webView: UIWebView!

//    MARK: - View Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        let url = NSBundle.mainBundle().URLForResource("impressum", withExtension: "html")!
        webView.loadRequest(NSURLRequest(URL: url))
        
    }
    
//    MARK: - Web View delegate
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        switch navigationType {
        case .LinkClicked:
            UIApplication.sharedApplication().openURL(request.URL!)
            return false
        default:
            return true
        }
    }
    

}
