//
//    ClsRemoteConfig.swift
//    Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation


class ClsRemoteConfig : NSObject, NSCoding{

    var androidAppID : String!
    var androidBannerAds : String!
    var androidInterstitalAds : String!
    var androidOneSignalID : String!
    var androidPrivacyPolicy : String!
    var androidShareText : String!
    var androidUpdateDescription : String!
    var androidUpdateVersion : String!
    var iOSPrivacyPolicy : String!
    var iosAppID : String!
    var iosBannerAds : String!
    var iosInterstitalAds : String!
    var iosAppOpenAds : String!
    var iosRewardedAds : String!
    var iosOneSignalID : String!
    var iosShareText : String!
    var iosUpdateDescription : String!
    var iosUpdateVersion : String!
    var isShowAndroidAds : Bool!
    var isShowiOSAds : Bool!
    var updateFirebaseJson : Int!
    var adsPresentCount: Int!

    /**
     * Instantiate the instance using the passed dictionary values to set the properties values
     */
    init(fromDictionary dictionary: [String:Any]){
        androidAppID = dictionary["androidAppID"] as? String
        androidBannerAds = dictionary["androidBannerAds"] as? String
        androidInterstitalAds = dictionary["androidInterstitalAds"] as? String
        androidOneSignalID = dictionary["androidOneSignalID"] as? String
        androidPrivacyPolicy = dictionary["androidPrivacyPolicy"] as? String
        androidShareText = dictionary["androidShareText"] as? String
        androidUpdateDescription = dictionary["androidUpdateDescription"] as? String
        androidUpdateVersion = dictionary["androidUpdateVersion"] as? String
        iOSPrivacyPolicy = dictionary["iOSPrivacyPolicy"] as? String
        iosAppID = dictionary["iosAppID"] as? String
        iosBannerAds = dictionary["iosBannerAds"] as? String
        iosInterstitalAds = dictionary["iosInterstitalAds"] as? String
        iosAppOpenAds = dictionary["iosAppOpenAds"] as? String
        iosRewardedAds = dictionary["iosRewardedAds"] as? String
        iosOneSignalID = dictionary["iosOneSignalID"] as? String
        iosShareText = dictionary["iosShareText"] as? String
        iosUpdateDescription = dictionary["iosUpdateDescription"] as? String
        iosUpdateVersion = dictionary["iosUpdateVersion"] as? String
        isShowAndroidAds = dictionary["isShowAndroidAds"] as? Bool
        isShowiOSAds = dictionary["isShowiOSAds"] as? Bool
        updateFirebaseJson = dictionary["updateFirebaseJson"] as? Int
        adsPresentCount = dictionary["adsPresentCount"] as? Int
    }

    /**
     * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
     */
    func toDictionary() -> [String:Any]
    {
        var dictionary = [String:Any]()
        if androidAppID != nil{
            dictionary["androidAppID"] = androidAppID
        }
        if androidBannerAds != nil{
            dictionary["androidBannerAds"] = androidBannerAds
        }
        if androidInterstitalAds != nil{
            dictionary["androidInterstitalAds"] = androidInterstitalAds
        }
        if androidOneSignalID != nil{
            dictionary["androidOneSignalID"] = androidOneSignalID
        }
        if androidPrivacyPolicy != nil{
            dictionary["androidPrivacyPolicy"] = androidPrivacyPolicy
        }
        if androidShareText != nil{
            dictionary["androidShareText"] = androidShareText
        }
        if androidUpdateDescription != nil{
            dictionary["androidUpdateDescription"] = androidUpdateDescription
        }
        if androidUpdateVersion != nil{
            dictionary["androidUpdateVersion"] = androidUpdateVersion
        }
        if iOSPrivacyPolicy != nil{
            dictionary["iOSPrivacyPolicy"] = iOSPrivacyPolicy
        }
        if iosAppID != nil{
            dictionary["iosAppID"] = iosAppID
        }
        if iosBannerAds != nil{
            dictionary["iosBannerAds"] = iosBannerAds
        }
        if iosInterstitalAds != nil{
            dictionary["iosInterstitalAds"] = iosInterstitalAds
        }
        if iosOneSignalID != nil{
            dictionary["iosOneSignalID"] = iosOneSignalID
        }
        if iosShareText != nil{
            dictionary["iosShareText"] = iosShareText
        }
        if iosUpdateDescription != nil{
            dictionary["iosUpdateDescription"] = iosUpdateDescription
        }
        if iosUpdateVersion != nil{
            dictionary["iosUpdateVersion"] = iosUpdateVersion
        }
        if isShowAndroidAds != nil{
            dictionary["isShowAndroidAds"] = isShowAndroidAds
        }
        if isShowiOSAds != nil{
            dictionary["isShowiOSAds"] = isShowiOSAds
        }
        if updateFirebaseJson != nil{
            dictionary["updateFirebaseJson"] = updateFirebaseJson
        }
        return dictionary
    }

