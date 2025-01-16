
//
//  AIUtilsManager.swift
//  Swift3CodeStructure
//
//  Created by Ravi Alagiya on 25/11/2016.
//  Copyright © 2016 Ravi Alagiya. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation


// MARK: - INTERNET CHECK
func SHOW_INTERNET_ALERT(){
    displayAlertWithTitle(APP_NAME, andMessage: "Please turn on data to use the \(APP_NAME) App.", buttons: ["Try Again"]) { (index) in
    }
}

// MARK: - ALERT
func displayAlertWithMessage(_ message:String) -> Void {
    displayAlertWithTitle(APP_NAME, andMessage: message, buttons: ["Dismiss"], completion: nil)
}


func displayAlertWithMessageFromVC(_ vc:UIViewController, message:String, buttons:[String], completion:((_ index:Int) -> Void)!) -> Void {
    
    let alertController = UIAlertController(title: APP_NAME, message: message, preferredStyle: .alert)
    
    for index in 0..<buttons.count	{
        
        alertController.setValue(NSAttributedString(string: APP_NAME, attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 16),NSAttributedString.Key.foregroundColor : UIColor.black]), forKey: "attributedTitle")
        
        alertController.setValue(NSAttributedString(string: message, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14),NSAttributedString.Key.foregroundColor : UIColor.black]), forKey: "attributedMessage")
        
        
        let action = UIAlertAction(title: buttons[index], style: .default, handler: {
            (alert: UIAlertAction!) in
            if(completion != nil){
                completion(index)
            }
        })
        
        action.setValue(UIColor.black, forKey: "titleTextColor")
        alertController.addAction(action)
    }
    
    vc.present(alertController, animated: true, completion: nil)
}

func displayAlertWithTitle(_ title:String, andMessage message:String, buttons:[String], completion:((_ index:Int) -> Void)!) -> Void {
    
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    for index in 0..<buttons.count	{
        
        alertController.setValue(NSAttributedString(string: title, attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 16),NSAttributedString.Key.foregroundColor : UIColor.black]), forKey: "attributedTitle")
        
        alertController.setValue(NSAttributedString(string: message, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14),NSAttributedString.Key.foregroundColor : UIColor.black]), forKey: "attributedMessage")
        
        
        let action = UIAlertAction(title: buttons[index], style: .default, handler: {
            (alert: UIAlertAction!) in
            if(completion != nil){
                completion(index)
            }
        })
        
        action.setValue(UIColor.black, forKey: "titleTextColor")
        alertController.addAction(action)
    }
    UIApplication.shared.delegate!.window!?.rootViewController!.present(alertController, animated: true, completion:nil)
}


func displayAlertWithTitle(_ vc:UIViewController, title:String, andMessage message:String, buttons:[String], completion:((_ index:Int) -> Void)!) -> Void {
    
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    for index in 0..<buttons.count	{
        
        alertController.setValue(NSAttributedString(string: title, attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 16),NSAttributedString.Key.foregroundColor : UIColor.black]), forKey: "attributedTitle")
        
        alertController.setValue(NSAttributedString(string: message, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14),NSAttributedString.Key.foregroundColor : UIColor.black]), forKey: "attributedMessage")
        
        
        let action = UIAlertAction(title: buttons[index], style: .default, handler: {
            (alert: UIAlertAction!) in
            if(completion != nil){
                completion(index)
            }
        })
        
        action.setValue(UIColor.black, forKey: "titleTextColor")
        alertController.addAction(action)
    }
    vc.present(alertController, animated: true, completion: nil)
}



// MARK: - Custom object Functions Save User Default
func setCustomObject(value:AnyObject,key:String)
{
    let data = NSKeyedArchiver.archivedData(withRootObject: value)
    UserDefaults.standard.set(data, forKey: key)
    UserDefaults.standard.synchronize()
}

func getCustomObject(key:String) -> Any?
{
    let data = UserDefaults.standard.object(forKey: key) as? NSData
    if data == nil
    {
        return nil
    }
    let value = NSKeyedUnarchiver.unarchiveObject(with: data! as Data)
    return value
}

func removeObjectForKey(_ objectKey: String) {
    
    let defaults = UserDefaults.standard
    defaults.removeObject(forKey: objectKey)
    defaults.synchronize()
}

func removeAllKeyFromDefault(){
    UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
}

func setImageObject(value:UIImage,key:String)
{
    UserDefaults.standard.set(value.pngData(), forKey: key)
    UserDefaults.standard.synchronize()
}
func getImageObject(key:String) -> UIImage
{
    let data = UserDefaults.standard.object(forKey: key) as? NSData
    if data == nil
    {
        let img = UIImage.init()
        img.accessibilityIdentifier = "nil"
        return img
    }
    return UIImage.init(data: data! as Data)!
}

// MARK: - String Functions
func setString(value:String,key:String)
{
    UserDefaults.standard.set(value, forKey: key)
    UserDefaults.standard.synchronize()
}

func getString(key:String) -> String?
{
    let value : String? = UserDefaults.standard.object(forKey: key) as? String
    return value
}

// MARK: - Int Functions
func setInt(value:Int,key:String)
{
    UserDefaults.standard.set(value, forKey: key)
    UserDefaults.standard.synchronize()
}

func getInt(key:String) -> Int?
{
    let value : Int? = UserDefaults.standard.object(forKey: key) as? Int
    return value
}

// MARK: - Float Functions
func setFloat(value:Float,key:String)
{
    UserDefaults.standard.set(value, forKey: key)
    UserDefaults.standard.synchronize()
}

func getFloat(key:String) -> Float?
{
    let value : Float? = UserDefaults.standard.object(forKey: key) as? Float
    return value
}

// MARK: - Double Functions
func setDouble(value:Double,key:String)
{
    UserDefaults.standard.set(value, forKey: key)
    UserDefaults.standard.synchronize()
}

func getDouble(key:String) -> Double?
{
    let value : Double? = UserDefaults.standard.object(forKey: key) as? Double
    return value
}


// MARK: - Date Functions
func setDate(value:Date,key:String)
{
    UserDefaults.standard.set(value, forKey: key)
    UserDefaults.standard.synchronize()
}

func getDate(key:String) -> Date?
{
    let value : Date? = UserDefaults.standard.object(forKey: key) as? Date
    return value
}
