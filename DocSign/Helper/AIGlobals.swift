//
//  AIGlobals.swift
//  Swift3CodeStructure
//
//  Created by Ravi Alagiya on 25/11/2016.
//  Copyright © 2016 Ravi Alagiya. All rights reserved.
//

import Foundation
import UIKit
//import GoogleMobileAds

//MARK: - GENERAL

let appDelegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
let APP_NAME = "PDF Editor"

//MARK:- Storyboard Outlet
let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)

//MARK:- Firebase Key
let FIREBASE_SERVER_KEY = "AAAAMWvlkKk:APA91bH9Mzzxy60SP5pC5KHGP1WEaOqkEwfhF9djRDPrZ4gR0VQay_FBM1jlv-b0YGHjgltQrT0M2MSwI-z-RW3Ym5JsTpxBO-Fhtbc7xCVXaGOFft6xQJm79c0raklOMBtIXLAAb1y0"

var kGoogleSignID = "216320069519-rm0c59rbamv2fii8mtbe8nh5mb9r1aov.apps.googleusercontent.com"


//MARK: - ONE SIGNAL
let ONE_SIGNAL_APP_ID = "db366e0f-32fd-4f07-a135-b310d4d95f1b"

//MARK: - FB AD ID
//let FBAdId = "1009874353176927"
// Test
//let FBInterstitialAdId = "VID_HD_9_16_39S_APP_INSTALL#YOUR_PLACEMENT_ID"
//let FBBannerID = "IMG_16_9_APP_INSTALL#YOUR_PLACEMENT_ID"

//let FBInterstitialAdId = "1009874353176927_1171126257051735"
//let FBBannerID = "1009874353176927_1171125937051767"

//MARK: - Google AD ID
let GBInterstitialAdId = appDelegate.isLiveAds ? (appDelegate.modelConfig.iosInterstitalAds) ?? "" : "ca-app-pub-3940256099942544/4411468910"
let GBRewardID = appDelegate.isLiveAds ? (appDelegate.modelConfig.iosRewardedAds) ?? "" : "ca-app-pub-3940256099942544/1712485313"
let GBAppOpenID = appDelegate.isLiveAds ? (appDelegate.modelConfig.iosAppOpenAds) ?? "" : "ca-app-pub-3940256099942544/5575463023"
let GBBannerID =  appDelegate.isLiveAds ? (appDelegate.modelConfig.iosBannerAds) ?? "" : "ca-app-pub-3940256099942544/6300978111"
//let bannerSize = UIDevice.current.userInterfaceIdiom == .pad ? GADAdSizeFullBanner : GADAdSizeBanner

let FeedbackEmail = "app@hash-mob.com"
let feedbackMessageBody = """
App name: \(APP_NAME)
Version: \(appDelegate.modelConfig.iosUpdateVersion ?? "")
Device: iPhone
OS Version: \(UIDevice.current.systemVersion)
"""
let feedbackSubject = "Support: \(APP_NAME)"

let DailyReminder = "Daily Reminder"
let ReminderIdentifire = "reminder"

//MARK: - UserDefault Key
let isUpgradePlan = "isUpgradePlan"
let ADS_PRESENT_COUNT = "adsPresentCount"
let ISSHOWINTROSCREEN = "IS_SHOW_INTRO_SCREEN"
let REMINDER_STRING = "reminderstring"
let REMINDER_DATE = "reminderdate"
let REMINDER_ON = "reminderon"

//var appIsStart = true
//MARK: - Live Ads
//let GBInterstitialAdId = "ca-app-pub-9597482417528881/8945401749"
//let GBBannerID = "ca-app-pub-9597482417528881/1262600264"

//MARK- Google
var kGoogleMapsKey = "AIzaSyBKjfd3ijrpaX-uwjvUfMNA8aX1izQUmOk"
var kGoogleAdsID = "ca-app-pub-3940256099942544/2934735716"
var APPSTOREURL = "https://apps.apple.com/us/app/gym-on-mobile/id1598731753"
var APPACCOUNTURL = "https://apps.apple.com/us/developer/jaydeep-virani/id1565674300"
var appID =  "1673005733"//"1483184959"

//MARK: - In-Purchase Identifier
var IN_APP_PURCHASE_BUNDLE_ID = "com.hashmob.workout.zumba.pro"

//MARK: - User Default Keyword
let isUpdateFirbaseInfo = "isUpdateFirbaseInfo"
let firebaseData = "firebaseData"


//MARK: - Alert Action String
let alertSomeThings = "Something went wrong. Please try again."


//MARK: - Notification String
let notificationString = "Still in bed? Awakkkkke 🌞 do some exercise and make your 🌻 day!"
