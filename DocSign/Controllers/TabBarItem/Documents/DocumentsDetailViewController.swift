//
//  DocumentsDetailViewController.swift
//  DocSign
//
//  Created by MAC on 06/02/23.
//

import UIKit
import PDFKit
import QuickLook
import GoogleMobileAds
import PhotosUI
import VisionKit

struct PDFinfo: Codable {
    var title: String
    var size: String
    var dateTime: String
    var pageCount: String
    var pdfName: String
}

enum type {
    case add
    case edit
    case isComeFromPrivacyPolicy
    case isComeFromTermAndCondition
}

class DocumentsDetailViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, PDFViewDelegate, UIScrollViewDelegate, QLPreviewControllerDelegate, QLPreviewControllerDataSource, UIPrinterPickerControllerDelegate, UIPageViewControllerDelegate {
   
    //MARK: - Outlets
    
    //UIView:
    @IBOutlet weak var view_bottomButtons: UIView!
    
    @IBOutlet weak var main_view: UIView!
    
    //UIButton:
    @IBOutlet weak var btn_mainAdd: UIButton!
    @IBOutlet weak var btn_add: UIButton!
    @IBOutlet weak var btn_txtAdd: UIButton!
    
    @IBOutlet weak var btn_mainShare: UIButton!
    @IBOutlet weak var btn_share: UIButton!
    @IBOutlet weak var btn_txtShare: UIButton!
    
    @IBOutlet weak var btn_mainSignature: UIButton!
    @IBOutlet weak var btn_signature: UIButton!
    @IBOutlet weak var btn_txtSignature: UIButton!
    
    @IBOutlet weak var btn_mainText: UIButton!
    @IBOutlet weak var btn_text: UIButton!
    
    @IBOutlet weak var btn_mainDelete: UIButton!
    @IBOutlet weak var btn_delete: UIButton!
    @IBOutlet weak var btn_txtDelete: UIButton!
    
    @IBOutlet weak var btn_back: UIButton!
    
    @IBOutlet weak var btn_edit: UIButton!
    @IBOutlet weak var btn_printer: UIButton!
    
    //UILabel:
    @IBOutlet weak var lbl_text: UILabel!
    @IBOutlet weak var lbl_title: UILabel!
    //@IBOutlet weak var lbl_pgNumbers: UILabel!
    
    //UIPageController:
    @IBOutlet weak var pageController: UIPageControl!
    
    //UIView:
    @IBOutlet weak var view_banner: UIView!
    @IBOutlet weak var height_banner: NSLayoutConstraint!
    
    //MARK: - Properties
    
    //pdfView:
    var pdfView = PDFView()
    var documents = PDFDocument()
    var pdfNewName:String = ""
    var existingPdfName:String = ""
    var editPDF:type = .add
    
    //model:
    var modelPDF : PDFinfo!
    var arrModelPdf = [PDFinfo]()
    
    //var arrPDF : [PDFinfo]()
    
    //imagePicker:
    var picker: UIImagePickerController? = UIImagePickerController()
    var arrImage = [UIImage]()
    var transferedImage:[UIImage]!
    
    //userDefaults:
    var defaults = UserDefaults.standard
    
    //current date and time:
    let currentDate = Date()
    var dateFormatter = DateFormatter()
    
    var delegate: PDFViewDelegate?
    var pwdDocUrl: URL?
    let button:UIButton = {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(pointSize: 50)
        view.setImage(UIImage(systemName: "doc.text", withConfiguration: config), for: .normal)
        
        return view
    }()
    
    var myClosure:([PDFinfo]) -> Void = {_ in}
    
    var bannerView = GADBannerView()
    private var appOpen: GADAppOpenAd?
    private var interstitial: GADInterstitialAd?
    
