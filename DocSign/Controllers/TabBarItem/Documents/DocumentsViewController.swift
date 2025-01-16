//
//  DocumentsViewController.swift
//  DocSign
//
//  Created by MAC on 03/02/23.
//

import UIKit
import PDFKit
import GoogleMobileAds
import QuickLook
import Lottie

class DocumentsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

//MARK: - Outlets
    @IBOutlet weak var tblView_documents: UITableView!
    @IBOutlet weak var view_noDocumentsAdded: UIView!
    @IBOutlet weak var img_noDocuments: LottieAnimationView!
    @IBOutlet weak var lbl_title: UILabel!{
        didSet{
            lbl_title.text = "You don't have any documents!"
        }
    }
    @IBOutlet weak var lbl_subTitle: UILabel!{
        didSet{
            lbl_subTitle.text = "Sync docs across smartphones, tablets \nand computers."
        }
    }
    @IBOutlet weak var img_downArrow: UIImageView!
    
    @IBOutlet weak var view_banner: UIView!
    @IBOutlet weak var height_banner: NSLayoutConstraint!
    
//MARK: - Properties
    
    var dateFormatter = DateFormatter()
    let currentDate = Date()
    let pdfView = PDFView()
    
    var pdfName:String = ""
        
    var dict: [[String: Any]] = []
    
    var modelPDF : PDFinfo!
    
    var bannerView = GADBannerView()
    private var appOpen: GADAppOpenAd?
    private var interstitial: GADInterstitialAd?
    var selectedIndex:IndexPath?
    

