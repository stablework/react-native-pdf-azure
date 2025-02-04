//
//  TabBarViewController.swift
//  DocSign
//
//  Created by MAC on 04/02/23.
//

import UIKit
import PDFKit

import PhotosUI
import VisionKit

class TabBarViewController: UITabBarController, UITabBarControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    //MARK: - Properties
    let menuButton = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
    
    var navDocuments:UINavigationController!
    var navSettings:UINavigationController!
    var documentsViewController: DocumentsViewController?

    var picker: UIImagePickerController? = UIImagePickerController()
    
    var pdfView = PDFView()
    var pdfDocument: PDFDocument!
    var toggleButtonVisibility: ((Bool) -> Void)?
    
    //MARK: - ViewController life cycle method
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.backgroundColor = .systemGray2
        self.tabBarController?.tabBar.isHidden = true
        self.delegate = self
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller1 = storyboard.instantiateViewController(withIdentifier: "DocumentsViewController") as! DocumentsViewController
        controller1.tabBarItem = UITabBarItem(title: "", image: nil, selectedImage: nil)
        navDocuments = UINavigationController(rootViewController: controller1)
        navDocuments.navigationBar.isHidden = true
        
//        let controller2 = storyboard.instantiateViewController(withIdentifier: "SettingsViewController") as! SettingsViewController
//        controller2.tabBarItem = UITabBarItem(title: "Settings", image: #imageLiteral(resourceName: "ic_settings"), selectedImage: #imageLiteral(resourceName: "ic_settings"))
//        navSettings = UINavigationController(rootViewController: controller2)
//        navSettings.navigationBar.isHidden = true
        self.documentsViewController = controller1
        self.viewControllers = [navDocuments, UINavigationController()]
        
        picker?.delegate = self
        
        //to set app_themeColor to tint color of button while they're selecting:
        UITabBar.appearance().tintColor = UIColor(named: "app_themeColor")
        appDelegate.registerNotification()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleToggleButtonVisibility(_:)), name: Notification.Name("ToggleButtonVisibility"), object: nil)
    }
    
    @objc private func handleToggleButtonVisibility(_ notification: Notification) {
        if let isVisible = notification.userInfo?["isVisible"] as? Bool {
            print("Button visibility is now: \(isVisible)")
            // Implement visibility logic here
            menuButton.isHidden = !isVisible
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name("ToggleButtonVisibility"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        self.setupMiddleButton()
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController.tabBarItem.title == nil{
            return false
        }
        return true
    }
    
    func toggleCustomButtonVisibility(isHidden: Bool) {
        menuButton.isHidden = isHidden
       }
    
    // TabBarButton – Setup Middle Button
    func setupMiddleButton() {
        var menuButtonFrame = menuButton.frame
        menuButtonFrame.origin.y = self.tabBar.yPos - ((menuButtonFrame.height / 2) - 12)
        menuButtonFrame.origin.x = self.view.frame.width / 2 - menuButtonFrame.size.width / 2
        menuButton.frame = menuButtonFrame
        menuButton.backgroundColor = .white
        menuButton.layer.cornerRadius = menuButtonFrame.height/2
        menuButton.setBackgroundImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        menuButton.tintColor = UIColor(named: "app_themeColor")
        menuButton.addTarget(self, action: #selector(TabBarViewController.menuButtonAction), for: UIControl.Event.touchUpInside)
        self.view.addSubview(menuButton)
        toggleButtonVisibility = { [weak self] isHidden in
            self?.menuButton.isHidden = isHidden
             }
        self.view.layoutIfNeeded()
    }
    
    // Menu Button Touch Action
    @objc func menuButtonAction(sender: UIButton) {
        self.actionSheet()
    }
    
    func actionSheet(){
        let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // create an action
        let firstAction: UIAlertAction = UIAlertAction(title: "Create PDF", style: .default) { action -> Void in
            self.createNewPDF()
        }
        let secondAction: UIAlertAction = UIAlertAction(title: "Choose Photo", style: .default) { action -> Void in
            self.openGalary()
        }
        let thirdAction: UIAlertAction = UIAlertAction(title: " Browse...", style: .default) { action -> Void in
            self.openFileManager()
        }
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
        }
        
        firstAction.setValue(UIColor(named: "app_themeColor"), forKey: "titleTextColor")
        secondAction.setValue(UIColor(named: "app_themeColor"), forKey: "titleTextColor")
        thirdAction.setValue(UIColor(named: "app_themeColor"), forKey: "titleTextColor")
        cancelAction.setValue(UIColor(named: "app_themeColor"), forKey: "titleTextColor")
        
        // add actions
        actionSheetController.addAction(firstAction)
        actionSheetController.addAction(secondAction)
        actionSheetController.addAction(thirdAction)
        actionSheetController.addAction(cancelAction)
        
        self.present(actionSheetController, animated: true) {
            print("option menu presented")
        }
    }
    
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//        //picker.dismiss(animated: true, completion: nil)
//        if let pickedImage = info[.editedImage] as? UIImage {
//            picker.dismiss(animated: true, completion: nil)
//            if let secondVC = self.storyboard?.instantiateViewController(withIdentifier: "DocumentsDetailViewController") as? DocumentsDetailViewController {
//                secondVC.editPDF = .add
//                secondVC.transferedImage = []
//                secondVC.hidesBottomBarWhenPushed = true
//                self.navigationController?.pushViewController(secondVC, animated: true)
//                
//            }
//        }
//    }
//    
    func openGalary() {
//        picker?.allowsEditing = true
//        picker?.sourceType = UIImagePickerController.SourceType.photoLibrary
//        present(picker!, animated: true, completion: nil)
        var  config = PHPickerConfiguration()
        config.selectionLimit = 5
        config.filter = .images

        let phPicker = PHPickerViewController(configuration: config)
        phPicker.delegate = self
        present(phPicker,animated: true)
    }
    
    func openFileManager() {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.pdf], asCopy: true)
        documentPicker.allowsMultipleSelection = true
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        present(documentPicker, animated: true, completion: nil)
        
    }
    
    func createNewPDF() {
        if let documentVC = self.documentsViewController {
            let currentFolderPath = documentVC.currentFolderPath
            promptForFileName { pdfNewName in
                guard let pdfNewName = pdfNewName else {
                    print("User canceled or entered an invalid name.")
                    return
                }
                
                // Generate empty images (replace `desiredPageCount` with the number of pages needed)
                let desiredPageCount = 5 // Example: 5 blank pages
                let selectedImages = self.generateEmptyImages(count: desiredPageCount)
                
                let pdfDocument = PDFDocument()
                
                for (index, image) in selectedImages.enumerated() {
                    let pdfPage = PDFPage(image: image)
                    pdfDocument.insert(pdfPage!, at: index)
                }
                let data = pdfDocument.dataRepresentation()
                
                
                //current date and time:
                let currentDate = Date()
                var dateFormatter = DateFormatter()
                
                //Current time:
                dateFormatter.dateFormat = "d MMM,yyyy | HH:mm:ss"
                let c_dateTime = dateFormatter.string(from: currentDate)
                
                //Replace space(" ") with "_":
                dateFormatter.dateFormat = "d MMM yyyy HH mm ss"
                let dateTime = dateFormatter.string(from: currentDate)
                
                let finalFileName = pdfNewName.isEmpty ? "PDF \(c_dateTime)" : pdfNewName
                let formattedFileName = finalFileName.replacingOccurrences(of: " ", with: "_")

                // Construct document directory path
                let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                var destinationPath = documentDirectory.appendingPathComponent(formattedFileName).appendingPathExtension("pdf")

                // Get file size
                let fileSize = self.fileSize(fromPath: "\(destinationPath.path)")
                
                print("User entered file name: \(pdfNewName)")
                
                print("createURL:\(destinationPath)")
                
                do{
                    try data?.write(to: destinationPath)
                    let pdfDocument = PDFDocument(url: destinationPath) ?? PDFDocument()
                    // Create PDFinfo model
                    var pdfModel = PDFinfo(
                        title: finalFileName,
                        size: "\(fileSize ?? "")",
                        dateTime: "\(c_dateTime)",
                        pageCount: "\("") page",
                        pdfName: "\(formattedFileName).pdf",
                        isFavorite: "false",
                        lastAccessedDate: "\(dateTime)",
                        folderPath: ""
                    )
                    //set pageCount and pdfSize:
                    pdfModel.pageCount = "\((pdfDocument.pageCount)) page"
                    pdfModel.size = fileSize ?? ""
                    
                    self.navigateToDocumentDetailScreen(pdfDocument: pdfDocument, url: destinationPath, pdfModel: pdfModel)
                }catch(let error){
                    print("error is \(error.localizedDescription)")
                }
            }
        }
    }
    
    func promptForFileName(completion: @escaping (String?) -> Void) {
        // Create an alert controller
        let alertController = UIAlertController(title: "Enter File Name", message: "Please provide a name for your file.", preferredStyle: .alert)

        // Add a text field to the alert
        alertController.addTextField { textField in
            textField.placeholder = "File Name"
        }

        // Add an "OK" action
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            let fileName = alertController.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            completion(fileName?.isEmpty == false ? fileName : nil)
        }

        // Add a "Cancel" action
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            completion(nil) // User canceled, return nil
        }

        alertController.addAction(okAction)
        alertController.addAction(cancelAction)

        // Present the alert
        if let topController = UIApplication.shared.keyWindow?.rootViewController {
            topController.present(alertController, animated: true, completion: nil)
        }
    }
    
    func generateEmptyImages(count: Int, size: CGSize = CGSize(width: 612, height: 792)) -> [UIImage] {
        var emptyImages: [UIImage] = []
        for _ in 0..<count {
            UIGraphicsBeginImageContext(size)
            let context = UIGraphicsGetCurrentContext()
            context?.setFillColor(UIColor.white.cgColor)
            context?.fill(CGRect(origin: .zero, size: size))
            if let image = UIGraphicsGetImageFromCurrentImageContext() {
                emptyImages.append(image)
            }
            UIGraphicsEndImageContext()
        }
        return emptyImages
    }
    
    private func generateBoundaryString() -> String {
        return "Boundary-\(UUID().uuidString)"
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
   
    func createPDF(){
        
        let data = pdfView.document?.dataRepresentation()
        
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        let docURL = documentDirectory.appendingPathComponent("Scanned-Docs.pdf")
        
        do{
            try data?.write(to: docURL)
        }catch(let error){
            print("error is \(error.localizedDescription)")
        }
    }
}