    //MARK: - ViewController life cycle method
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.pdfNewName = "Heyy.pdf"
        self.view_bottomButtons.layer.shadowColor = UIColor.systemGray4.cgColor
        self.view_bottomButtons.layer.shadowOpacity = 1.5
        
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.navigationBar.isHidden = true
        let tabBar = self.tabBarController as? TabBarViewController
        tabBar?.menuButton.isHidden = true
        
        self.btn_add.isUserInteractionEnabled = false
        self.btn_share.isUserInteractionEnabled = false
        self.btn_signature.isUserInteractionEnabled = false
        self.btn_text.isUserInteractionEnabled = false
        self.btn_delete.isUserInteractionEnabled = false
        self.btn_txtAdd.isUserInteractionEnabled = false
        self.btn_txtShare.isUserInteractionEnabled = false
        self.btn_txtSignature.isUserInteractionEnabled = false
        self.btn_txtDelete.isUserInteractionEnabled = false
        
        self.pdfView.delegate = self
        
        self.pdfView.isUserInteractionEnabled = false
        
        if appDelegate.modelConfig.isShowiOSAds != nil {
            if(appDelegate.modelConfig.isShowiOSAds){
                setupAds()
                interstitialAddAds()
            }else{
                self.height_banner.constant = 0
            }
            appDelegate.checkAppVersionUpdated()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //pdfView.usePageViewController(true)
        
        if let tabbar = self.tabBarController as? TabBarViewController {
            tabbar.menuButton.isHidden = true
        }
        
        if editPDF == .add{
            
            //Current time:
            dateFormatter.dateFormat = "d MMM,yyyy | HH:mm"
            let c_dateTime = dateFormatter.string(from: currentDate)
            
            //Replace space(" ") with "_":
            dateFormatter.dateFormat = "d MMM yyyy HH mm ss"
            let dateTime = dateFormatter.string(from: currentDate)
            
            let str = "PDF \(dateTime)"
            let replaced = str.replacingOccurrences(of: " ", with: "_")
            
            let fileManager = FileManager()
            let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let docURL = documentDirectory.appendingPathComponent("PDF \(c_dateTime)")
            if fileManager.fileExists(atPath: docURL.path){
                pdfView.document = PDFDocument(url: docURL)
            }
            
            let fileSize = fileSize(fromPath: "\(docURL.path)")
            
            let pdfModel = PDFinfo(title: "PDF \(c_dateTime)", size: "\(fileSize ?? "")", dateTime: "\(c_dateTime)", pageCount: "\("") page", pdfName: "\(replaced).pdf")
            
            self.modelPDF = pdfModel
            
            print(pdfModel)
            print("title:\(pdfModel.title)")
            print("size:\(pdfModel.size)")
            print("dateTime:\(pdfModel.dateTime)")
            print("pgCount:\(pdfModel.pageCount)")
            print("pdfName:\(pdfModel.pdfName)")
            
            //For fit image in pdfView:
            //pdfView.usePageViewController(true, withViewOptions: nil)
            
            self.lbl_title.text = "\(modelPDF.title)"
            self.createPDF()
            self.displayPdf()
            editPDF = .edit
            //self.imagePickerControllerDidCancel(picker!)
            
        }
        else{
            self.lbl_title.text = "\(modelPDF.title)"
            self.displayPdf()
        }
    }
    
    override func viewDidAppear(_ _animated: Bool){
    }
    
    @objc func didTapEditButton(sender: AnyObject){
    }
    
    @objc func didTapPrintButton(sender: AnyObject){
    }
    
