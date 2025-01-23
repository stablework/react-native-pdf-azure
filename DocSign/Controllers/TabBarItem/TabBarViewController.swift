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
//        let scannerViewController = VNDocumentCameraViewController()
//        scannerViewController.delegate = self
//        present(scannerViewController, animated: true)
//        picker?.allowsEditing = true
//        picker?.sourceType = UIImagePickerController.SourceType.camera
//        present(picker!, animated: true, completion: nil)
        promptForFileName { fileName in
                guard let fileName = fileName else {
                    print("User canceled or entered an invalid name.")
                    return
                }

                print("User entered file name: \(fileName)")

                // Generate empty images (replace `desiredPageCount` with the number of pages needed)
                let desiredPageCount = 5 // Example: 5 blank pages
            let selectedImages = self.generateEmptyImages(count: desiredPageCount)
            if let documentVC = self.documentsViewController {
                 let currentFolderPath = documentVC.currentFolderPath
                 print("Current Folder Path: \(currentFolderPath)")
                DispatchQueue.main.async {
                    self.dismiss(animated: true) {
                        if let secondVC = self.storyboard?.instantiateViewController(withIdentifier: "DocumentsDetailViewController") as? DocumentsDetailViewController {
                            
                            secondVC.editPDF = .add
                            secondVC.pdfNewName = fileName
                            secondVC.transferedImage = selectedImages
                            secondVC.curFolderPath = currentFolderPath
                            secondVC.hidesBottomBarWhenPushed = true
                            self.navigationController?.pushViewController(secondVC, animated: true)
                        }
                    }
                }
                 
                 // Perform your logic with currentFolderPath here
             } else {
                 print("DocumentViewController not found")
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
        
//        if let secondVC = self.storyboard?.instantiateViewController(withIdentifier: "DocumentsDetailViewController") as? DocumentsDetailViewController {
//            secondVC.editPDF = .add
//            secondVC.transferedImage = pickedImage
//            secondVC.hidesBottomBarWhenPushed = true
//            self.navigationController?.pushViewController(secondVC, animated: true)
//            
//        }
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
            if let secondVC = self.storyboard?.instantiateViewController(withIdentifier: "DocumentsDetailViewController") as? DocumentsDetailViewController {
                     secondVC.editPDF = .add
                     secondVC.transferedImage = selectedImages
                     secondVC.hidesBottomBarWhenPushed = true
                     self.navigationController?.pushViewController(secondVC, animated: true)
         
                 }
        }
        
//
        
    }
    
    
    
}

extension TabBarViewController:VNDocumentCameraViewControllerDelegate {
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        // Process the scanned pages
        let dispatchGroup = DispatchGroup()
        
        var selectedImages:[UIImage] = [UIImage]()
        var lastImage:UIImage!
        for pageNumber in 0..<scan.pageCount {
            dispatchGroup.enter()
            let image = scan.imageOfPage(at: pageNumber)
            print(image)
            selectedImages.append(image)
            print(selectedImages.count)
            lastImage = image
            dispatchGroup.leave()
        }

        // You are responsible for dismissing the controller.
        dispatchGroup.notify(queue: .main) {
            controller.dismiss(animated: true)
            if let secondVC = self.storyboard?.instantiateViewController(withIdentifier: "DocumentsDetailViewController") as? DocumentsDetailViewController {
                     secondVC.editPDF = .add
                     secondVC.transferedImage = selectedImages
                     secondVC.hidesBottomBarWhenPushed = true
                     self.navigationController?.pushViewController(secondVC, animated: true)
         
                 }
        }
       
    }
}
extension TabBarViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        
        let dispatchGroup = DispatchGroup()
        
        var selectedImages:[UIImage] = [UIImage]()
        
        if let url = urls.first {
                  
                   pdfDocument = PDFDocument(url: url)
            for pageIndex in 0..<pdfDocument.pageCount {
                        guard let pdfPage = pdfDocument.page(at: pageIndex) else { continue }

                        // Render PDF page as image
                        let pageRect = pdfPage.bounds(for: .cropBox)
                        UIGraphicsBeginImageContext(pageRect.size)
                        guard let context = UIGraphicsGetCurrentContext() else { return }
                        context.translateBy(x: 0.0, y: pageRect.size.height)
                        context.scaleBy(x: 1.0, y: -1.0)
                        pdfPage.draw(with: .mediaBox, to: context)
                        let pageImage = UIGraphicsGetImageFromCurrentImageContext()
                        UIGraphicsEndImageContext()

                        if let pageImage = pageImage {
                            selectedImages.append(pageImage)
                        }
                    }
                   
               }
//                for url in urls {
//                    dispatchGroup.enter()
//                    do {
//                        let imageData = try Data(contentsOf: url)
//                        if let image = UIImage(data: imageData) {
//                            selectedImages.append(image)
//                        }
//                    } catch {
//                        print("Error loading image at \(url): \(error.localizedDescription)")
//                    }
//                    dispatchGroup.leave()
//                }
        
                
        dispatchGroup.notify(queue: .main) {
            self.dismiss(animated: true)
            
            if let secondVC = self.storyboard?.instantiateViewController(withIdentifier: "DocumentsDetailViewController") as? DocumentsDetailViewController {
                     secondVC.editPDF = .add
                     secondVC.transferedImage = selectedImages
                     secondVC.hidesBottomBarWhenPushed = true
                     self.navigationController?.pushViewController(secondVC, animated: true)
         
                 }
        }
         
     }

     // Delegate method to handle user's cancellation
     func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
         // Handle cancellation if necessary
     }
}