    /**
    * NSCoding required initializer.
    * Fills the data from the passed decoder
    */
    @objc required init(coder aDecoder: NSCoder)
    {
         androidAppID = aDecoder.decodeObject(forKey: "androidAppID") as? String
         androidBannerAds = aDecoder.decodeObject(forKey: "androidBannerAds") as? String
         androidInterstitalAds = aDecoder.decodeObject(forKey: "androidInterstitalAds") as? String
         androidOneSignalID = aDecoder.decodeObject(forKey: "androidOneSignalID") as? String
         androidPrivacyPolicy = aDecoder.decodeObject(forKey: "androidPrivacyPolicy") as? String
         androidShareText = aDecoder.decodeObject(forKey: "androidShareText") as? String
         androidUpdateDescription = aDecoder.decodeObject(forKey: "androidUpdateDescription") as? String
         androidUpdateVersion = aDecoder.decodeObject(forKey: "androidUpdateVersion") as? String
         iOSPrivacyPolicy = aDecoder.decodeObject(forKey: "iOSPrivacyPolicy") as? String
         iosAppID = aDecoder.decodeObject(forKey: "iosAppID") as? String
         iosBannerAds = aDecoder.decodeObject(forKey: "iosBannerAds") as? String
         iosInterstitalAds = aDecoder.decodeObject(forKey: "iosInterstitalAds") as? String
         iosOneSignalID = aDecoder.decodeObject(forKey: "iosOneSignalID") as? String
         iosShareText = aDecoder.decodeObject(forKey: "iosShareText") as? String
         iosUpdateDescription = aDecoder.decodeObject(forKey: "iosUpdateDescription") as? String
         iosUpdateVersion = aDecoder.decodeObject(forKey: "iosUpdateVersion") as? String
         isShowAndroidAds = aDecoder.decodeObject(forKey: "isShowAndroidAds") as? Bool
         isShowiOSAds = aDecoder.decodeObject(forKey: "isShowiOSAds") as? Bool
         updateFirebaseJson = aDecoder.decodeObject(forKey: "updateFirebaseJson") as? Int

    }

    /**
    * NSCoding required method.
    * Encodes mode properties into the decoder
    */
    @objc func encode(with aCoder: NSCoder)
    {
        if androidAppID != nil{
            aCoder.encode(androidAppID, forKey: "androidAppID")
        }
        if androidBannerAds != nil{
            aCoder.encode(androidBannerAds, forKey: "androidBannerAds")
        }
        if androidInterstitalAds != nil{
            aCoder.encode(androidInterstitalAds, forKey: "androidInterstitalAds")
        }
        if androidOneSignalID != nil{
            aCoder.encode(androidOneSignalID, forKey: "androidOneSignalID")
        }
        if androidPrivacyPolicy != nil{
            aCoder.encode(androidPrivacyPolicy, forKey: "androidPrivacyPolicy")
        }
        if androidShareText != nil{
            aCoder.encode(androidShareText, forKey: "androidShareText")
        }
        if androidUpdateDescription != nil{
            aCoder.encode(androidUpdateDescription, forKey: "androidUpdateDescription")
        }
        if androidUpdateVersion != nil{
            aCoder.encode(androidUpdateVersion, forKey: "androidUpdateVersion")
        }
        if iOSPrivacyPolicy != nil{
            aCoder.encode(iOSPrivacyPolicy, forKey: "iOSPrivacyPolicy")
        }
        if iosAppID != nil{
            aCoder.encode(iosAppID, forKey: "iosAppID")
        }
        if iosBannerAds != nil{
            aCoder.encode(iosBannerAds, forKey: "iosBannerAds")
        }
        if iosInterstitalAds != nil{
            aCoder.encode(iosInterstitalAds, forKey: "iosInterstitalAds")
        }
        if iosOneSignalID != nil{
            aCoder.encode(iosOneSignalID, forKey: "iosOneSignalID")
        }
        if iosShareText != nil{
            aCoder.encode(iosShareText, forKey: "iosShareText")
        }
        if iosUpdateDescription != nil{
            aCoder.encode(iosUpdateDescription, forKey: "iosUpdateDescription")
        }
        if iosUpdateVersion != nil{
            aCoder.encode(iosUpdateVersion, forKey: "iosUpdateVersion")
        }
        if isShowAndroidAds != nil{
            aCoder.encode(isShowAndroidAds, forKey: "isShowAndroidAds")
        }
        if isShowiOSAds != nil{
            aCoder.encode(isShowiOSAds, forKey: "isShowiOSAds")
        }
        if updateFirebaseJson != nil{
            aCoder.encode(updateFirebaseJson, forKey: "updateFirebaseJson")
        }

    }

}