    @objc func didTapBackButton(sender: AnyObject){
        self.navigationController?.popViewController(animated: true)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    @IBAction func btn_back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    //MARK: - Actions
    @IBAction func btn_mainAdd(_ sender: Any) {
        self.actionSheet()
    }
    
    @IBAction func btn_mainShare(_ sender: Any) {
        
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let docURL = documentDirectory.appendingPathComponent(modelPDF.pdfName)
        
        let objectsToShare = [docURL]
        let activityController = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        let excludedActivities = [UIActivity.ActivityType.postToFlickr, UIActivity.ActivityType.postToWeibo, UIActivity.ActivityType.message, UIActivity.ActivityType.mail, UIActivity.ActivityType.print, UIActivity.ActivityType.copyToPasteboard, UIActivity.ActivityType.assignToContact, UIActivity.ActivityType.saveToCameraRoll, UIActivity.ActivityType.addToReadingList, UIActivity.ActivityType.postToFlickr, UIActivity.ActivityType.postToVimeo, UIActivity.ActivityType.postToTencentWeibo]
        
        activityController.excludedActivityTypes = excludedActivities
        
        present(activityController, animated: true, completion: nil)
    }
    
    @IBAction func btn_mainSignature(_ sender: Any) {
        editPDF = .edit
        let previewController = QLPreviewController()
        previewController.dataSource = self
        previewController.delegate = self
        previewController.setEditing(true, animated: true)
        self.present(previewController, animated: true, completion: nil)
    }
    
    @IBAction func btn_mainText(_ sender: Any) {
    }
    
    @IBAction func btn_mainDelete(_ sender: Any) {
        self.delete_alertAction()
    }
    
    @IBAction func btn_edit(_ sender: Any) {
        editPDF = .edit
        let previewController = QLPreviewController()
        previewController.dataSource = self
        previewController.delegate = self
        previewController.setEditing(true, animated: true)
        self.present(previewController, animated: true, completion: nil)
    }
    
    @IBAction func btn_printer(_ sender: Any) {
        
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let docURL = documentDirectory.appendingPathComponent(modelPDF.pdfName)
        
        let info = UIPrintInfo(dictionary:nil)
        info.outputType = UIPrintInfo.OutputType.general
        info.jobName = "Printing"
        
        let vc = UIPrintInteractionController.shared
        vc.printInfo = info
        
        vc.printingItem = docURL
        
        vc.present(from: self.view.frame, in: self.view, animated: true, completionHandler: nil)
    }
    
    @IBAction func pageController(_ sender: Any) {
        
        let indexPath = IndexPath()
        
        self.pageController.currentPage = indexPath.row
    }    
    
    //MARK: - PdfView Delegate
    
    //    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
    //        <#code#>
    //    }
    
    //MARK: - Functions
    func createPDF(){
        
        let pdfDocument = PDFDocument()
        // Insert the PDF page into your document
        for index in 0...transferedImage.count - 1 {
            let pdfPage = PDFPage(image: transferedImage[index])
            pdfDocument.insert(pdfPage!, at: index)
        }
        
        
        
        let data = pdfDocument.dataRepresentation()
//        
//        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//        
//        let docURL = documentDirectory.appendingPathComponent()
        
            let documentDirectory = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
            let docURL = documentDirectory.appendingPathComponent(self.modelPDF.pdfName)

           
//
//     // true
        
        print("createURL:\(docURL)")
        
        do{
            try data?.write(to: docURL)
        }catch(let error){
            print("error is \(error.localizedDescription)")
        }
        
        //set pageCount and pdfSize:
        modelPDF.pageCount = "\((pdfView.document?.pageCount) ?? 1) page"
        modelPDF.size = "\(fileSize(fromPath: "\(docURL.path)") ?? "")"
        
        appDelegate.arrPDFinfo.append(self.modelPDF)
        appDelegate.setPdfInfoUserDefault()
    }
    
    func comeFromCellPDF(){
        
        let data = pdfView.document?.dataRepresentation()
        
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        let docURL = documentDirectory.appendingPathComponent("\(modelPDF.pdfName)")
        
        do{
            try data?.write(to: docURL)
        }catch(let error){
            print("error is \(error.localizedDescription)")
        }
        
        //get value of array:
        let id = appDelegate.arrPDFinfo.firstIndex { info in
            info.pdfName == self.modelPDF.pdfName
        }
        
        //Update pdfSize and pageCount after insert each page:
        appDelegate.arrPDFinfo[id ?? 0].pageCount = "\((pdfView.document?.pageCount) ?? 0) page"
        appDelegate.arrPDFinfo[id ?? 0].size = "\(fileSize(fromPath: "\(docURL.path)") ?? "")"
        
        appDelegate.setPdfInfoUserDefault()
    }
    
    private func displayPdf() {
        
        let pdfView1 = PDFView(frame: self.main_view.bounds)
        pdfView = pdfView1
        //        let myFileName = "sample"
        //        guard let url = Bundle.main.url(forResource: myFileName, withExtension: "pdf") else {
        //                 return
        //        }
        pdfView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        pdfView.autoScales = true
        pdfView.displaysPageBreaks = true
        pdfView.displayMode = .singlePageContinuous
                
        pdfView.displayDirection = .horizontal
        pdfView.translatesAutoresizingMaskIntoConstraints = false
       
        //For fit image in pdfView:
        pdfView.usePageViewController(true, withViewOptions: nil)
        self.main_view.addSubview(pdfView)
        
        let fileManager = FileManager()
        
        if editPDF == .add {
            let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let docURL = documentDirectory.appendingPathComponent(modelPDF.pdfName)
            print(modelPDF.pdfName)
            if fileManager.fileExists(atPath: docURL.path){
                let pdfDoc = PDFDocument(url: docURL)
                print( pdfDoc?.isEncrypted)
                if !(pdfDoc?.isEncrypted ?? false) {
                    pdfView.document = pdfDoc
                }
               
            }
        }
        else{
            let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let docURL = documentDirectory.appendingPathComponent(modelPDF.pdfName)
            if fileManager.fileExists(atPath: docURL.path){
                pdfView.document = PDFDocument(url: docURL)
            }
        }
        
//        let currentPageIndex = pdfView.document?.pageCount //pdfDocument.index(for: pdfView.currentPage!)
//        self.lbl_pgNumbers.text = "\(currentPageIndex ?? 0)"
        
        print("documents::::\(self.documents)")
 //       pageController.numberOfPages = pdfView.document?.pageCount ?? 0
        
        
//        pdfView.detectScrollView()?.isScrollEnabled = true
        pdfView.detectScrollView()?.showsVerticalScrollIndicator = false
        pdfView.detectScrollView()?.showsHorizontalScrollIndicator = false
                
    }
    
    func openGalary() {

        var  config = PHPickerConfiguration()
        config.selectionLimit = 5
        config.filter = .images
        let phPicker = PHPickerViewController(configuration: config)
        phPicker.delegate = self
        present(phPicker,animated: true)
    }
    
    func openCamera() {
//        picker!.allowsEditing = true
//        picker?.delegate = self
//        picker!.sourceType = .camera
//        present(picker!, animated: true, completion: nil)
        let scannerViewController = VNDocumentCameraViewController()
        scannerViewController.delegate = self
        present(scannerViewController, animated: true)
    }
    func openFileManager() {
        let documentPicker = UIDocumentPickerViewController(documentTypes: ["public.image"], in: .import)
        documentPicker.allowsMultipleSelection = true
        documentPicker.delegate = self
                documentPicker.allowsMultipleSelection = false
                present(documentPicker, animated: true, completion: nil)
        
    }
    
    private func generateBoundaryString() -> String {
        return "Boundary-\(UUID().uuidString)"
    }
    
 
    
    func actionSheet(){
        let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // create an action
        let firstAction: UIAlertAction = UIAlertAction(title: "Take Photo", style: .default) { action -> Void in
            self.openCamera()
            print("Take photos btn pressed")
        }
        let secondAction: UIAlertAction = UIAlertAction(title: "Choose Photo", style: .default) { action -> Void in
            self.openGalary()
        }
        let thirdAction: UIAlertAction = UIAlertAction(title: " Browse...", style: .default) { action -> Void in
            self.openFileManager()
        }
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in }
        
        firstAction.setValue(UIColor(named: "app_themeColor"), forKey: "titleTextColor")
        secondAction.setValue(UIColor(named: "app_themeColor"), forKey: "titleTextColor")
        thirdAction.setValue(UIColor(named: "app_themeColor"), forKey: "titleTextColor")
        cancelAction.setValue(UIColor(named: "app_themeColor"), forKey: "titleTextColor")
        
        // add actions
        actionSheetController.addAction(firstAction)
        actionSheetController.addAction(secondAction)
        actionSheetController.addAction(thirdAction)
        actionSheetController.addAction(cancelAction)
        
        present(actionSheetController, animated: true) {
            print("option menu presented")
        }
    }
    
