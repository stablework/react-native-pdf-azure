//
//  SettingsViewController.swift
//  DocSign
//
//  Created by MAC on 03/02/23.
//

import UIKit
import GoogleMobileAds
import MessageUI

struct Setting{
    var image: UIImage
    var lblTitle: String
}

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
//MARK: - Outlets
    //UILabel:
    @IBOutlet weak var lbl_settings: UILabel!
    @IBOutlet weak var lbl_version: UILabel!
    //UITableView:
    @IBOutlet weak var tblView_setting: UITableView!
    @IBOutlet weak var height_tblViewSettings: NSLayoutConstraint!
    //UIView:
    @IBOutlet weak var view_banner: UIView!
    @IBOutlet weak var height_banner: NSLayoutConstraint!
    
//MARK: - Properties
    
    var settings = [Setting(image: AppConstants.SettingsMenu_images.img1, lblTitle: AppConstants.SettingsMenu_lblTitle.lbl_title1),
                    Setting(image: AppConstants.SettingsMenu_images.img2, lblTitle: AppConstants.SettingsMenu_lblTitle.lbl_title2),
                    Setting(image: AppConstants.SettingsMenu_images.img3, lblTitle: AppConstants.SettingsMenu_lblTitle.lbl_title3),
                    Setting(image: AppConstants.SettingsMenu_images.img4, lblTitle: AppConstants.SettingsMenu_lblTitle.lbl_title4),
                    Setting(image: AppConstants.SettingsMenu_images.img5, lblTitle: AppConstants.SettingsMenu_lblTitle.lbl_title5),
                    Setting(image: AppConstants.SettingsMenu_images.img6, lblTitle: AppConstants.SettingsMenu_lblTitle.lbl_title6)]
    
    var bannerView = GADBannerView()
    private var appOpen: GADAppOpenAd?
    private var interstitial: GADInterstitialAd?

//MARK: - ViewController life cycle method
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set height of tableView:
        tblView_setting.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
       
        self.lbl_version.text = "Version \(getAppInfo())"
        
        if appDelegate.modelConfig.isShowiOSAds != nil {
            if(appDelegate.modelConfig.isShowiOSAds){
                setupAds()
            }else{
                self.height_banner.constant = 0
            }
            appDelegate.checkAppVersionUpdated()
        }
//        self.navigationController?.navigationBar.isHidden = true
//        self.navigationController?.navigationItem.largeTitleDisplayMode = .automatic
//        self.navigationItem.largeTitleDisplayMode = .always
//        self.navigationController?.navigationBar.largeContentTitle = "Setting s"
//        self.navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        height_tblViewSettings.constant = tblView_setting.contentSize.height
        
        tblView_setting.layoutIfNeeded()
        tblView_setting.layoutSubviews()
        
    }
    