extension TabBarViewController:PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        // Process the scanned pages
        let dispatchGroup = DispatchGroup()
        
        let pdfDocument = PDFDocument()
        
        for (pageNumber, result) in results.enumerated() {
            dispatchGroup.enter()
            result.itemProvider.loadObject(ofClass: UIImage.self) { imageObject, error in
                if let image = imageObject as? UIImage {
                    let pdfPage = PDFPage(image: image)
                    pdfDocument.insert(pdfPage!, at: pageNumber)
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            let data = pdfDocument.dataRepresentation()
            
            //current date and time:
            let currentDate = Date()
            var dateFormatter = DateFormatter()
            var pdfNewName:String = ""
            
            //Current time:
            dateFormatter.dateFormat = "d MMM,yyyy | HH:mm:ss"
            let c_dateTime = dateFormatter.string(from: currentDate)
            
            //Replace space(" ") with "_":
            dateFormatter.dateFormat = "d MMM yyyy HH mm ss"
            let dateTime = dateFormatter.string(from: currentDate)
            
            let finalFileName = pdfNewName.isEmpty ? "PDF \(c_dateTime)" : pdfNewName
            let formattedFileName = finalFileName.replacingOccurrences(of: " ", with: "_")

            // Construct document directory path
            let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            var destinationPath = documentDirectory.appendingPathComponent(formattedFileName).appendingPathExtension("pdf")

            // Get file size
            let fileSize = self.fileSize(fromPath: "\(destinationPath.path)")
            
            print("createURL:\(destinationPath)")
            
            do{
                try data?.write(to: destinationPath)
                let pdfDocument = PDFDocument(url: destinationPath) ?? PDFDocument()
                // Create PDFinfo model
                var pdfModel = PDFinfo(
                    title: finalFileName,
                    size: "\(fileSize ?? "")",
                    dateTime: "\(c_dateTime)",
                    pageCount: "\("") page",
                    pdfName: "\(formattedFileName).pdf",
                    isFavorite: "false",
                    lastAccessedDate: "\(dateTime)",
                    folderPath: ""
                )
                //set pageCount and pdfSize:
                pdfModel.pageCount = "\((pdfDocument.pageCount)) page"
                pdfModel.size = fileSize ?? ""
                
                self.navigateToDocumentDetailScreen(pdfDocument: pdfDocument, url: destinationPath, pdfModel: pdfModel)
            }catch(let error){
                print("error is \(error.localizedDescription)")
            }
        }
    }
}