    func fileSize(fromPath path: String) -> String? {
        guard let size = try? FileManager.default.attributesOfItem(atPath: path)[FileAttributeKey.size],
              let fileSize = size as? UInt64 else {
                  return nil
              }
        
        // bytes
        if fileSize < 1023 {
            return String(format: "%lu bytes", CUnsignedLong(fileSize))
        }
        // KB
        var floatSize = Float(fileSize / 1024)
        if floatSize < 1023 {
            return String(format: "%.1f KB", floatSize)
        }
        // MB
        floatSize = floatSize / 1024
        if floatSize < 1023 {
            return String(format: "%.1f MB", floatSize)
        }
        // GB
        floatSize = floatSize / 1024
        return String(format: "%.1f GB", floatSize)
    }
    
    //AlertBox when tapped on btn_delete:
    func delete_alertAction(){
        let actionSheetController: UIAlertController = UIAlertController(title: "PDF Editor", message: "Are you sure you want to delete \(modelPDF.pdfName)?", preferredStyle: .alert)

        // create an action:
        let firstAction: UIAlertAction = UIAlertAction(title: "Yes", style: .default) { action -> Void in

            //get value of array:
            let id = appDelegate.arrPDFinfo.firstIndex { info in
                info.pdfName == self.modelPDF.pdfName
            }
            
            let idd = appDelegate.arrPDFinfo.remove(at: id ?? 0)
            self.myClosure(appDelegate.arrPDFinfo)
            appDelegate.setPdfInfoUserDefault()
            
            self.navigationController?.popViewController(animated: true)
            self.tabBarController?.tabBar.isHidden = false
            
            print("Yes pressed")
            print(idd)
        }
        let secondAction: UIAlertAction = UIAlertAction(title: "No", style: .default) { action -> Void in
            self.dismiss(animated: true, completion: nil)
            print("No pressed")
        }

        // add actions:
        actionSheetController.addAction(firstAction)
        actionSheetController.addAction(secondAction)

        self.present(actionSheetController, animated: true) {
            print("option menu presented")
        }
    }
    