//MARK: - ViewController life cycle method
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarController?.tabBar.isHidden = false
        
        self.tabBarController?.tabBar.layer.shadowColor = UIColor.systemGray4.cgColor
        self.tabBarController?.tabBar.layer.shadowOpacity = 1
        
        view_noDocumentsAdded.isHidden = true
        tblView_documents.isHidden = false
        
        self.tblView_documents.reloadData()
        
        
        if appDelegate.modelConfig.isShowiOSAds != nil {
           if(appDelegate.modelConfig.isShowiOSAds){
               setupAds()
           }else{
               self.height_banner.constant = 0
           }
           appDelegate.checkAppVersionUpdated()
       }
        img_noDocuments?.animation = .named("noPDF")
         
        img_noDocuments!.loopMode = .loop
         
        img_noDocuments!.play()
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        let tabbar = self.tabBarController as! TabBarViewController
        tabbar.menuButton.isHidden = false
        self.tabBarController?.tabBar.isHidden = false
        appDelegate.getPdfInfoUserDefault()
        self.tblView_documents.reloadData()
       
    }
    override func viewDidAppear(_ animated: Bool) {
      
    }
  
    func show(_ type:GoogleAddType){
        let vc = appDelegate.window?.visibleViewController
        switch type {
        case .Interstitial:
            if let ad = interstitial {
                ad.present(fromRootViewController: vc ?? self)
            } else {
              print("Ad wasn't ready")
            }
        case .AppOpen:
            if let ad = appOpen {
                ad.present(fromRootViewController: vc ?? self)
            } else {
              print("Ad wasn't ready")
            }
        }
    }

    func menu(indexPath:IndexPath,showRemovePass:Bool) -> UIMenu {
        
        
        let itemMenu = UIMenu(options: .displayInline,children: [
            //go to edit pdf screen
            UIAction(title: "Edit",image: UIImage(systemName: "pencil") ,handler: { _ in
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "DocumentsDetailViewController") as! DocumentsDetailViewController
                vc.editPDF = .edit
                vc.modelPDF = appDelegate.arrPDFinfo[indexPath.section]
                vc.hidesBottomBarWhenPushed = true
                vc.myClosure = { arr in
                    appDelegate.arrPDFinfo = arr
                    self.tblView_documents.reloadData()
                }
                self.navigationController?.pushViewController(vc, animated: true)
            }),
            //rename file
           
            UIAction(title: "Rename",image: UIImage(systemName: "doc.text") ,handler: { _ in
                let dict = appDelegate.arrPDFinfo[indexPath.section]
                let alertController = UIAlertController(title: "Rename PDF", message: "", preferredStyle: .alert)
                alertController.addTextField { (textfield) in
                    textfield.placeholder = "Enter a new PDF name"
                }
                let doneAction = UIAlertAction(title: "Done", style: .default) { (action) in
                   if let newName = alertController.textFields?.first {
                       let newPdfName = newName.text ?? "newFile"
                       do {
                           
                           let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
                           let documentDirectory = URL(fileURLWithPath: path)
                           let originPath = documentDirectory.appendingPathComponent(dict.pdfName)
                           let destinationPath = documentDirectory.appendingPathComponent(newPdfName)
                           try FileManager.default.moveItem(at: originPath, to: destinationPath)
                           
                           appDelegate.arrPDFinfo[indexPath.section].pdfName = newPdfName
                           self.tblView_documents.reloadData()
                       } catch {
                           print(error)
                       }
                    }
                }
                let cancelAction = UIAlertAction(title: "Cancel", style: .destructive) { _ in
                    
                }
                alertController.addAction(doneAction)
                alertController.addAction(cancelAction)
                self.present(alertController, animated: true)
                
            }),
           
            UIAction(title:!showRemovePass ? "Add Password" : "Remove Pass",image: UIImage(systemName: "lock.doc") ,handler: { _ in

                let dict = appDelegate.arrPDFinfo[indexPath.section]
                        let alertController = UIAlertController(title: !showRemovePass ? "Add Password" : "Remove Pass", message: "", preferredStyle: .alert)
                        alertController.addTextField { (textfield) in
                            textfield.placeholder = "Enter a Password"
                        }
                        let doneAction = UIAlertAction(title: "Done", style: .default) { (action) in
                            if let newName = alertController.textFields?.first {
                                let password = newName.text ?? ""
                                let dict = appDelegate.arrPDFinfo[indexPath.section]
                                let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                                let docURL = documentDirectory.appendingPathComponent(dict.pdfName)
                                let fileManager = FileManager()
                                if fileManager.fileExists(atPath: docURL.path){
                                    let pdfDoc = PDFDocument(url: docURL)
                                    if showRemovePass {
                                        self.removePasswordFromPdf(docUrl: docURL, password: password)
                                    }
                                    else {
                                        self.addPasswordToPdf(docUrl: docURL, password: password)
                                    }
                                    self.tblView_documents.reloadData()
                                }
                            }
                        }
                        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive) { _ in
                            
                        }
                        alertController.addAction(doneAction)
                        alertController.addAction(cancelAction)
                        self.present(alertController, animated: true)
                        
                    
                    
                }),

            //delete pdf
            UIAction(title: "Share",image: UIImage(systemName: "square.and.arrow.up") ,handler: { _ in
                let dict = appDelegate.arrPDFinfo[indexPath.section]
                let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let docURL = documentDirectory.appendingPathComponent(dict.pdfName)
                self.sharePdf(docUrl: docURL)
            }),
            UIAction(title: "Delete",image: UIImage(systemName: "trash.fill"),attributes: .destructive ,handler: { _ in
                let dict = appDelegate.arrPDFinfo[indexPath.section]
                self.simpleAlert(vc: self, title: "PDF Editor", message: "Are you sure you want to delete \(dict.pdfName)?", indexPath: indexPath)
            })
        ])
            
        return itemMenu
             
     
    }
    func addPasswordToPdf(docUrl:URL,password:String) {
        let pdfDocument = PDFDocument(url: docUrl)
        //         write with password protection
        pdfDocument?.write(to: docUrl, withOptions: [PDFDocumentWriteOption.userPasswordOption : "\(password)",
                                                    PDFDocumentWriteOption.ownerPasswordOption : "\(password)"])
        
        // get encrypted pdf
        guard let encryptedPDFDoc = PDFDocument(url: docUrl) else {
            return
        }
    }
    func removePasswordFromPdf(docUrl: URL,password:String) {
        guard let pdfDocument = PDFDocument(url: docUrl) else {
            return
        }
        let isPdfUnlock =   pdfDocument.unlock(withPassword: "\(password)")
        if isPdfUnlock {
            let newPdfDocument = PDFDocument()
            for i in 0..<pdfDocument.pageCount {
                if let page = pdfDocument.page(at: i) {
                    newPdfDocument.insert(page, at: i)
                }
            }
            newPdfDocument.write(to: docUrl)
        } else {
            let invalidAlert = UIAlertController(title: "Password Wrong" , message: "Your password is invalid", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Done", style: .default) { _ in
                
            }
            invalidAlert.addAction(cancelAction)
            self.present(invalidAlert, animated: true)
        }
    }

    func sharePdf(docUrl:URL)  {
        
       
        let objectsToShare = [docUrl]
        let activityController = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        let excludedActivities = [UIActivity.ActivityType.postToFlickr, UIActivity.ActivityType.postToWeibo, UIActivity.ActivityType.message, UIActivity.ActivityType.mail, UIActivity.ActivityType.print, UIActivity.ActivityType.copyToPasteboard, UIActivity.ActivityType.assignToContact, UIActivity.ActivityType.saveToCameraRoll, UIActivity.ActivityType.addToReadingList, UIActivity.ActivityType.postToFlickr, UIActivity.ActivityType.postToVimeo, UIActivity.ActivityType.postToTencentWeibo]
        
        activityController.excludedActivityTypes = excludedActivities
        
        present(activityController, animated: true, completion: nil)
    }
    