//MARK: - TableView delegates
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settings.count
    }
   
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsTableViewCell") as! SettingsTableViewCell
        
        let dict = settings[indexPath.row]
        
        cell.img_icon.image = settings[indexPath.row].image
        cell.lbl_title.text = dict.lblTitle
        if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1  {
           
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: cell.bounds.size.width)
        } else {
            cell.separatorInset = UIEdgeInsets.zero
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            AppSupport.rateApp()
        }
        else if indexPath.row == 1 {
            AppSupport.sendFeedback(inController: self)
        }
        else if indexPath.row == 2 {
            let vc = self.storyboard!.instantiateViewController(withIdentifier: "PrivacyPolicyViewController") as! PrivacyPolicyViewController
            let dict = settings[indexPath.row]
            vc.text_title = dict.lblTitle
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if indexPath.row == 3 {
            let vc = self.storyboard!.instantiateViewController(withIdentifier: "PrivacyPolicyViewController") as! PrivacyPolicyViewController
            let dict = settings[indexPath.row]
            vc.text_title = dict.lblTitle
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if indexPath.row == 4 {
            AppSupport.shareApp(inController: self)
        }
        else {
            guard let url = URL(string: APPACCOUNTURL) else {
                return //be safe
            }
            
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
//MARK: - Functions
    // return result: Version 1.0(1)
    func getAppInfo()->String {
        let dictionary = Bundle.main.infoDictionary!
        let version = dictionary["CFBundleShortVersionString"] as! String
        let build = dictionary["CFBundleVersion"] as! String
        return version + "(" + build + ")"
    }
}

//MARK: - Functions
extension SettingsViewController{
    func setupAds(){
        bannerView = GADBannerView(adSize: bannerSize)
        bannerView.adUnitID = GBBannerID
        bannerView.rootViewController = self
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        bannerView.load(GADRequest())
        bannerView.delegate = self
        view_banner.addSubview(bannerView)
        view_banner.isHidden = true
        bannerView.centerXAnchor.constraint(equalTo: view_banner.centerXAnchor).isActive = true
        bannerView.centerYAnchor.constraint(equalTo: view_banner.centerYAnchor).isActive = true
    }
}

//MARK: - Banner Delegate
extension SettingsViewController:GADBannerViewDelegate {
    
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("bannerViewDidReceiveAd")
        view_banner.isHidden = false
        height_banner.constant = 50
    }
    
    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        print("bannerView:didFailToReceiveAdWithError: \(error.localizedDescription)")
        height_banner.constant = 0
    }
    
    func bannerViewDidRecordImpression(_ bannerView: GADBannerView) {
        print("bannerViewDidRecordImpression")
    }
    
    func bannerViewWillPresentScreen(_ bannerView: GADBannerView) {
        print("bannerViewWillPresentScreen")
    }
    
    func bannerViewWillDismissScreen(_ bannerView: GADBannerView) {
        print("bannerViewWillDIsmissScreen")
    }
    
    func bannerViewDidDismissScreen(_ bannerView: GADBannerView) {
        print("bannerViewDidDismissScreen")
    }
}

struct AppSupport {
    static func rateApp(){
        if let url = URL(string: "https://itunes.apple.com/app/id\(appID)?action=write-review"/* "itms-apps://itunes.apple.com/app/\(appID)" */) {
            AppSupport.openURL(url)
        }
    }

    static func openURL(_ url: URL){
        if UIApplication.shared.canOpenURL(url){
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }

    static func sendFeedback(inController controller:UIViewController){
        if MFMailComposeViewController.canSendMail(){
            sendEmail(inController: controller)
        } else {
            print("Mail services are not available")
        }
    }
    
    static func sendEmail(inController controller:UIViewController) {
        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = controller as? MFMailComposeViewControllerDelegate
        
        composeVC.setToRecipients([FeedbackEmail])
        composeVC.setSubject(feedbackSubject)
        composeVC.setMessageBody(feedbackMessageBody, isHTML: false)
        composeVC.popoverPresentationController?.sourceView = controller.view
        // Present the view controller modally.
//        appDelegate.inputViewController?.present(composeVC, animated: true, completion: nil)
        controller.present(composeVC, animated: true, completion: nil)
//        self.present(composeVC, animated: true, completion: nil)
    }
    
    static func shareApp(inController controller:UIViewController){
        let textToShare = "\(appDelegate.modelConfig.iosShareText ?? "")"//" \n itms-apps://itunes.apple.com/app/\(appID)"
        AppSupport.itemShare(inController: controller, items: textToShare)
    }

    static func itemShare(inController controller:UIViewController, items:Any){
        let objectsToShare = [items]
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = controller.view
        activityVC.popoverPresentationController?.sourceRect = CGRect(x: 100, y: 200, width: 300, height: 300)
        controller.present(activityVC, animated: true, completion: nil)
    }
}

//MARK: - MF Mail Compose View Controller Delegate
extension SettingsViewController:MFMailComposeViewControllerDelegate{
    private func mailComposeController(controller: MFMailComposeViewController,
                               didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
