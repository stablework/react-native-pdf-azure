//
//  AppDelegate.swift
//  DocSign
//
//  Created by MAC on 03/02/23.
//

import UIKit
//import Firebase
//import FirebaseAnalytics
//import FirebaseCrashlytics
//import FirebaseRemoteConfig
import AppTrackingTransparency
import Network
//import OneSignalFramework
import PusherSwift
import Toast

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    //MARK: - Properties
    var window: UIWindow?
    var recentBlob : [Blob] {
        get{
            if let data = UserDefaults.standard.data(forKey: AppConstants.UserDefaultKeys.myRecentBlob) {
                do {
                    // Create JSON Decoder
                    let decoder = JSONDecoder()
                    // Decode Note
                    let container = try decoder.decode([Blob].self, from: data)
                    return container
                } catch {
                    return []
                }
            }else{
                return []
            }
        }
        set{
            do {
                // Create JSON Encoder
                let encoder = JSONEncoder()
                // Encode Data
                let data = try encoder.encode(newValue)
                
                // Write/Set Data
                UserDefaults.standard.set(data, forKey: AppConstants.UserDefaultKeys.myRecentBlob)
            } catch {
                print("Unable to Encode data (\(error))")
            }
        }
    }
    var favouriteBlob : [Blob] {
        get{
            if let data = UserDefaults.standard.data(forKey: AppConstants.UserDefaultKeys.myFavouriteBlob) {
                do {
                    // Create JSON Decoder
                    let decoder = JSONDecoder()
                    // Decode Note
                    let container = try decoder.decode([Blob].self, from: data)
                    return container
                } catch {
                    return []
                }
            }else{
                return []
            }
        }
        set{
            do {
                // Create JSON Encoder
                let encoder = JSONEncoder()
                // Encode Data
                let data = try encoder.encode(newValue)
                
                // Write/Set Data
                UserDefaults.standard.set(data, forKey: AppConstants.UserDefaultKeys.myFavouriteBlob)
            } catch {
                print("Unable to Encode data (\(error))")
            }
        }
    }
//    var arrPDFinfo = [PDFinfo]()
    var container: [Container] {
        get{
            if let data = UserDefaults.standard.data(forKey: AppConstants.UserDefaultKeys.myContainer) {
                do {
                    // Create JSON Decoder
                    let decoder = JSONDecoder()
                    // Decode Note
                    let container = try decoder.decode([Container].self, from: data)
                    return container
                } catch {
                    return []
                }
            }else{
                return []
            }
        }
        set{
            do {
                // Create JSON Encoder
                let encoder = JSONEncoder()
                // Encode Data
                let data = try encoder.encode(newValue)
                
                // Write/Set Data
                UserDefaults.standard.set(data, forKey: AppConstants.UserDefaultKeys.myContainer)
            } catch {
                print("Unable to Encode data (\(error))")
            }
        }
    }
    var blobdetailModel : [String:EnumerationBlobResults] {
        get{
            if let data = UserDefaults.standard.data(forKey: AppConstants.UserDefaultKeys.myBlobDetail) {
                do {
                    // Create JSON Decoder
                    let decoder = JSONDecoder()
                    // Decode Note
                    let container = try decoder.decode([String:EnumerationBlobResults].self, from: data)
                    return container
                } catch {
                    return [:]
                }
            }else{
                return [:]
            }
        }
        set{
            do {
                // Create JSON Encoder
                let encoder = JSONEncoder()
                // Encode Data
                let data = try encoder.encode(newValue)
                
                // Write/Set Data
                UserDefaults.standard.set(data, forKey: AppConstants.UserDefaultKeys.myBlobDetail)
            } catch {
                print("Unable to Encode data (\(error))")
            }
        }
    }
    
    //For banner ads:
    var modelConfig = ClsRemoteConfig(fromDictionary: [:])
    var isLiveAds:Bool = true
    var isHideAllAds:Bool = false
    var fireData = clsFirebaseModel(fromDictionary: [:])
    let dispatchgroup = DispatchGroup()
    let monitor = NWPathMonitor()
    var internetIsAvailable = false
    
    //Pusher
    var pusher:Pusher? = nil
    var appKey:String = "048f35c4f35c4c9c67f7"
    var pusherSecret:String = "b044bfcb4c1e2a3524b6"
    var pusherChannel:String = "blob-notifications"
    var cluster:String = "us2"
    