//MARK: - TableView delegates
    func numberOfSections(in tableView: UITableView) -> Int {
        if appDelegate.arrPDFinfo.count == 0 {
            view_noDocumentsAdded.isHidden = false
        }else {
            view_noDocumentsAdded.isHidden = true
        }
        
        return appDelegate.arrPDFinfo.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      
        let cell = tableView.dequeueReusableCell(withIdentifier: "DocumentsTableViewCell") as! DocumentsTableViewCell

        let dict = appDelegate.arrPDFinfo[indexPath.section]
        
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let docURL = documentDirectory.appendingPathComponent(dict.pdfName)
    
//        let img = self.generatePdfThumbnail(of: CGSize(width: cell.img_profile.width, height: cell.img_profile.height), for: docURL, atPage: pdfView.document?.pageCount ?? 0)
        
//        cell.img_profile.image = img
//        cell.img_profile.tintColor = UIColor(named: "app_themeColor")
        cell.lbl_title.text = dict.pdfName
        
        
        
        
        cell.selectionStyle = .gray
        cell.btn_editPdf.showsMenuAsPrimaryAction = true
        let pdfDocument = PDFDocument(url: docURL)
        cell.btn_editPdf.menu = self.menu(indexPath: indexPath,showRemovePass: pdfDocument?.isLocked ?? true )
        appDelegate.setPdfInfoUserDefault()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let vc = storyboard?.instantiateViewController(withIdentifier: "DocumentsDetailViewController") as! DocumentsDetailViewController
//        vc.editPDF = .edit
//        vc.modelPDF = appDelegate.arrPDFinfo[indexPath.section]
//        vc.hidesBottomBarWhenPushed = true
//        vc.myClosure = { arr in
//            appDelegate.arrPDFinfo = arr
//            self.tblView_documents.reloadData()
//        }
                
        let modelPDF = appDelegate.arrPDFinfo[indexPath.section]
//        let vc = storyboard?.instantiateViewController(withIdentifier: "PdfViewVM") as! PdfViewVM
//        vc.pdfName = modelPDF.pdfName
//        self.navigationController?.pushViewController(vc, animated: true)
        self.pdfName = modelPDF.pdfName
        let previewController = QLPreviewController()
        previewController.dataSource = self
        previewController.delegate = self
        previewController.setEditing(false, animated: true)
        self.present(previewController, animated: true, completion: nil)
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return 11
    }
    
    func generatePdfThumbnail(of thumbnailSize: CGSize , for documentUrl: URL, atPage pageIndex: Int) -> UIImage? {
        let pdfDocument = PDFDocument(url: documentUrl)
        let pdfDocumentPage = pdfDocument?.page(at: pageIndex)
        if (pdfDocument?.isLocked ?? false ) {
            return UIImage(named: "ic_pdf_lock")
        }
        else {
            return pdfDocumentPage?.thumbnail(of: thumbnailSize, for: PDFDisplayBox.trimBox)
        }
    }
    
    func simpleAlert(vc:UIViewController, title:String, message:String, indexPath: IndexPath) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        // Create NO button:
        let cancelAction = UIAlertAction(title: "NO", style: .cancel) {
            (action: UIAlertAction!) in
            self.tblView_documents.reloadData()
        }
        alertController.addAction(cancelAction)
        
        // Create YES button:
        let OKAction = UIAlertAction(title: "YES", style: .default) {
            (action: UIAlertAction!) in
            
            //On click YES button data is removed:
            appDelegate.arrPDFinfo.remove(at: indexPath.section)
            appDelegate.setPdfInfoUserDefault()
            self.tblView_documents.reloadData()
            
            // Code in this block will trigger when OK button tapped.
            print("indexPath(\(indexPath.section))deteted Data");
        }
        alertController.addAction(OKAction)
        
        // Present Dialog message
        self.present(alertController, animated: true, completion: nil)
    }
    