extension TabBarViewController:VNDocumentCameraViewControllerDelegate {
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        let pdfDocument = PDFDocument()
        
        for pageNumber in 0..<scan.pageCount {
            let image = scan.imageOfPage(at: pageNumber)
            let pdfPage = PDFPage(image: image)
            pdfDocument.insert(pdfPage!, at: pageNumber)
        }
        let data = pdfDocument.dataRepresentation()
        
        //current date and time:
        let currentDate = Date()
        var dateFormatter = DateFormatter()
        var pdfNewName:String = ""
        
        //Current time:
        dateFormatter.dateFormat = "d MMM,yyyy | HH:mm:ss"
        let c_dateTime = dateFormatter.string(from: currentDate)
        
        //Replace space(" ") with "_":
        dateFormatter.dateFormat = "d MMM yyyy HH mm ss"
        let dateTime = dateFormatter.string(from: currentDate)
        
        let finalFileName = pdfNewName.isEmpty ? "PDF \(c_dateTime)" : pdfNewName
        let formattedFileName = finalFileName.replacingOccurrences(of: " ", with: "_")

        // Construct document directory path
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        var destinationPath = documentDirectory.appendingPathComponent(formattedFileName).appendingPathExtension("pdf")

        // Get file size
        let fileSize = fileSize(fromPath: "\(destinationPath.path)")
        
        
        
