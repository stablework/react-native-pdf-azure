//
//  DocumentsViewController.swift
//  DocSign
//
//  Created by MAC on 03/02/23.
//

import UIKit
import PDFKit

import QuickLook
//import Lottie

class DocumentsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {

//MARK: - Outlets
    @IBOutlet weak var lblNavigationTitle: UILabel!
    @IBOutlet weak var tblView_documents: UITableView!
    @IBOutlet weak var view_noDocumentsAdded: UIView!
//    @IBOutlet weak var img_noDocuments: LottieAnimationView!
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
    
    @IBOutlet weak var backBtn: UIButton!
    
    
 
//MARK: - Properties
    
    var dateFormatter = DateFormatter()
    let currentDate = Date()
    let pdfView = PDFView()
    var containerName = ""{
        didSet{
            if currentFolderPath.isEmpty{
                lblNavigationTitle.text = containerName.isEmpty ? "Cook PDF App" : containerName
            }
        }
    }
    
    var pdfName:String = ""
    var nameOfPDF:String = ""
    var pdfURL:URL = URL(fileURLWithPath: "")
        
    var dict: [[String: Any]] = []
    
    var modelPDF : PDFinfo!
    var currentFolderPath: String = ""{
        didSet{
            let lastPath = currentFolderPath.split(separator: "/").last?.string ?? ""
            lblNavigationTitle.text = lastPath.isEmpty ? containerName.isEmpty ? "Cook PDF App" : containerName : lastPath
        }
    }

    var selectedIndex:IndexPath?
    
    // Fixed folders
    let fixedFolders = ["Recent", "Favorite"]
    
    var showFixedFolders = true // Flag to show/hide "Recent" and "Favorite"
    
    var isRecent = false
    var isFav = false

//MARK: - ViewController life cycle method
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarController?.tabBar.isHidden = false
        
        self.tabBarController?.tabBar.layer.shadowColor = UIColor.systemGray4.cgColor
        self.tabBarController?.tabBar.layer.shadowOpacity = 1
        
        view_noDocumentsAdded.isHidden = true
        tblView_documents.isHidden = false
        
        self.tblView_documents.reloadData()
        
//        img_noDocuments?.animation = .named("noPDF")
//         
//        img_noDocuments!.loopMode = .loop
//         
//        img_noDocuments!.play()
        