//    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//        
//        let dict = appDelegate.arrPDFinfo[indexPath.section]
//        
//        //Delete row:
//        let delete = UIContextualAction(style: .destructive, title: "Delete") {  (contextualAction, view, boolValue) in
//            self.simpleAlert(vc: self, title: "PDF Editor", message: "Are you sure you want to delete \(dict.pdfName)?", indexPath: indexPath)
//        }
//        delete.backgroundColor = .systemRed
//        
//        let edit = UIContextualAction(style: .destructive, title: "Edit") { (contextualAction, view,
//        boolValue) in
//            let vc = self.storyboard?.instantiateViewController(withIdentifier: "DocumentsDetailViewController") as! DocumentsDetailViewController
//            vc.editPDF = .edit
//            vc.modelPDF = appDelegate.arrPDFinfo[indexPath.section]
//            vc.hidesBottomBarWhenPushed = true
//            vc.myClosure = { arr in
//                appDelegate.arrPDFinfo = arr
//                self.tblView_documents.reloadData()
//            }
//            
//            self.navigationController?.pushViewController(vc, animated: true)
//        }
//        edit.backgroundColor = .systemGreen
//        
//        let swipeActions = UISwipeActionsConfiguration(actions: [delete, edit])
//        return swipeActions
//    }
}

//MARK: - Functions
extension DocumentsViewController{
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
extension DocumentsViewController:GADBannerViewDelegate {

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

extension DocumentsViewController: QLPreviewControllerDataSource, QLPreviewControllerDelegate {
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        print(controller.isEditing)
        
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let docURL = documentDirectory.appendingPathComponent(self.pdfName)
        
        return docURL as QLPreviewItem
    }
    
    func previewController(_ controller: QLPreviewController, didUpdateContentsOf previewItem: QLPreviewItem) {
        print("updatedURL:\(self.pdfName)")
    }
    func previewController(_ controller: QLPreviewController, editingModeFor previewItem: QLPreviewItem) -> QLPreviewItemEditingMode {
        return .disabled }
    
}
