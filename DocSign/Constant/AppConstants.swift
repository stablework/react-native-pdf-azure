//
//  Created by Sam on 05/12/20.
//

import Foundation
import UIKit
//import SVProgressHUD

//MARK: Global Constant
let AppName = "PDF Editor"
let APP_VERSION: String = Bundle.main.releaseVersionNumber!
let APP_BUILD_NUMBER: String = Bundle.main.buildVersionNumber!
let APP_BUNDLE_IDENTIFIER = Bundle.main.bundleIdentifier
let APP_PLATFORM = "iOS"
let KStatusBarHeight = UIApplication.shared.statusBarFrame.height
let GOOGLE_PLACE_API_KEY = "AIzaSyBJs2f0TNNui_OcRHgVRTIsJAvGQ0EB7oA"

let tenantID = "e5ae3765-2175-4ca5-8c46-4d901c5b77b3"
let clientID = "2a1c2ff5-d96c-489f-8a16-f89a3b8ea713"
let clientSecret = "lPA8Q~Wi7292aKJ8mZcNJnE7im3qsV32TFGxSaPL"

let storageAccountName = "cookerpdfus2"//"pdfstoreaccount"


//MARK: - UIStoryboard

let kAlertTitle = "PDF Editor"

//MARK: - ERROR
let CUSTOM_ERROR_DOMAIN         = "CUSTOM_ERROR_DOMAIN"
let CUSTOM_ERROR_USER_INFO_KEY  = "CUSTOM_ERROR_USER_INFO_KEY"
let DEFAULT_ERROR               = "Something went wrong and try again."
let INTERNET_ERROR              = "Please check your internet connection and try again."

//let kAppName = LocalizationManager.shared.getLocalizedData(id: "app_name")

var VERSION_NUMBER = "1.1"
var SYSTEM_VERSION = "iOS 11"
var APP_SECRET = "boss#1407"
var USER_AGENT = "container1102"
var BUILD_NUMBER = "1.1"

let KFireBaseToken : String = "KFireBaseToken"
let kREFRESH_NOTIFICATION = "kREFRESH_NOTIFICATION"



func printFonts()
{
    let fontFamilyNames = UIFont.familyNames
    for familyName in fontFamilyNames {
        print("------------------------------")
        print("Font Family Name = [\(familyName)]")
        let names = UIFont.fontNames(forFamilyName: familyName)
        print("Font Names = [\(names)]")
    }
}

// MARK: - AppConstant
struct AppConstants {
    
    //placeholder image
    static let placeholderImage = UIImage(named: "placeholderImage") ?? UIImage()
    
    struct UserDefaultKeys {
        
        static let isUpgradePlan = "isUpgradePlan"
        
        
        static let myDictionary                     = "myDictionary"
        static let myContainer                      = "myContainer"
        static let myBlobDetail                     = "myBlobDetail"
        static let myRecentBlob                     = "myRecentBlob"
        static let myFavouriteBlob                  = "myFavouriteBlob"
        
        static let UserInfoModelKey                 = "UserInfoModelKey"
        static let BannerDetailModelKey             = "BannerDetailModelKey"
    }
    
    struct PushNotificationTypes {
        
        static let MESSAGE                           = "message"
        static let STATUS_UPDATE                     = "status_update"
        static let ORDER_PLACED                      = "order_placed"
        static let CHANGE_REQUEST                    = "change_request"
    }
    
    struct NotificationName {
        
        static let CHECK_VALIDATION                  = "checkValidation"
    }
    
    //AppIntroVC_images:
    struct AppIntro_images {
        static let img1                              = "quickOverview"
        static let img2                              = "readyForMore"
        static let img3                              = "whatPdfEditorOffers"
        static let img4                              = "getNotification"
    }
    
    //AppIntroVC_lblTitle:
    struct AppIntro_lblTitle {
        static let lbl_title1                        = "Quick Overview"
        static let lbl_title2                        = "Ready for more?"
        static let lbl_title3                        = "What PDF Editor offers?"
        static let lbl_title4                        = "Get Notified"
    }
    
    //AppIntroVC_description:
    struct AppIntro_lblDescription {
        static let lbl_description1                  = "Import images or scan paper files with your camera and convert them to PDFs - notes, receipts, invoices, forms, business cards, certificates, whiteboards, ID cards, etc., all supported."
        static let lbl_description2                  = "Instead of carrying around bundles of paperwork, enjoy a fast and reliable signing experience."
        static let lbl_description3                  = "Turn a picture into a PDF. Sign documents digitally. Print any document with AirPrint enabled printers or share anywhere!"
        static let lbl_description4                  = "Receive notifications when critical situations occur to stay on top of everything important."
    }
    
    //SettingVC_images:
    struct SettingsMenu_images {
        static let img1                              = UIImage(named: "ic_rateUsOnAppStore")!
        static let img2                              = UIImage(named: "ic_feedback")!
        static let img3                              = UIImage(named: "ic_privacyPolicy")!
        static let img4                              = UIImage(named: "ic_t&c")!
        static let img5                              = UIImage(named: "ic_inviteFriends")!
        static let img6                              = UIImage(named: "ic_moreApp")!
    }
    
    //SettingVC_lblTitle:
    struct SettingsMenu_lblTitle {
        static let lbl_title1                        = "Rate us on App Store"
        static let lbl_title2                        = "Send Feedback"
        static let lbl_title3                        = "Privacy Policy"
        static let lbl_title4                        = "Terms & Condition"
        static let lbl_title5                        = "Invite Friends"
        static let lbl_title6                        = "More Apps"
    }
}

//MARK: Device Constant
class DeviceConstant{
    
    enum UIUserInterfaceIdiom : Int
    {
        case Unspecified
        case Phone
        case Pad
    }
    
    struct ScreenSize
    {
        static let SCREEN_WIDTH         = UIScreen.main.bounds.size.width
        static let SCREEN_HEIGHT        = UIScreen.main.bounds.size.height
        static let SCREEN_MAX_LENGTH    = max(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
        static let SCREEN_MIN_LENGTH    = min(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
    }
    
    
    struct DeviceType {
        static let IS_IPHONE_4_OR_LESS  = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH < 568.0
        static let IS_IPHONE_5          = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 568.0
        static let IS_IPHONE_6          = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 667.0
        static let IS_IPHONE_6P         = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 736.0
        static let IS_IPHONE_X_OR_ABOVE          = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH >= 812.0
        static let IS_IPAD              = UIDevice.current.userInterfaceIdiom == .pad
        
    }
}
