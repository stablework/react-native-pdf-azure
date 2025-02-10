//
//  DocumentsDetailViewController.swift
//  DocSign
//
//  Created by MAC on 06/02/23.
//

import UIKit
import PDFKit
import QuickLook
import PhotosUI
import VisionKit

struct PDFinfo: Codable, Equatable {
    var title: String
    var size: String
    var dateTime: String
    var pageCount: String
    var pdfName: String
    var isFavorite: String
    var lastAccessedDate: String
    var folderPath: String
    var storageAccountName: String
    var containerName: String
    var blobName: String
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
    
    @IBOutlet weak var btn_mainText: UIButton!
    @IBOutlet weak var btn_text: UIButton!
    
    @IBOutlet weak var btn_mainDelete: UIButton!
    @IBOutlet weak var btn_delete: UIButton!
    @IBOutlet weak var btn_txtDelete: UIButton!
    
    @IBOutlet weak var btnMainPrint: UIButton!
    @IBOutlet weak var btn_Print: UIButton!
    @IBOutlet weak var btn_Print_Text: UIButton!
    
    @IBOutlet weak var btn_back: UIButton!
    
    @IBOutlet weak var btn_edit: UIButton!
    @IBOutlet weak var btn_printer: UIButton!
    
    //UILabel:
    @IBOutlet weak var lbl_text: UILabel!
    @IBOutlet weak var lbl_title: UILabel!
    //@IBOutlet weak var lbl_pgNumbers: UILabel!
    
    //UIPageController:
    @IBOutlet weak var pageController: UIPageControl!
    
    //MARK: - Properties
    //pdfView:
    var pdfView = PDFView()
    var documents = PDFDocument()
    var pdfNewName:String = ""
    var existingPdfName:String = ""
    var curFolderPath:String = ""
    var editPDF:type = .add
    
    //model:
    var modelPDF : PDFinfo!
    var arrModelPdf = [PDFinfo]()
    
    //var arrPDF : [PDFinfo]()
    
    //imagePicker:
    var picker: UIImagePickerController? = UIImagePickerController()
//    var arrImage = [UIImage]()
    var pdfURL = URL(string: "")
//    var transferedImage:[UIImage]!
    
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
        
        self.btn_text.isUserInteractionEnabled = false
        self.btn_delete.isUserInteractionEnabled = false
        self.btn_Print.isUserInteractionEnabled = false
        self.btn_txtAdd.isUserInteractionEnabled = false
        self.btn_txtShare.isUserInteractionEnabled = false
        
        self.btn_txtDelete.isUserInteractionEnabled = false
        self.btn_Print_Text.isUserInteractionEnabled = false
        
        self.pdfView.delegate = self
        
        self.pdfView.isUserInteractionEnabled = false
        
     
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //pdfView.usePageViewController(true)
        
        if let tabbar = self.tabBarController as? TabBarViewController {
            tabbar.menuButton.isHidden = true
        }
        
        if editPDF == .add{
            self.lbl_title.text = "\(modelPDF.title)"
            self.displayPdf()
            editPDF = .edit
            pdfView.document = documents
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
        displayAlertWithTitle(AppName, andMessage: "Please select a save option", buttons: ["Finish and Upload", "Save as Draft (Offline)", "Back without saving", "Cancel"]) { index in
            if index == 0{
                showIndicator()
                ApiService.shared.uploadPDF(storageAccountName: self.modelPDF.storageAccountName, containerName: self.modelPDF.containerName, blobName: self.modelPDF.blobName) { result in
                    switch result {
                    case .success(_):
                        print("Upload Success :--->>> \(self.modelPDF.containerName) / \(self.modelPDF.blobName)")
                        DispatchQueue.main.async {
                            hideIndicator()
                            self.navigationController?.popViewController(animated: true)
                            self.tabBarController?.tabBar.isHidden = false
                        }
                    case .failure(let failure):
                        hideIndicator()
                        print("Upload Failer :--->> ", failure.localizedDescription)
                    }
                }
            }else{
                if index == 2{
                    let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                    let docURL = documentDirectory.appendingPathComponent(self.modelPDF.pdfName)
                    try? self.documents.dataRepresentation()?.write(to: docURL)
                }
                if index != 3{
                    self.navigationController?.popViewController(animated: true)
                    self.tabBarController?.tabBar.isHidden = false
                }
            }
        }
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
    
//    @IBAction func btn_mainSignature(_ sender: Any) {
//        editPDF = .edit
//        let previewController = QLPreviewController()
//        previewController.dataSource = self
//        previewController.delegate = self
//        previewController.setEditing(true, animated: true)
//        self.present(previewController, animated: true, completion: nil)
//    }
    
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
//    func createPDF(){
//        
//        let pdfDocument = PDFDocument()
//        // Insert the PDF page into your document
//        for index in transferedImage.indices
//        {
//            let pdfPage = PDFPage(image: transferedImage[index])
//            pdfDocument.insert(pdfPage!, at: index)
//        }
//        
//        
//        
//        let data = pdfDocument.dataRepresentation()
////        
////        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
////        
////        let docURL = documentDirectory.appendingPathComponent()
//        
//            let documentDirectory = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
//            let docURL = documentDirectory.appendingPathComponent(self.modelPDF.pdfName)
//
//           
////
////     // true
//        
//        print("createURL:\(docURL)")
//        
//        do{
//            try data?.write(to: docURL)
//        }catch(let error){
//            print("error is \(error.localizedDescription)")
//        }
//        
//        //set pageCount and pdfSize:
//        modelPDF.pageCount = "\((pdfView.document?.pageCount) ?? 1) page"
//        modelPDF.size = "\(fileSize(fromPath: "\(docURL.path)") ?? "")"
//        
//        appDelegate.arrPDFinfo.append(self.modelPDF)
//        appDelegate.setPdfInfoUserDefault()
//    }
    
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
//        let id = appDelegate.arrPDFinfo.firstIndex { info in
//            info.pdfName == self.modelPDF.pdfName
//        }
        
        //Update pdfSize and pageCount after insert each page:
//        appDelegate.arrPDFinfo[id ?? 0].pageCount = "\((pdfView.document?.pageCount) ?? 0) page"
//        appDelegate.arrPDFinfo[id ?? 0].size = "\(fileSize(fromPath: "\(docURL.path)") ?? "")"
        
//        appDelegate.setPdfInfoUserDefault()
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
//            let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
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
        let actionSheetController: UIAlertController = UIAlertController(title: AppName, message: "Are you sure you want to delete \(modelPDF.pdfName)?", preferredStyle: .alert)

        // create an action:
        let firstAction: UIAlertAction = UIAlertAction(title: "Yes", style: .default) { action -> Void in

            //get value of array:
//            let id = appDelegate.arrPDFinfo.firstIndex { info in
//                info.pdfName == self.modelPDF.pdfName
//            }
            
//            let idd = appDelegate.arrPDFinfo.remove(at: id ?? 0)
//            self.myClosure(appDelegate.arrPDFinfo)
//            appDelegate.setPdfInfoUserDefault()
            
            self.navigationController?.popViewController(animated: true)
            self.tabBarController?.tabBar.isHidden = false
            
            print("Yes pressed")
//            print(idd)
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
        
        return PreviewItem(url: docURL, title: (modelPDF.pdfName.split(separator: "/")).last?.string ?? "")
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

class PreviewItem: NSObject, QLPreviewItem {
    var previewItemURL: URL?
    var previewItemTitle: String?
    init(url: URL? = nil, title: String? = nil) {
        previewItemURL = url
        previewItemTitle = title
    }
}
