//
//  RegulationsController.swift
//  Fahrschule
//
//  Created on 02.07.15.
//  Copyright (c) 2015. All rights reserved.
//

import UIKit

class RegulationsController: UIViewController {

//    MARK: - Types
//    MARK: Outlets
    @IBOutlet weak var webView: UIWebView!
    
//    MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        let url = NSBundle.mainBundle().URLForResource("StVO", withExtension: "pdf")!
        let request = NSURLRequest(URL: url)
        webView.loadRequest(request)
        
    }


}