    //MARK: - QLPreviewController() //Edit PDF:
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        print(controller.isEditing)
        
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let docURL = documentDirectory.appendingPathComponent(modelPDF.pdfName)
        
        return docURL as QLPreviewItem
    }
    
    func previewController(_ controller: QLPreviewController, editingModeFor previewItem: QLPreviewItem) -> QLPreviewItemEditingMode {
        
        return .updateContents
    }
    
    func previewController(_ controller: QLPreviewController, didUpdateContentsOf previewItem: QLPreviewItem) {
        print("updatedURL:\(modelPDF.pdfName)")
    }
}

extension PDFView {
    func onScrollOffsetChange(handler: @escaping (UIScrollView) -> Void) -> NSKeyValueObservation? {
        detectScrollView()?.observe(\.contentOffset) { scroll, _ in
            handler(scroll)
        }
    }
    
     func detectScrollView() -> UIScrollView? {
        for view in subviews {
            if let scroll = view as? UIScrollView {
                return scroll
            } else {
                for subview in view.subviews {
                    if let scroll = subview as? UIScrollView {
                        return scroll
                    }
                }
            }
        }
        
        print("Unable to find a scrollView subview on a PDFView.")
        return nil
    }
}

//MARK: - Functions
extension DocumentsDetailViewController{
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
    