        print("createURL:\(destinationPath)")
        
        do{
            try data?.write(to: destinationPath)
            let pdfDocument = PDFDocument(url: destinationPath) ?? PDFDocument()
            
            // Create PDFinfo model
            var pdfModel = PDFinfo(
                title: finalFileName,
                size: "\(fileSize ?? "")",
                dateTime: "\(c_dateTime)",
                pageCount: "\("") page",
                pdfName: "\(formattedFileName).pdf",
                isFavorite: "false",
                lastAccessedDate: "\(dateTime)",
                folderPath: ""
            )
            //set pageCount and pdfSize:
            pdfModel.pageCount = "\((pdfDocument.pageCount)) page"
            pdfModel.size = fileSize ?? ""
            
            navigateToDocumentDetailScreen(pdfDocument: pdfDocument, url: destinationPath, pdfModel: pdfModel)
        }catch(let error){
            print("error is \(error.localizedDescription)")
        }
    }
}
extension TabBarViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        if let url = urls.first {
            let originPath = url
            
            //current date and time:
            let currentDate = Date()
            var dateFormatter = DateFormatter()
            var pdfNewName:String = ""
            
            //Current time:
            dateFormatter.dateFormat = "d MMM,yyyy | HH:mm:ss"
            let c_dateTime = dateFormatter.string(from: currentDate)
            
            //Replace space(" ") with "_":
            dateFormatter.dateFormat = "d MMM yyyy HH mm ss"
            let dateTime = dateFormatter.string(from: currentDate)
            
            let finalFileName = pdfNewName.isEmpty ? "PDF \(c_dateTime)" : pdfNewName
            let formattedFileName = finalFileName.replacingOccurrences(of: " ", with: "_")

            // Construct document directory path
            let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

            let destinationPath = documentDirectory.appendingPathComponent(formattedFileName).appendingPathExtension("pdf")
            
            // Get file size
            let fileSize = fileSize(fromPath: "\(destinationPath.path)")
            
            do{
                try FileManager.default.moveItem(at: originPath, to: destinationPath)
                let pdfDocument = PDFDocument(url: url) ?? PDFDocument()
                
                // Create PDFinfo model
                var pdfModel = PDFinfo(
                    title: finalFileName,
                    size: "\(fileSize ?? "")",
                    dateTime: "\(c_dateTime)",
                    pageCount: "\("") page",
                    pdfName: "\(formattedFileName).pdf",
                    isFavorite: "false",
                    lastAccessedDate: "\(dateTime)",
                    folderPath: ""
                )
                //set pageCount and pdfSize:
                pdfModel.pageCount = "\((pdfDocument.pageCount)) page"
                pdfModel.size = fileSize ?? ""
                
                navigateToDocumentDetailScreen(pdfDocument: pdfDocument, url: url, pdfModel: pdfModel)
            }catch{
                print(error.localizedDescription)
            }
        }
        
     }

     // Delegate method to handle user's cancellation
     func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
         // Handle cancellation if necessary
     }
    
    func navigateToDocumentDetailScreen(pdfDocument:PDFDocument, url:URL, pdfModel:PDFinfo){
        self.dismiss(animated: true)
        
        appDelegate.arrPDFinfo.append(pdfModel)
        appDelegate.setPdfInfoUserDefault()
        
        
        if let secondVC = self.storyboard?.instantiateViewController(withIdentifier: "DocumentsDetailViewController") as? DocumentsDetailViewController {
            secondVC.editPDF = .edit
            secondVC.pdfURL = url
            secondVC.documents = pdfDocument
            secondVC.modelPDF = pdfModel
            secondVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(secondVC, animated: true)
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
}
