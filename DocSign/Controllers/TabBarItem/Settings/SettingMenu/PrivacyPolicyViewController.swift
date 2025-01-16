//
//  PrivacyPolicyViewController.swift
//  DocSign
//
//  Created by MAC on 20/02/23.
//

import UIKit
import WebKit

class PrivacyPolicyViewController: UIViewController {

    //MARK: - Outlets
    
    @IBOutlet var webView : WKWebView!
    @IBOutlet weak var btn_back: UIButton!
    @IBOutlet weak var lbl_title: UILabel!
    
    var text_title: String = ""
    
    //MARK: - View Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadWebviewWithURL(strURL: appDelegate.modelConfig.iOSPrivacyPolicy)
        
        lbl_title.text = text_title
    }
    
    //MARK: - Functions
    
    func loadWebviewWithURL(strURL:String){
        
        let myURL = URL(string:strURL)
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //pdfView.usePageViewController(true)
        
        if let tabbar = self.tabBarController as? TabBarViewController {
            tabbar.menuButton.isHidden = true
        }
    }
    
    //MARK: - IBActions
  
    @IBAction func btn_back(_ sender: Any) {
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.popViewController(animated: true)
        if let tabbar = self.tabBarController as? TabBarViewController {
            tabbar.menuButton.isHidden = false
        }
    }
}