    func interstitialAddAds(){
        appDelegate.loadAds(interstitial: { ad in
            self.interstitial = ad
            self.show(.Interstitial)
        }, reward: nil, adsType: .Interstitial)
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
}

//MARK: - Banner Delegate
extension DocumentsDetailViewController:GADBannerViewDelegate {

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

//new photo picker
extension DocumentsDetailViewController : PHPickerViewControllerDelegate {

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        let dispatchGroup = DispatchGroup()
        
        var selectedImages:[UIImage] = [UIImage]()

        
        for result in results {
            dispatchGroup.enter()
            result.itemProvider.loadObject(ofClass: UIImage.self) { imageObject, error in
                if let image = imageObject as? UIImage {
                    print(image)
                    selectedImages.append(image)
                    print(selectedImages.count)
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            self.dismiss(animated: true)
//
            for image in selectedImages{
                let pdfPage = PDFPage(image: image)
                // Insert the PDF page into your document
                self.pdfView.document?.insert(pdfPage!, at: self.pdfView.document?.pageCount ?? 0)
            }
           
            
            //Set pageController -> pages count = image count:
            self.pageController.numberOfPages = self.pdfView.document?.pageCount ?? 0
            self.pageController.currentPage = 0
            
            //For fit image in pdfView:
            //pdfView.usePageViewController(true, withViewOptions: nil)
            
            self.comeFromCellPDF()
            self.displayPdf()
        }
    }

    
    
}

extension DocumentsDetailViewController: VNDocumentCameraViewControllerDelegate {
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        // Process the scanned pages
        let dispatchGroup = DispatchGroup()
        
        var selectedImages:[UIImage] = [UIImage]()
        var lastImage:UIImage!
        for pageNumber in 0..<scan.pageCount {
            dispatchGroup.enter()
            let image = scan.imageOfPage(at: pageNumber)
            let pdfPage = PDFPage(image: image)
            // Insert the PDF page into your document
            self.pdfView.document?.insert(pdfPage!, at: self.pdfView.document?.pageCount ?? 0)
            lastImage = image
            dispatchGroup.leave()
        }

        // You are responsible for dismissing the controller.
        dispatchGroup.notify(queue: .main) {
            controller.dismiss(animated: true)
            self.pageController.numberOfPages = self.pdfView.document?.pageCount ?? 0
            self.pageController.currentPage = 0
            
            //For fit image in pdfView:
            //pdfView.usePageViewController(true, withViewOptions: nil)
            
            self.comeFromCellPDF()
            self.displayPdf()
        }
       
    }
}

extension DocumentsDetailViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        
        let dispatchGroup = DispatchGroup()
        
        var selectedImages:[UIImage] = [UIImage]()
                for url in urls {
                    dispatchGroup.enter()
                    do {
                        let imageData = try Data(contentsOf: url)
                        if let image = UIImage(data: imageData) {
                            selectedImages.append(image)
                        }
                    } catch {
                        print("Error loading image at \(url): \(error.localizedDescription)")
                    }
                    dispatchGroup.leave()
                }
                
        dispatchGroup.notify(queue: .main) {
            self.dismiss(animated: true)
//
            for image in selectedImages{
                let pdfPage = PDFPage(image: image)
                // Insert the PDF page into your document
                self.pdfView.document?.insert(pdfPage!, at: self.pdfView.document?.pageCount ?? 0)
            }
           
            
            //Set pageController -> pages count = image count:
            self.pageController.numberOfPages = self.pdfView.document?.pageCount ?? 0
            self.pageController.currentPage = 0
            
            //For fit image in pdfView:
            //pdfView.usePageViewController(true, withViewOptions: nil)
            
            self.comeFromCellPDF()
            self.displayPdf()
        }
    }

     
     
}