//    app_id = "1933719"
//    key = "048f35c4f35c4c9c67f7"
//    secret = "b044bfcb4c1e2a3524b6"
//    cluster = "us2"
    //MARK: - AppDelegates
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        pusherSetup()
        checkAndFetchToken()
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
        self.setHomePage()
        dispatchgroup.notify(queue: .main) {
            self.setHomePage()
        }
        
        //sleep(2)
        fetchContainers()
        setNetworkMonitor()
        return true
    }
    
    func pusherSetup(){
        
        pusher = Pusher(key: appKey, options: PusherClientOptions(authMethod: .inline(secret: pusherSecret), host: .cluster(cluster)))
        pusher?.delegate = self
        pusher?.connect()
        
        let myChannel = pusher?.subscribe(channelName: "blob-notifications")
        _ = myChannel?.bind(eventName: "BlobCreated", eventCallback: { event in
            var message = "Received event: '\(event.eventName)'"
            if let channelName = event.channelName{
                message += "on channel '\(channelName)'"
            }
            if let userId = event.userId{
                message += "from user '\(userId)'"
            }
            if let datastr = event.data{
                message += "with data '\(datastr)'"
                let data = datastr.data(using: .utf8)!
                do {
                    if let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? Dictionary<String,Any>
                    {
                        if let message = jsonArray["message"] as? String{
//                            displayAlertWithMessage(message)
                            showToast(text: "Some files have been updated")
                        }
                       print(jsonArray)
                    } else {
                        print("bad json")
                    }
                } catch let error as NSError {
                    print(error)
                }
            }
            print("pusher :::::::======>>>>>>> ",message)
            self.fetchContainers()
        })
        _ = myChannel?.bind(eventName: "BlobDeleted", eventCallback: { event in
            var message = "Received event: '\(event.eventName)'"
            if let channelName = event.channelName{
                message += "on channel '\(channelName)'"
            }
            if let userId = event.userId{
                message += "from user '\(userId)'"
            }
            if let datastr = event.data{
                message += "with data '\(datastr)'"
                let data = datastr.data(using: .utf8)!
                do {
                    if let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? Dictionary<String,Any>
                    {
                        if let message = jsonArray["message"] as? String{
//                            displayAlertWithMessage(message)
                            showToast(text: "Some files have been updated")
                        }
                       print(jsonArray)
                    } else {
                        print("bad json")
                    }
                } catch let error as NSError {
                    print(error)
                }
            }
            print("pusher :::::::======>>>>>>> ",message)
            self.fetchContainers()
        })
        _ = myChannel?.bind(eventName: "DirectoryCreated", eventCallback: { event in
            var message = "Received event: '\(event.eventName)'"
            if let channelName = event.channelName{
                message += "on channel '\(channelName)'"
            }
            if let userId = event.userId{
                message += "from user '\(userId)'"
            }
            if let datastr = event.data{
                message += "with data '\(datastr)'"
                let data = datastr.data(using: .utf8)!
                do {
                    if let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? Dictionary<String,Any>
                    {
                        if let message = jsonArray["message"] as? String{
//                            displayAlertWithMessage(message)
                            showToast(text: "Some files have been updated")
                        }
                       print(jsonArray)
                    } else {
                        print("bad json")
                    }
                } catch let error as NSError {
                    print(error)
                }
            }
            print("pusher :::::::======>>>>>>> ",message)
            self.fetchContainers()
        })
        _ = myChannel?.bind(eventName: "DirectoryDeleted", eventCallback: { event in
            var message = "Received event: '\(event.eventName)'"
            if let channelName = event.channelName{
                message += "on channel '\(channelName)'"
            }
            if let userId = event.userId{
                message += "from user '\(userId)'"
            }
            if let datastr = event.data{
                message += "with data '\(datastr)'"
                let data = datastr.data(using: .utf8)!
                do {
                    if let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? Dictionary<String,Any>
                    {
                        if let message = jsonArray["message"] as? String{
//                            displayAlertWithMessage(message)
                            showToast(text: "Some files have been updated")
                        }
                       print(jsonArray)
                    } else {
                        print("bad json")
                    }
                } catch let error as NSError {
                    print(error)
                }
            }
            print("pusher :::::::======>>>>>>> ",message)
            self.fetchContainers()
        })
        
        let onMemberAdded = { (member:PusherPresenceChannelMember) in
            print(member)
        }
        let chan = pusher?.subscribe(channelName: "", onMemberAdded: onMemberAdded)
        chan?.trigger(eventName: "", data: ["test":"some value"])
    }
    
    func setNetworkMonitor(){
        // Start monitoring network path updates
        monitor.pathUpdateHandler = { path in
            self.internetIsAvailable = path.status == .satisfied
        }

        let queue = DispatchQueue(label: "NetworkMonitor")
        monitor.start(queue: queue)
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

// API Call
extension AppDelegate{
    private func fetchContainers() {
        let storageAccountName = storageAccountName
//        showIndicator()
        ApiService.shared.listStorageContents(storageAccountName: storageAccountName) { result in
//            hideIndicator()
            switch result {
            case .success(let containers):
                print("Fetched containers: \(containers)")
                
                // Update the otherFolder array and reload the table view
                DispatchQueue.main.async {
                    self.container = containers.filter({!$0.name.hasPrefix("azure-")})
                    DispatchQueue.global(qos: .background).async {
                        for container in self.container {
                            self.fetchBlogs(containerName:container.name, isNotify: false)
                        }
                    }
                    
                    NotificationCenter.default.post(name: NSNotification.Name("setContainer"), object: nil)
                }
                
            case .failure(let error):
                print("Error fetching containers: \(error.localizedDescription)")
            }
        }
    }
    
    // Load folders and PDFs from the specified path
  
    func fetchBlogs(containerName:String, isNotify:Bool = true) {
        let storageAccountName = storageAccountName
//        showIndicator()
        ApiService.shared.listStorageBlobsContent(storageAccountName: storageAccountName, containerName: containerName) { result in
            print("Fetched \(containerName) blob: \(result)")
            
            DispatchQueue.main.async {
//                hideIndicator()
                switch result {
                case .success(let blobdetailModel):
                    DispatchQueue.main.async {
                        self.blobdetailModel[containerName] = blobdetailModel
//                        if isNotify{
                            NotificationCenter.default.post(name: NSNotification.Name("setContainer"), object: nil)
//                        }
                    }
                    
                case .failure(let error):
                    print("Error fetching containers: \(error.localizedDescription)")
                }
            }
        }
    }
}

extension AppDelegate:PusherDelegate{
    func changedConnectionState(from old: ConnectionState, to new: ConnectionState) {
        print("old: \(old.stringValue()), new: \(new.stringValue())")
    }
    
    func subscribedToChannel(name: String) {
        print("Subscribed to \(name)")
    }
    func debugLog(message: String) {
        print(message)
    }
    func receivedError(error: PusherError) {
        if let code = error.code{
            print("Recived error: (\(code)) \(error.message)")
        }else{
            print("Recived error: \(error.message)")
        }
    }
}

func showToast(text:String){
    let scene = UIApplication.shared.connectedScenes.first
    if var topController = UIApplication.shared.keyWindow?.rootViewController {
        while let presentedViewController = topController.presentedViewController {
            topController = presentedViewController
        }
        
        topController.view.makeToast(text,duration: 4, position: .top)
        // topController should now be your topmost view controller
    }
}