        tblView_documents.separatorStyle = .singleLine
        tblView_documents.separatorColor = UIColor.gray
        tblView_documents.separatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        
        backBtn.isHidden = true
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("setContainer"), object: nil, queue: .main) { _ in
            self.tblView_documents.reloadData()
        }
    }
    
    private func downloadPDF(containerName:String,blobName:String, completionHandler:@escaping ()->Void) {
        let storageAccountName = storageAccountName
        showIndicator()
        ApiService.shared.PDFDownLoad(storageAccountName: storageAccountName, containerName: containerName, blobName: blobName) { result in
            switch result {
            case .success(let pdfData):
                // Create a temporary file for the PDF data
                let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let tempURL = documentDirectory.appendingPathComponent(containerName+blobName.replacingOccurrences(of: "/", with: ""))
                do {
                    try pdfData.write(to: tempURL)
                    
                    DispatchQueue.main.async {
                        hideIndicator()
                        completionHandler()
                        // Set up and present the QLPreviewController
                    }
                } catch {
                    hideIndicator()
                    print("Error saving PDF to temporary file: \(error)")
                }
            case .failure(let error):
                hideIndicator()
                print("Error fetching containers: \(error.localizedDescription)")
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let tabbar = self.tabBarController as! TabBarViewController
        tabbar.menuButton.isHidden = false
        self.tabBarController?.tabBar.isHidden = false
//        appDelegate.getPdfInfoUserDefault()
        self.tblView_documents.reloadData()
       
    }
    override func viewDidAppear(_ animated: Bool) {
      
    }
  

    @IBAction func handleBack(_ sender: Any) {
        if isRecent {
            self.isRecent = false
            self.tblView_documents.reloadData()
            backBtn.isHidden = true
            NotificationCenter.default.post(name: Notification.Name("ToggleButtonVisibility"), object: nil, userInfo: ["isVisible": true])
        }
        if isFav {
            self.isFav = false
            self.tblView_documents.reloadData()
            backBtn.isHidden = true
            NotificationCenter.default.post(name: Notification.Name("ToggleButtonVisibility"), object: nil, userInfo: ["isVisible": true])
        }
        if currentFolderPath != "" {
            let slashCount = self.currentFolderPath.split(separator: "/").count
            if(slashCount > 0) {
//                if let lastSlashIndex = currentFolderPath.lastIndex(of: "/") {
//                    // Remove the last segment after the last "/"
//                    currentFolderPath.removeSubrange(lastSlashIndex..<currentFolderPath.endIndex)
//                }
                var path = self.currentFolderPath.split(separator: "/")
                path.removeLast()
                currentFolderPath = path.joined(separator: "/")
            }else {
                self.currentFolderPath = ""
                self.containerName = ""
                self.showFixedFolders = true
                backBtn.isHidden = true
            }
            self.tblView_documents.reloadData()
        }else {
            self.currentFolderPath = ""
            self.containerName = ""
            self.showFixedFolders = true
            backBtn.isHidden = true
            self.tblView_documents.reloadData()
        }
    }
    
//    func menu(indexPath:IndexPath,showRemovePass:Bool, curFile: PDFinfo) -> UIMenu {
//        let itemMenu = UIMenu(options: .displayInline,children: [
//            //go to edit pdf screen
//            UIAction(title: "Edit",image: UIImage(systemName: "pencil") ,handler: { _ in
//                let vc = self.storyboard?.instantiateViewController(withIdentifier: "DocumentsDetailViewController") as! DocumentsDetailViewController
//                vc.editPDF = .edit
//                vc.modelPDF = curFile
//                vc.hidesBottomBarWhenPushed = true
//                vc.myClosure = { arr in
//                    appDelegate.arrPDFinfo = arr
//                    self.tblView_documents.reloadData()
//                }
//                self.navigationController?.pushViewController(vc, animated: true)
//            }),
//            //rename file
//           
//            UIAction(title: "Rename",image: UIImage(systemName: "doc.text") ,handler: { _ in
//                let dict = curFile
//                let alertController = UIAlertController(title: "Rename PDF", message: "", preferredStyle: .alert)
//                alertController.addTextField { (textfield) in
//                    let cachesDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
//                    let originPath = cachesDirectory.appendingPathComponent(dict.pdfName)
//                    textfield.text = originPath.deletingPathExtension().lastPathComponent
//                    textfield.placeholder = "Enter a new PDF name"
//                    textfield.becomeFirstResponder() // Show keyboard
//                    DispatchQueue.main.async{
//                        if let beginningOfText = textfield.beginningOfDocument as? UITextPosition{
//                            textfield.selectedTextRange = textfield.textRange(from: beginningOfText, to: beginningOfText)
//                        }
//                    }
//                }
//                let doneAction = UIAlertAction(title: "Done", style: .default) { (action) in
//                   if let newName = alertController.textFields?.first {
//                       let newPdfName = newName.text ?? "newFile"
//                       do {
//                           
//                           let path = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0]
//                           let documentDirectory = URL(fileURLWithPath: path)
//                           let originPath = documentDirectory.appendingPathComponent(dict.pdfName)
//                           var destinationPath = documentDirectory.appendingPathComponent(newPdfName)
//                           if destinationPath.pathExtension.isEmpty || destinationPath.pathExtension != "pdf"{
//                               destinationPath = destinationPath.appendingPathExtension(originPath.pathExtension)
//                           }
//                           try FileManager.default.moveItem(at: originPath, to: destinationPath)
//                           
//                           if let index = appDelegate.arrPDFinfo.firstIndex(where: { $0.lastAccessedDate == curFile.lastAccessedDate }) {
//                               appDelegate.arrPDFinfo[index].pdfName = destinationPath.lastPathComponent
//                           }
//
//                           self.tblView_documents.reloadData()
//                       } catch {
//                           print(error)
//                       }
//                    }
//                }
//                let cancelAction = UIAlertAction(title: "Cancel", style: .destructive) { _ in
//                    
//                }
//                alertController.addAction(cancelAction)
//                alertController.addAction(doneAction)
//                self.present(alertController, animated: true)
//                
//            }),
//
//            curFile.isFavorite == "false" ?
//            UIAction(title: "Add to Favorite",image: UIImage(systemName: "heart") ,handler: { _ in
//                if let index = appDelegate.arrPDFinfo.firstIndex(where: { $0.lastAccessedDate == curFile.lastAccessedDate }) {
//                    appDelegate.arrPDFinfo[index].isFavorite = "true"
//                    self.tblView_documents.reloadData()
//                }
//            }) :
//                UIAction(title: "Remove from Favorite",image: UIImage(systemName: "heart.fill") ,handler: { _ in
//                    if let index = appDelegate.arrPDFinfo.firstIndex(where: { $0.lastAccessedDate == curFile.lastAccessedDate }) {
//                        appDelegate.arrPDFinfo[index].isFavorite = "false"
//                        self.tblView_documents.reloadData()
//                    }
//                })
//        ])
//            
//        return itemMenu
//             
//     
//    }
    
    func menu(indexPath:IndexPath,showRemovePass:Bool, curFile: Blob) -> UIMenu {
        var containerName = self.containerName
        if let index = appDelegate.recentBlob.firstIndex(where: {$0.name == curFile.name}), (self.isRecent){
            containerName = appDelegate.recentBlob[index].containerName ?? ""
        }
        if let index = appDelegate.favouriteBlob.firstIndex(where: {$0.name == curFile.name}), (self.isFav){
            containerName = appDelegate.favouriteBlob[index].containerName ?? ""
        }
        
        let isFavourite = appDelegate.favouriteBlob.contains(where: {$0.name == curFile.name})
        let itemMenu = UIMenu(options: .displayInline,children: [
            //go to edit pdf screen
            UIAction(title: "Edit",image: UIImage(systemName: "pencil") ,handler: { _ in
                // Create PDFinfo model
                //current date and time:
                let currentDate = Date()
                let dateFormatter = DateFormatter()
                let containerName = self.isFav || self.isRecent ? (curFile.containerName ?? "") : self.containerName
                //Current time:
                dateFormatter.dateFormat = "d MMM,yyyy | HH:mm:ss"
                let c_dateTime = dateFormatter.string(from: currentDate)
                
                //Replace space(" ") with "_":
                dateFormatter.dateFormat = "d MMM yyyy HH mm ss"
                let dateTime = dateFormatter.string(from: currentDate)
                
                self.pdfName = containerName+(curFile.name?.replacingOccurrences(of: "/", with: "") ?? "")
                self.nameOfPDF = curFile.name ?? ""
                let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let tempURL = documentDirectory.appendingPathComponent(self.pdfName)
                let pdfDocument = PDFDocument(url: tempURL) ?? PDFDocument()
                let finalFileName = self.pdfName//(curFile.name?.split(separator: "/"))?.last?.string ?? ""
                let finalFileTitle = ((curFile.name?.split(separator: "/"))?.last?.string ?? "").replacingOccurrences(of: ".pdf", with: "")
                let fileSize = self.fileSize(fromPath: "\(tempURL.path)")
                var pdfModel = PDFinfo(
                    title: finalFileTitle,
                    size: "\(fileSize ?? "")",
                    dateTime: "\(c_dateTime)",
                    pageCount: "\("") page",
                    pdfName: finalFileName,
                    isFavorite: "false",
                    lastAccessedDate: "\(dateTime)",
                    folderPath: "", storageAccountName: storageAccountName, containerName: containerName, blobName: curFile.name ?? ""
                )
                //set pageCount and pdfSize:
                pdfModel.pageCount = "\((pdfDocument.pageCount)) page"
                pdfModel.size = fileSize ?? ""
                
                var blob = curFile
                blob.containerName = containerName
                dateFormatter.dateFormat = "d MMM yyyy HH mm ss"
                blob.properties?.lastModified = dateFormatter.string(from: Date())
                
                if let index = appDelegate.recentBlob.firstIndex(where: {$0.name == curFile.name}){
                    appDelegate.recentBlob[index] = blob
                }else{
                    appDelegate.recentBlob.append(blob)
                }
                
//                if appDelegate.internetIsAvailable{
//                    self.downloadPDF(containerName: containerName, blobName: (curFile.name ?? "")){
//                        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//                        let tempURL = documentDirectory.appendingPathComponent(self.pdfName)
//                        if let secondVC = self.storyboard?.instantiateViewController(withIdentifier: "DocumentsDetailViewController") as? DocumentsDetailViewController {
//                            secondVC.editPDF = .edit
//                            secondVC.pdfURL = tempURL
//                            secondVC.documents = pdfDocument
//                            secondVC.modelPDF = pdfModel
//                            secondVC.hidesBottomBarWhenPushed = true
//                            self.navigationController?.pushViewController(secondVC, animated: true)
//                        }
//                    }
//                }else {
//                    
//                }
                
                if FileManager.default.fileExists(atPath: tempURL.path){
                    if let secondVC = self.storyboard?.instantiateViewController(withIdentifier: "DocumentsDetailViewController") as? DocumentsDetailViewController {
                        secondVC.editPDF = .edit
                        secondVC.pdfURL = tempURL
                        secondVC.documents = pdfDocument
                        secondVC.modelPDF = pdfModel
                        secondVC.hidesBottomBarWhenPushed = true
                        self.navigationController?.pushViewController(secondVC, animated: true)
                    }
                }else{
                    
                    self.downloadPDF(containerName: containerName, blobName: (curFile.name ?? "")){
                        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                        let tempURL = documentDirectory.appendingPathComponent(self.pdfName)
                        if let secondVC = self.storyboard?.instantiateViewController(withIdentifier: "DocumentsDetailViewController") as? DocumentsDetailViewController {
                            secondVC.editPDF = .edit
                            secondVC.pdfURL = tempURL
                            secondVC.documents = pdfDocument
                            secondVC.modelPDF = pdfModel
                            secondVC.hidesBottomBarWhenPushed = true
                            self.navigationController?.pushViewController(secondVC, animated: true)
                        }
                    }
                }
            }),
            //rename file
            
//            UIAction(title: "Rename",image: UIImage(systemName: "doc.text") ,handler: { _ in
//                let dict = curFile
//                let alertController = UIAlertController(title: "Rename PDF", message: "", preferredStyle: .alert)
//                alertController.addTextField { (textfield) in
//                    let cachesDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
//                    let originPath = cachesDirectory.appendingPathComponent((dict.name ?? ""))
//                    textfield.text = originPath.deletingPathExtension().lastPathComponent
//                    textfield.placeholder = "Enter a new PDF name"
//                    textfield.becomeFirstResponder() // Show keyboard
//                    DispatchQueue.main.async{
//                        if let beginningOfText = textfield.beginningOfDocument as? UITextPosition{
//                            textfield.selectedTextRange = textfield.textRange(from: beginningOfText, to: beginningOfText)
//                        }
//                    }
//                }
//                let doneAction = UIAlertAction(title: "Done", style: .default) { (action) in
//                    if let newName = alertController.textFields?.first {
//                        let newPdfName = newName.text ?? "newFile"
//                        if !appDelegate.internetIsAvailable{
//                            displayAlertWithMessage("No Internet Connection!!")
//                            return
//                        }
//                        showIndicator()
//                        do {
//                            let cachesDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
//                            let originPath = cachesDirectory.appendingPathComponent(containerName + (dict.name?.replacingOccurrences(of: "/", with: "") ?? ""))
//                            let tempPath = cachesDirectory.appendingPathComponent(containerName + (dict.name ?? ""))
//                            let fileName = tempPath.deletingPathExtension().lastPathComponent.replacingOccurrences(of: containerName, with: "")
//                            var finalName = (dict.name ?? "").replacingOccurrences(of: fileName, with: newPdfName)
//                            var finalNameWithOutSlash = (dict.name ?? "").replacingOccurrences(of: fileName, with: newPdfName).replacingOccurrences(of: "/", with: "")
//                            var destinationPath = cachesDirectory.appendingPathComponent(containerName+finalNameWithOutSlash.replacingOccurrences(of: "/", with: ""))
//                            if destinationPath.pathExtension.isEmpty || destinationPath.pathExtension != "pdf"{
//                                finalNameWithOutSlash += ".pdf"
//                                destinationPath = cachesDirectory.appendingPathExtension(".pdf")
//                            }
//                            if FileManager.default.fileExists(atPath: originPath.path){
//                                print("from url :- ", originPath.path)
//                                print("to url :- ", destinationPath.path)
//                                
//                                try FileManager.default.moveItem(at: originPath, to: destinationPath)
//                            }
//                            
//                            let dateFormatter = DateFormatter()
//                            var blob = curFile
//                            blob.name = finalName
//                            blob.containerName = containerName
//                            dateFormatter.dateFormat = "d MMM yyyy HH mm ss"
//                            blob.properties?.lastModified = dateFormatter.string(from: Date())
//                            
//                            if let index = appDelegate.recentBlob.firstIndex(where: {$0.name == curFile.name}){
//                                appDelegate.recentBlob[index] = blob
//                            }else{
//                                appDelegate.recentBlob.append(blob)
//                            }
//                            
//                            if let index = appDelegate.favouriteBlob.firstIndex(where: {$0.name == curFile.name}){
//                                appDelegate.favouriteBlob[index] = blob
//                            }
//                            print("KKK;::____>>",containerName, (dict.name ?? ""), finalNameWithOutSlash)
//                            ApiService.shared.deletePDF(storageAccountName: storageAccountName, containerName: containerName, blobName: (dict.name ?? "")) { _ in
//                                DispatchQueue.main.async {
//                                    ApiService.shared.uploadPDF(storageAccountName: storageAccountName, containerName: containerName, blobName: finalName) { result in
//                                        hideIndicator()
//                                        DispatchQueue.main.async {
//                                            switch result {
//                                            case .success(_):
//                                                print("Upload Success :--->>> \(containerName) / \(newPdfName)")
//                                                appDelegate.fetchBlogs(containerName:containerName)
//                                            case .failure(let failure):
//                                                print("Upload Failer :--->> ", failure.localizedDescription)
//                                            }
//                                        }
//                                    }
//                                }
//                            }
//                        } catch {
//                            hideIndicator()
//                            print(error)
//                        }
//                    }
//                }
//                let cancelAction = UIAlertAction(title: "Cancel", style: .destructive) { _ in
//                    
//                }
//                alertController.addAction(cancelAction)
//                alertController.addAction(doneAction)
//                self.present(alertController, animated: true)
//                
//            }),
            
            !isFavourite ?
            UIAction(title: "Add to Favorite",image: UIImage(systemName: "heart") ,handler: { _ in
                let dateFormatter = DateFormatter()
                var blob = curFile
                blob.containerName = containerName
                dateFormatter.dateFormat = "d MMM yyyy HH mm ss"
                blob.properties?.lastModified = dateFormatter.string(from: Date())
                
                if let index = appDelegate.recentBlob.firstIndex(where: {$0.name == curFile.name}){
                    appDelegate.recentBlob[index] = blob
                }else{
                    appDelegate.recentBlob.append(blob)
                }
                appDelegate.favouriteBlob.append(blob)
                self.tblView_documents.reloadData()
            }) :
                UIAction(title: "Remove from Favorite",image: UIImage(systemName: "heart.fill") ,handler: { _ in
                    let dateFormatter = DateFormatter()
                    var blob = curFile
                    blob.containerName = containerName
                    dateFormatter.dateFormat = "d MMM yyyy HH mm ss"
                    blob.properties?.lastModified = dateFormatter.string(from: Date())
                    
                    if let index = appDelegate.recentBlob.firstIndex(where: {$0.name == curFile.name}){
                        appDelegate.recentBlob[index] = blob
                    }else{
                        appDelegate.recentBlob.append(blob)
                    }
                    appDelegate.favouriteBlob.removeAll(where: { $0.name == curFile.name })
                    self.tblView_documents.reloadData()
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
        if isRecent {
            return 1
        }
        
        if isFav {
            return 1
        }
        
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //recent blob Data
        if isRecent {
            return appDelegate.recentBlob.count
        }
        // favourite blob data
        if isFav {
            return appDelegate.favouriteBlob.count
        }
        
        // Main Home Screen
        if showFixedFolders {
            return section == 0 ? fixedFolders.count : appDelegate.container.count
        } else {
            let slashCount = self.currentFolderPath.split(separator: "/").count
            let lastPath = self.currentFolderPath.split(separator: "/").last ?? ""
            let arrFilter = appDelegate.blobdetailModel[containerName]?.blobs.blob.filter({ blob in
                let arrSplit = (blob.name?.split(separator: "/"))
                if arrSplit?.count ?? 0 > slashCount+1{
                    if slashCount-1 >= 0{
                        print(arrSplit, slashCount-1, (arrSplit?[slashCount-1] ?? "") == lastPath)
                        return (arrSplit?[slashCount-1] ?? "") == lastPath
                    }else{
                        return true
                    }
                }else{
                    return false
                }
            })
            
            let arrFolderNames:[String] = arrFilter?.map{ Blob in
                let name:[String.SubSequence] = (Blob.name?.split(separator: "/")) ?? []
                return name[slashCount].string
            } ?? []
            
            let arrFolder:[String] = Dictionary.init(grouping: arrFolderNames, by: {$0}).keys.sorted()
            
            print("\n\n\n------ documentCount -------")
            let documentCount = appDelegate.blobdetailModel[containerName]?.blobs.blob.filter({ blob in
                let arrSplit = (blob.name?.split(separator: "/"))
                print(arrSplit, arrSplit?.count, (slashCount+1), arrSplit?.count == (slashCount+1), slashCount, lastPath)
                return arrSplit?.count == (slashCount+1) && (arrSplit?[slashCount-1] ?? "") == lastPath
            }).count ?? 0
            print("------ documentCount -------")
            return section == 0 ? arrFolder.count : documentCount
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      
        let cell = tableView.dequeueReusableCell(withIdentifier: "DocumentsTableViewCell") as! DocumentsTableViewCell
        if isRecent || isFav{
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "d MMM yyyy HH mm ss"
            
            let slashCount = self.currentFolderPath.split(separator: "/").count
            
            let sortedPdfArray = (isRecent ? appDelegate.recentBlob : appDelegate.favouriteBlob).sorted { (pdf1, pdf2) -> Bool in
                guard let date1 = dateFormatter.date(from: pdf1.properties?.lastModified ?? ""),
                      let date2 = dateFormatter.date(from: pdf2.properties?.lastModified ?? "") else {
                    return false
                }
                return date1 > date2
            }
            let dict = sortedPdfArray[indexPath.row]
            let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let docURL = documentDirectory.appendingPathComponent(dict.name?.replacingOccurrences(of: "/", with: "") ?? "")
            let name = docURL.deletingPathExtension().lastPathComponent
                cell.lbl_title.text = name//(dict.name?.split(separator: "/"))?.last?.string ?? ""
                cell.img_profile.image = UIImage(systemName: "doc")
                cell.btn_editPdf.isHidden = false
                cell.selectionStyle = .gray
                cell.btn_editPdf.showsMenuAsPrimaryAction = true
                let pdfDocument = PDFDocument(url: docURL)
                cell.btn_editPdf.menu = self.menu(indexPath: indexPath,showRemovePass: pdfDocument?.isLocked ?? true, curFile: dict)
                cell.btn_editPdf.isHidden = false
                cell.lbl_fileNum.isHidden = true
            
        }
        else if(showFixedFolders) {
            if indexPath.section == 0 {
                cell.lbl_fileNum.isHidden = false
                cell.lbl_title.text = fixedFolders[indexPath.row]
                if fixedFolders[indexPath.row] == "Recent" {
                    cell.lbl_fileNum.text = String(appDelegate.recentBlob.count)
                    cell.img_profile?.image = UIImage(systemName: "clock") // Clock icon for Recent
                } else if fixedFolders[indexPath.row] == "Favorite" {
                    cell.img_profile?.image = UIImage(systemName: "star") // Star icon for Favorite
                    cell.lbl_fileNum.text = String(appDelegate.favouriteBlob.count)
                }
            } else {
                cell.lbl_fileNum.isHidden = true
                cell.lbl_title.text = appDelegate.container[indexPath.row].name
                cell.img_profile.image = UIImage(systemName: "folder")
            }
            cell.btn_editPdf.isHidden = true
            
        } else {
            cell.lbl_fileNum.isHidden = true
            if indexPath.section == 0 {
                let slashCount = self.currentFolderPath.split(separator: "/").count
                let lastPath = self.currentFolderPath.split(separator: "/").last ?? ""
                let arrFilter = appDelegate.blobdetailModel[containerName]?.blobs.blob.filter({ blob in
                    let arrSplit = (blob.name?.split(separator: "/"))
                    if arrSplit?.count ?? 0 > slashCount+1{
                        if slashCount-1 >= 0{
                            print(arrSplit, slashCount-1, (arrSplit?[slashCount-1] ?? "") == lastPath)
                            return (arrSplit?[slashCount-1] ?? "") == lastPath
                        }else{
                            return true
                        }
                    }else{
                        return false
                    }
                })
                
                let arrFolderNames:[String] = arrFilter?.map{ Blob in
                    let name:[String.SubSequence] = (Blob.name?.split(separator: "/")) ?? []
                    return name[slashCount].string
                } ?? []
                
                let arrFolder:[String] = Dictionary.init(grouping: arrFolderNames, by: {$0}).keys.sorted()
                
                cell.lbl_title.text = arrFolder[indexPath.row]///dict.name ?? ""
                cell.img_profile.image = UIImage(systemName: "folder")
                cell.btn_editPdf.isHidden = true
            } else {
                print(self.currentFolderPath)
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "d MMM yyyy HH mm ss"
                
                let slashCount = self.currentFolderPath.split(separator: "/").count
                let lastPath = self.currentFolderPath.split(separator: "/").last ?? ""
                
                let sortedPdfArray = appDelegate.blobdetailModel[containerName]?.blobs.blob.filter({ blob in
                    let arrSplit = (blob.name?.split(separator: "/"))
                    return arrSplit?.count == (slashCount+1) && (arrSplit?[slashCount-1] ?? "") == lastPath
                }).sorted { (pdf1, pdf2) -> Bool in
                    guard let date1 = dateFormatter.date(from: pdf1.properties?.lastModified ?? ""),
                          let date2 = dateFormatter.date(from: pdf2.properties?.lastModified ?? "") else {
                        return false
                    }
                    return date1 > date2 // Ascending order: change to date1 > date2 for descending order
                } ?? []
                
                let dict = sortedPdfArray[indexPath.row]
                
                let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let docURL = documentDirectory.appendingPathComponent(dict.name?.replacingOccurrences(of: "/", with: "") ?? "")
                let name = docURL.deletingPathExtension().lastPathComponent
                    cell.lbl_title.text = name//(dict.name?.split(separator: "/"))?.last?.string ?? ""
                    cell.img_profile.image = UIImage(systemName: "doc")
                    cell.btn_editPdf.isHidden = false
                    cell.selectionStyle = .gray
                    cell.btn_editPdf.showsMenuAsPrimaryAction = true
                    let pdfDocument = PDFDocument(url: docURL)
                    cell.btn_editPdf.menu = self.menu(indexPath: indexPath,showRemovePass: pdfDocument?.isLocked ?? true, curFile: dict)
                    cell.btn_editPdf.isHidden = false
                    cell.lbl_fileNum.isHidden = true
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.backBtn.isHidden = false
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMM yyyy HH mm ss"
        if isRecent || isFav{
            let sortedPdfArray = (isRecent ? appDelegate.recentBlob : appDelegate.favouriteBlob).sorted { (pdf1, pdf2) -> Bool in
                guard let date1 = dateFormatter.date(from: pdf1.properties?.lastModified ?? ""),
                      let date2 = dateFormatter.date(from: pdf2.properties?.lastModified ?? "") else {
                    return false
                }
                return date1 > date2
            }
            let dict = sortedPdfArray[indexPath.row]
            
            if let index = appDelegate.recentBlob.firstIndex(where: { $0.name == dict.name }) {
                appDelegate.recentBlob[index].properties?.lastModified = dateFormatter.string(from: Date())
            }
            pdfName = (dict.containerName ?? "")+(sortedPdfArray[indexPath.row].name ?? "").replacingOccurrences(of: "/", with: "")
            
            let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let docURL = documentDirectory.appendingPathComponent(dict.name?.replacingOccurrences(of: "/", with: "") ?? "")
            let name = docURL.deletingPathExtension().lastPathComponent
            nameOfPDF = name//(sortedPdfArray[indexPath.row].name ?? "")
            
            let tempURL = documentDirectory.appendingPathComponent(pdfName)
//            if appDelegate.internetIsAvailable{
//                downloadPDF(containerName: dict.containerName ?? "", blobName: (sortedPdfArray[indexPath.row].name ?? "")){
//                    showIndicator()
//                    let previewController = QLPreviewController()
//                    previewController.dataSource = self
//                    previewController.delegate = self
//                    previewController.setEditing(false, animated: true)
//                    self.present(previewController, animated: true, completion: nil)
//                }
//            }else {
//                
//            }
            
            if FileManager.default.fileExists(atPath: tempURL.path){
                showIndicator()
                let previewController = QLPreviewController()
                previewController.dataSource = self
                previewController.delegate = self
                previewController.setEditing(false, animated: true)
                self.present(previewController, animated: true, completion: nil)
            }else{
                downloadPDF(containerName: dict.containerName ?? "", blobName: (sortedPdfArray[indexPath.row].name ?? "")){
                    showIndicator()
                    let previewController = QLPreviewController()
                    previewController.dataSource = self
                    previewController.delegate = self
                    previewController.setEditing(false, animated: true)
                    self.present(previewController, animated: true, completion: nil)
                }
            }
        }
//        else if isFav {
//            
//            let modelPDF = appDelegate.arrPDFinfo.filter {$0.isFavorite == "true"}[indexPath.row]
//            if let index = appDelegate.arrPDFinfo.firstIndex(where: { $0.title == modelPDF.title }) {
//                appDelegate.arrPDFinfo[index].lastAccessedDate = dateFormatter.string(from: Date())
//            }
//            self.pdfName = modelPDF.pdfName
//            let previewController = QLPreviewController()
//            previewController.dataSource = self
//            previewController.delegate = self
//            previewController.setEditing(false, animated: true)
//            self.present(previewController, animated: true, completion: nil)
//        }
        else if showFixedFolders == true {
            if indexPath.section == 0 {
                NotificationCenter.default.post(name: Notification.Name("ToggleButtonVisibility"), object: nil, userInfo: ["isVisible": false])
                if fixedFolders[indexPath.row] == "Recent" {
                    isRecent = true
                } else {
                    isFav = true
                }
                self.tblView_documents.reloadData()
            } else {
                containerName = appDelegate.container[indexPath.row].name
                showFixedFolders = false
                currentFolderPath = ""
                self.tblView_documents.reloadData()
            }
        } else {
            if indexPath.section == 0 {
                let slashCount = self.currentFolderPath.split(separator: "/").count
                let lastPath = self.currentFolderPath.split(separator: "/").last ?? ""
                let arrFilter = appDelegate.blobdetailModel[containerName]?.blobs.blob.filter({ blob in
                    let arrSplit = (blob.name?.split(separator: "/"))
                    if arrSplit?.count ?? 0 > slashCount+1{
                        if slashCount-1 >= 0{
                            print(arrSplit, slashCount-1, (arrSplit?[slashCount-1] ?? "") == lastPath)
                            return (arrSplit?[slashCount-1] ?? "") == lastPath
                        }else{
                            return true
                        }
                    }else{
                        return false
                    }
                })
                
                let arrFolderNames:[String] = arrFilter?.map{ Blob in
                    let name:[String.SubSequence] = (Blob.name?.split(separator: "/")) ?? []
                    return name[slashCount].string
                } ?? []
                
                let arrFolder:[String] = Dictionary.init(grouping: arrFolderNames, by: {$0}).keys.sorted()
                
                let name:String = arrFolder[indexPath.row]
                
                currentFolderPath = [currentFolderPath, name].joined(separator: "/")
                
                self.tblView_documents.reloadData()
            } else {
                let slashCount = self.currentFolderPath.split(separator: "/").count
                let lastPath = self.currentFolderPath.split(separator: "/").last ?? ""
                
                let sortedPdfArray = appDelegate.blobdetailModel[containerName]?.blobs.blob.filter({ blob in
                    let arrSplit = (blob.name?.split(separator: "/"))
                    return arrSplit?.count == (slashCount+1) && (arrSplit?[slashCount-1] ?? "") == lastPath
                }).sorted { (pdf1, pdf2) -> Bool in
                    guard let date1 = dateFormatter.date(from: pdf1.properties?.lastModified ?? ""),
                          let date2 = dateFormatter.date(from: pdf2.properties?.lastModified ?? "") else {
                        return false
                    }
                    return date1 > date2 // Ascending order: change to date1 > date2 for descending order
                } ?? []
                
                pdfName = containerName+(sortedPdfArray[indexPath.row].name?.replacingOccurrences(of: "/", with: "") ?? "")
                let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let docURL = documentDirectory.appendingPathComponent(sortedPdfArray[indexPath.row].name?.replacingOccurrences(of: "/", with: "") ?? "")
                let name = docURL.deletingPathExtension().lastPathComponent
                nameOfPDF = name//(sortedPdfArray[indexPath.row].name ?? "")
                let tempURL = documentDirectory.appendingPathComponent(pdfName)
//                if appDelegate.internetIsAvailable{
//                    downloadPDF(containerName: containerName, blobName: (sortedPdfArray[indexPath.row].name ?? "")){
//                        showIndicator()
//                        let previewController = QLPreviewController()
//                        previewController.dataSource = self
//                        previewController.delegate = self
//                        previewController.setEditing(false, animated: true)
//                        self.present(previewController, animated: true, completion: nil)
//                    }
//                }else{
//                    
//                }
                
                if FileManager.default.fileExists(atPath: tempURL.path){
                    showIndicator()
                    let previewController = QLPreviewController()
                    previewController.dataSource = self
                    previewController.delegate = self
                    previewController.setEditing(false, animated: true)
                    self.present(previewController, animated: true, completion: nil)
                }else{
                    downloadPDF(containerName: containerName, blobName: (sortedPdfArray[indexPath.row].name ?? "")){
                        showIndicator()
                        let previewController = QLPreviewController()
                        previewController.dataSource = self
                        previewController.delegate = self
                        previewController.setEditing(false, animated: true)
                        self.present(previewController, animated: true, completion: nil)
                    }
                }
                
            }
        }
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
    
//    func simpleAlert(vc:UIViewController, title:String, message:String, indexPath: IndexPath) {
//        
//        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
//        
//        // Create NO button:
//        let cancelAction = UIAlertAction(title: "NO", style: .cancel) {
//            (action: UIAlertAction!) in
//            self.tblView_documents.reloadData()
//        }
//        alertController.addAction(cancelAction)
//        
//        // Create YES button:
//        let OKAction = UIAlertAction(title: "YES", style: .default) {
//            (action: UIAlertAction!) in
//            
//            //On click YES button data is removed:
//            let dateFormatter = DateFormatter()
//            dateFormatter.dateFormat = "d MMM yyyy HH mm ss"
//            let sortedPdfArray = appDelegate.arrPDFinfo.sorted { (pdf1, pdf2) -> Bool in
//                guard let date1 = dateFormatter.date(from: pdf1.lastAccessedDate),
//                      let date2 = dateFormatter.date(from: pdf2.lastAccessedDate) else {
//                    return false
//                }
//                return date1 > date2 // Ascending order: change to date1 > date2 for descending order
//            }
//            
//            let dict = sortedPdfArray[indexPath.row]
//            if let deleteIndex = appDelegate.arrPDFinfo.firstIndex(of: dict){
//                appDelegate.arrPDFinfo.remove(at: deleteIndex)
//            }
//
//            appDelegate.setPdfInfoUserDefault()
//            self.tblView_documents.reloadData()
//            
//            // Code in this block will trigger when OK button tapped.
//            print("indexPath(\(indexPath.section))deteted Data");
//        }
//        alertController.addAction(OKAction)
//        
//        // Present Dialog message
//        self.present(alertController, animated: true, completion: nil)
//    }
    
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
//           vc.modelPDF = appDelegate.arrPDFinfo[indexPath.section]
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



extension DocumentsViewController: QLPreviewControllerDataSource, QLPreviewControllerDelegate {
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        print(controller.isEditing)
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let tempURL = documentDirectory.appendingPathComponent(pdfName)
        
        hideIndicator()
        return PreviewItem(url: tempURL, title: (nameOfPDF.split(separator: "/")).last?.string ?? "")
    }
    
    func previewController(_ controller: QLPreviewController, didUpdateContentsOf previewItem: QLPreviewItem) {
        print("updatedURL:\(self.pdfName)")
    }
    func previewController(_ controller: QLPreviewController, editingModeFor previewItem: QLPreviewItem) -> QLPreviewItemEditingMode {
        return .disabled }
    
    func previewControllerDidDismiss(_ controller: QLPreviewController) {
        // Remove the temporary file after you're done
        hideIndicator()
    }
    
    func previewControllerDidFinish(_ controller: QLPreviewController) {
         // Stop the activity indicator once preview is presented
        hideIndicator()
     }
}
