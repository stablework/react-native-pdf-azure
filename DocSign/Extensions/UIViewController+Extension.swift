//
//  UIViewController+Extension.swift
//  Doctor
//
//  Created by Jaydeep on 02/07/19.
//  Copyright © 2019 Jaydeep. All rights reserved.
//

import Foundation
import UIKit


extension UIViewController {
    func setupNavigationBarWithMenuButton(_ name:String){
        
        //self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.navigationController?.isNavigationBarHidden = false
        
        let lblTitle = UILabel()
        lblTitle.text = name
        lblTitle.textColor = UIColor.systemBlue
        
        lblTitle.font = UIFont(name: "Poppins-Medium", size: 26.0)
        self.navigationItem.titleView = lblTitle
        //self.navigationItem.largeTitleDisplayMode = true
    }
    
    @objc func dismissVC(){
        self.dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }

    @objc func btnMenuAction(){
    }
    
    @objc func btnRefreshAction(){
        
    }
    
    @objc func btnAddDeviceAction(){
        /*if arrDeviceList.count == 0 {
            openActionShitMenu()
        } else {
            openActionShitMenu()
            /*let alertController = UIAlertController(title: "Tasmotrol free version".localized(), message: "You are using the free Version \nwhich is limited to one device.\n\nDo you want to start your free 30 day Trial of Tasmotrol Pro?".localized(), preferredStyle: .alert)
            
            let deleteAction = UIAlertAction(title: "Start Pro trial".localized(), style: .destructive) { (action) in
                
            }
            
            let cancelAction = UIAlertAction(title: "Cancel".localized(), style: .default) { (action) in
                
            }
            
            alertController.addAction(cancelAction)
            alertController.addAction(deleteAction)
            
            self.present(alertController, animated: true, completion: nil)*/
        }*/
    }
    
    //MARK:- Change StatusBar Background Color

    func changeStatusBarBackgroundColor(color:UIColor) {
        if #available(iOS 13.0, *) {
            let app = UIApplication.shared
            let statusBarHeight: CGFloat = app.statusBarFrame.size.height
            
            let statusbarView = UIView()
            statusbarView.backgroundColor = color
            view.addSubview(statusbarView)
          
            statusbarView.translatesAutoresizingMaskIntoConstraints = false
            statusbarView.heightAnchor
                .constraint(equalToConstant: statusBarHeight).isActive = true
            statusbarView.widthAnchor
                .constraint(equalTo: view.widthAnchor, multiplier: 1.0).isActive = true
            statusbarView.topAnchor
                .constraint(equalTo: view.topAnchor).isActive = true
            statusbarView.centerXAnchor
                .constraint(equalTo: view.centerXAnchor).isActive = true
          
        } else {
            let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView
            statusBar?.backgroundColor = color
        }
    }
    
    //MARK:- Check Valid URL
    
    func canOpenURL(_ string: String?) -> Bool {
        guard let urlString = string,
            let url = URL(string: urlString)
            else { return false }

        if !UIApplication.shared.canOpenURL(url) { return false }

        let regEx = "((https|http)://)((\\w|-)+)(([.]|[/])((\\w|-)+))+"
        let predicate = NSPredicate(format:"SELF MATCHES %@", argumentArray:[regEx])
        return predicate.evaluate(with: string)
    }
    
   
    func addDoneButtonOnKeyboard(textfield : UITextField)
    {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x:0,y: 0,width: UIScreen.main.bounds.width,height: 50))
        doneToolbar.barStyle = UIBarStyle.default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem:  UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(doneButtonAction))
        done.tintColor = UIColor(red: 35/255, green: 141/255, blue: 250/255, alpha: 1.0)
        
        let items = NSMutableArray()
        items.add(flexSpace)
        items.add(done)
        
        doneToolbar.items = items as? [UIBarButtonItem]
        doneToolbar.sizeToFit()
        
        textfield.inputAccessoryView = doneToolbar
        
    }
    
    @objc func doneButtonAction()
    {
        self.view.endEditing(true)
    }
    
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
}




extension UIApplication {
    class func isFirstClickOnDeviceSearch() -> Bool {
        if !UserDefaults.standard.bool(forKey: "device_search") {
            UserDefaults.standard.set(true, forKey: "device_search")
            UserDefaults.standard.synchronize()
            return true
        }
        return false
    }
}

extension Date {
    var millisecondsSince1970:Int64 {
        Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    
    init(milliseconds:Int64) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }
}

