//
//  AppDelegate.swift
//  DocSign
//
//  Created by MAC on 03/02/23.
//

import UIKit
import Firebase
import FirebaseAnalytics
import FirebaseCrashlytics
import FirebaseRemoteConfig
import AppTrackingTransparency
import OneSignalFramework

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    //MARK: - Properties
    var window: UIWindow?
    var arrPDFinfo = [PDFinfo]()
    
    //For banner ads:
    var modelConfig = ClsRemoteConfig(fromDictionary: [:])
    var isLiveAds:Bool = true
    var isHideAllAds:Bool = false
    var fireData = clsFirebaseModel(fromDictionary: [:])
    let dispatchgroup = DispatchGroup()
    //MARK: - AppDelegates
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        checkAndFetchToken()
        FirebaseApp.configure()
      
        
        OneSignal.Debug.setLogLevel(.LL_VERBOSE)
          // OneSignal initialization
          OneSignal.initialize(ONE_SIGNAL_APP_ID, withLaunchOptions: launchOptions)
        
        if (launchOptions != nil)
        {
            let dictionary:NSDictionary = launchOptions?[UIApplication.LaunchOptionsKey.remoteNotification] as! NSDictionary
            if let info = dictionary["custom"] as? Dictionary<String, AnyObject>,let stringUrl = info["u"] as? String{
                 print(dictionary)
                 guard let url = URL(string: stringUrl) else { return true}
                 UIApplication.shared.open(url)
             }
        }
        dispatchgroup.enter()
        getRemoteConfig()
        dispatchgroup.notify(queue: .main) {
            self.getPdfInfoUserDefault()
//            if let isShowIntroScreen = getInt(key: ISSHOWINTROSCREEN), isShowIntroScreen == 1{
                self.setHomePage()
//            }
            
//            else{
//                self.setAppIntro()
//            }
        }
       
        //sleep(2)
        return true
    }
    
    func getPdfInfoUserDefault(){
        if let data = UserDefaults.standard.data(forKey: AppConstants.UserDefaultKeys.myDictionary) {
            do {
                // Create JSON Decoder
                let decoder = JSONDecoder()
                // Decode Note
                arrPDFinfo = try decoder.decode([PDFinfo].self, from: data)
            } catch {
                print("Unable to Decode data (\(error))")
            }
            print(data)
            print(arrPDFinfo)
        }
    }
    
    func setPdfInfoUserDefault(){
        do {
            // Create JSON Encoder
            let encoder = JSONEncoder()
            // Encode Data
            let data = try encoder.encode(self.arrPDFinfo)
            
            // Write/Set Data
            UserDefaults.standard.set(data, forKey: AppConstants.UserDefaultKeys.myDictionary)
        } catch {
            print("Unable to Encode data (\(error))")
        }
    }
    
    //MARK: - Register Notification Method
    func registerNotification(){
        let application = UIApplication.shared
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in
                    //self.setUpnotification()
                    //self.requestPermission()
                })
        } else {
            let settings: UIUserNotificationSettings =
            UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
            //self.setUpnotification()
            //self.requestPermission()
        }
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    private func checkAndFetchToken() {
            // Check if the token is valid
            if !ApiService.shared.isTokenValid() {
                let tenantID = tenantID
                let clientID = clientID
                let clientSecret = clientSecret
                
                ApiService.shared.getStorageBearerToken(tenantID: tenantID, clientID: clientID, clientSecret: clientSecret) { result in
                    switch result {
                    case .success:
                        print("Token refreshed successfully")
                    case .failure(let error):
                        print("Failed to refresh token: \(error.localizedDescription)")
                    }
                }
            } else {
                print("Token is still valid, no need to refresh")
            }
        }
    
    

    
   
}

//MARK: - Get Remote Config, Check App version and, Home screen setup method
extension AppDelegate{
    func getRemoteConfig(){
        showIndicator()
        let remoteConfig = RemoteConfig.remoteConfig()
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        remoteConfig.configSettings = settings
        
        remoteConfig.fetch { (status, error) -> Void in
            if status == .success {
                remoteConfig.activate { changed, error in
                    if let dictConfig = RemoteConfig.remoteConfig()
                        .configValue(forKey: "config_ios").jsonValue as? [String : Any] {
                        self.modelConfig = ClsRemoteConfig(fromDictionary: dictConfig)
                        if self.isHideAllAds {
                            self.modelConfig.isShowiOSAds = false
                        }

                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//                            self.requestPermission()
                            self.dispatchgroup.leave()
                        }
                    }else{
                        hideIndicator()
                        displayAlertWithTitle(APP_NAME, andMessage: INTERNET_ERROR, buttons: ["Try Again"]) { _ in
                            self.getRemoteConfig()
                            self.dispatchgroup.leave()
                        }
                    }
                }
            }else{
                hideIndicator()
                displayAlertWithTitle(APP_NAME, andMessage: INTERNET_ERROR, buttons: ["Try Again"]) { _ in
                    self.getRemoteConfig()
                    self.dispatchgroup.leave()
                }
            }
        }
    }
    
    func setAppIntro(){
        DispatchQueue.main.async {
            let mainStoryboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let home = mainStoryboard.instantiateViewController(withIdentifier: "AppIntroViewController") as! AppIntroViewController
            let navigation = UINavigationController(rootViewController: home)
            navigation.isNavigationBarHidden = true
            self.window?.rootViewController = navigation
            self.window?.makeKeyAndVisible()
        }
    }
    func setHomePage() {
        setInt(value: 1, key: ISSHOWINTROSCREEN)
        DispatchQueue.main.async {
            let mainStoryboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = mainStoryboard.instantiateViewController(withIdentifier: "TabBarViewController") as! TabBarViewController
            let navigationController = UINavigationController(rootViewController: vc)
            navigationController.navigationBar.isHidden = true
            appDelegate.window?.rootViewController = navigationController
            appDelegate.window?.makeKeyAndVisible()
        }
    }
    func checkAppVersionUpdated()  {
        
        let serverString = self.modelConfig.iosUpdateVersion.replacingOccurrences(of: ".", with: "")
        let appString = VERSION_NUMBER.replacingOccurrences(of: ".", with: "")
        let serverVersion = Int(serverString)
        let appVersion = Int(appString)
        
        if(appVersion! < serverVersion!){
            displayAlertWithTitle(APP_NAME, andMessage: self.modelConfig.iosUpdateDescription, buttons: ["Update"]) { (index) in
                if let url = URL(string: "itms-apps://itunes.apple.com/app/id6443735870"),
                   UIApplication.shared.canOpenURL(url){
                    UIApplication.shared.open(url)
                }
            }
        }
    }
}

//MARK: - Google Ads
extension AppDelegate{
    
}

//MARK: - User Notification Center Delegate Method
@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        //let userInfo = notification.request.content.userInfo
        completionHandler([.banner, .badge, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo

        let temp : NSDictionary = userInfo as NSDictionary
        if let info = temp["custom"] as? Dictionary<String, AnyObject>,let stringUrl = info["u"] as? String{
             print(temp)
             guard let url = URL(string: stringUrl) else { return }
             UIApplication.shared.open(url)
         }
        completionHandler()
    }
}
