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
    
    var pdfName:String = ""
    var pdfURL:URL = URL(fileURLWithPath: "")
        
    var dict: [[String: Any]] = []
    
    var modelPDF : PDFinfo!
    var currentFolderPath: String = ""{
        didSet{
            let lastPath = currentFolderPath.split(separator: "/").last?.string ?? ""
            lblNavigationTitle.text = lastPath.isEmpty ? "Cook PDF App" : lastPath
        }
    }
    

    var selectedIndex:IndexPath?
    
    // Fixed folders
    let fixedFolders = ["Recent", "Favorite"]
    // Dynamic content
    var otherFolders: [Container] = []
    var blobdetailModel : EnumerationBlobResults = EnumerationBlobResults(serviceEndpoint: "", containerName: "", blobs: BlobName(blob: []))
    var otherFolders1: [String] = ["Cooker"]
    var otherFolders2: [String] = ["PDFs"]
    var otherFolders3: [String] = []
    var pdfFiles: [String] = []
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
        
        fetchContainers()
    }
    
    private func fetchContainers() {
        let storageAccountName = storageAccountName
        showIndicator()
        ApiService.shared.listStorageContents(storageAccountName: storageAccountName) { result in
            hideIndicator()
            switch result {
            case .success(let containers):
                print("Fetched containers: \(containers)")
                
                // Update the otherFolder array and reload the table view
                DispatchQueue.main.async {
                    self.otherFolders = containers
                    self.tblView_documents.reloadData()
                }
                
            case .failure(let error):
                print("Error fetching containers: \(error.localizedDescription)")
            }
        }
    }
    
    // Load folders and PDFs from the specified path
  
    private func fetchBlogs(containerName:String) {
        let storageAccountName = storageAccountName
        showIndicator()
        ApiService.shared.listStorageBlobsContent(storageAccountName: storageAccountName, containerName: containerName) { result in
            hideIndicator()
            switch result {
            case .success(let blobdetailModel):
                print("Fetched containers: \(blobdetailModel)")
                
                // Update the otherFolder array and reload the table view
                DispatchQueue.main.async {
                    self.blobdetailModel = blobdetailModel
                    self.tblView_documents.reloadData()
                }
                
            case .failure(let error):
                print("Error fetching containers: \(error.localizedDescription)")
            }
        }
    }
    
    private func downloadPDF(containerName:String,blobName:String, completionHandler:@escaping ()->Void) {
        let storageAccountName = storageAccountName
        showIndicator()
        ApiService.shared.PDFDownLoad(storageAccountName: storageAccountName, containerName: containerName, blobName: blobName) { result in
            switch result {
            case .success(let pdfData):
                // Create a temporary file for the PDF data
                let documentDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
                let tempURL = documentDirectory.appendingPathComponent(containerName+blobName)
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
        appDelegate.getPdfInfoUserDefault()
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
                self.showFixedFolders = true
                backBtn.isHidden = true
            }
            self.tblView_documents.reloadData()
        }else {
            self.currentFolderPath = ""
            self.showFixedFolders = true
            backBtn.isHidden = true
            self.tblView_documents.reloadData()
        }
    }
    
    func menu(indexPath:IndexPath,showRemovePass:Bool, curFile: PDFinfo) -> UIMenu {
        let itemMenu = UIMenu(options: .displayInline,children: [
            //go to edit pdf screen
            UIAction(title: "Edit",image: UIImage(systemName: "pencil") ,handler: { _ in
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "DocumentsDetailViewController") as! DocumentsDetailViewController
                vc.editPDF = .edit
                vc.modelPDF = curFile
                vc.hidesBottomBarWhenPushed = true
                vc.myClosure = { arr in
                    appDelegate.arrPDFinfo = arr
                    self.tblView_documents.reloadData()
                }
                self.navigationController?.pushViewController(vc, animated: true)
            }),
            //rename file
           
            UIAction(title: "Rename",image: UIImage(systemName: "doc.text") ,handler: { _ in
                let dict = curFile
                let alertController = UIAlertController(title: "Rename PDF", message: "", preferredStyle: .alert)
                alertController.addTextField { (textfield) in
                    let cachesDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
                    let originPath = cachesDirectory.appendingPathComponent(dict.pdfName)
                    textfield.text = originPath.deletingPathExtension().lastPathComponent
                    textfield.placeholder = "Enter a new PDF name"
                    textfield.becomeFirstResponder() // Show keyboard
                    DispatchQueue.main.async{
                        if let beginningOfText = textfield.beginningOfDocument as? UITextPosition{
                            textfield.selectedTextRange = textfield.textRange(from: beginningOfText, to: beginningOfText)
                        }
                    }
                }
                let doneAction = UIAlertAction(title: "Done", style: .default) { (action) in
                   if let newName = alertController.textFields?.first {
                       let newPdfName = newName.text ?? "newFile"
                       do {
                           
                           let path = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0]
                           let documentDirectory = URL(fileURLWithPath: path)
                           let originPath = documentDirectory.appendingPathComponent(dict.pdfName)
                           var destinationPath = documentDirectory.appendingPathComponent(newPdfName)
                           if destinationPath.pathExtension.isEmpty || destinationPath.pathExtension != "pdf"{
                               destinationPath = destinationPath.appendingPathExtension(originPath.pathExtension)
                           }
                           try FileManager.default.moveItem(at: originPath, to: destinationPath)
                           
                           if let index = appDelegate.arrPDFinfo.firstIndex(where: { $0.lastAccessedDate == curFile.lastAccessedDate }) {
                               appDelegate.arrPDFinfo[index].pdfName = destinationPath.lastPathComponent
                           }

                           self.tblView_documents.reloadData()
                       } catch {
                           print(error)
                       }
                    }
                }
                let cancelAction = UIAlertAction(title: "Cancel", style: .destructive) { _ in
                    
                }
                alertController.addAction(cancelAction)
                alertController.addAction(doneAction)
                self.present(alertController, animated: true)
                
            }),

            curFile.isFavorite == "false" ?
            UIAction(title: "Add to Favorite",image: UIImage(systemName: "heart") ,handler: { _ in
                if let index = appDelegate.arrPDFinfo.firstIndex(where: { $0.lastAccessedDate == curFile.lastAccessedDate }) {
                    appDelegate.arrPDFinfo[index].isFavorite = "true"
                    self.tblView_documents.reloadData()
                }
            }) :
                UIAction(title: "Remove from Favorite",image: UIImage(systemName: "heart.fill") ,handler: { _ in
                    if let index = appDelegate.arrPDFinfo.firstIndex(where: { $0.lastAccessedDate == curFile.lastAccessedDate }) {
                        appDelegate.arrPDFinfo[index].isFavorite = "false"
                        self.tblView_documents.reloadData()
                    }
                })
        ])
            
        return itemMenu
             
     
    }
    
    func menu(indexPath:IndexPath,showRemovePass:Bool, curFile: Blob) -> UIMenu {
        let itemMenu = UIMenu(options: .displayInline,children: [
            //go to edit pdf screen
            UIAction(title: "Edit",image: UIImage(systemName: "pencil") ,handler: { _ in
                // Create PDFinfo model
                //current date and time:
                let currentDate = Date()
                var dateFormatter = DateFormatter()
                
                //Current time:
                dateFormatter.dateFormat = "d MMM,yyyy | HH:mm:ss"
                let c_dateTime = dateFormatter.string(from: currentDate)
                
                //Replace space(" ") with "_":
                dateFormatter.dateFormat = "d MMM yyyy HH mm ss"
                let dateTime = dateFormatter.string(from: currentDate)
                
                self.pdfName = self.blobdetailModel.containerName+(curFile.name ?? "")
                let documentDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
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
                    folderPath: "", storageAccountName: storageAccountName, containerName: self.blobdetailModel.containerName, blobName: curFile.name ?? ""
                )
                //set pageCount and pdfSize:
                pdfModel.pageCount = "\((pdfDocument.pageCount)) page"
                pdfModel.size = fileSize ?? ""
                
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
                    self.downloadPDF(containerName: self.blobdetailModel.containerName, blobName: (curFile.name ?? "")){
                        let documentDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
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
            
            UIAction(title: "Rename",image: UIImage(systemName: "doc.text") ,handler: { _ in
                let dict = curFile
                let alertController = UIAlertController(title: "Rename PDF", message: "", preferredStyle: .alert)
                alertController.addTextField { (textfield) in
                    let cachesDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
                    let originPath = cachesDirectory.appendingPathComponent(self.blobdetailModel.containerName + (dict.name ?? ""))
                    textfield.text = originPath.deletingPathExtension().lastPathComponent
                    textfield.placeholder = "Enter a new PDF name"
                    textfield.becomeFirstResponder() // Show keyboard
                    DispatchQueue.main.async{
                        if let beginningOfText = textfield.beginningOfDocument as? UITextPosition{
                            textfield.selectedTextRange = textfield.textRange(from: beginningOfText, to: beginningOfText)
                        }
                    }
                }
                let doneAction = UIAlertAction(title: "Done", style: .default) { (action) in
                    if let newName = alertController.textFields?.first {
                        let newPdfName = newName.text ?? "newFile"
                        showIndicator()
                        do {
                            let cachesDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
                            let originPath = cachesDirectory.appendingPathComponent(self.blobdetailModel.containerName + (dict.name ?? ""))
                            let fileName = originPath.deletingPathExtension().lastPathComponent
                            let finalName = (dict.name ?? "").replacingOccurrences(of: fileName, with: newPdfName)
                            var destinationPath = cachesDirectory.appendingPathComponent(self.blobdetailModel.containerName+finalName)
                            if destinationPath.pathExtension.isEmpty || destinationPath.pathExtension != "pdf"{
                                destinationPath = cachesDirectory.appendingPathExtension(originPath.pathExtension)
                            }
                            if FileManager.default.fileExists(atPath: originPath.path){
                                print("from url :- ", originPath.path)
                                print("to url :- ", destinationPath.path)
                                
                                try FileManager.default.moveItem(at: originPath, to: destinationPath)
                            }
                            
                            ApiService.shared.deletePDF(storageAccountName: self.modelPDF.storageAccountName, containerName: self.modelPDF.containerName,blobName: (dict.name ?? "")) { _ in
                                ApiService.shared.uploadPDF(storageAccountName: self.modelPDF.storageAccountName, containerName: self.modelPDF.containerName, blobName: newPdfName) { result in
                                    switch result {
                                    case .success(_):
                                        print("Upload Success :--->>> \(self.modelPDF.containerName) / \(self.modelPDF.blobName)")
                                        self.fetchBlogs(containerName:self.otherFolders[indexPath.row].name)
                                    case .failure(let failure):
                                        hideIndicator()
                                        print("Upload Failer :--->> ", failure.localizedDescription)
                                    }
                                }
                            }
//                            self.tblView_documents.reloadData()
                        } catch {
                            hideIndicator()
                            print(error)
                        }
                    }
                }
                let cancelAction = UIAlertAction(title: "Cancel", style: .destructive) { _ in
                    
                }
                alertController.addAction(cancelAction)
                alertController.addAction(doneAction)
                self.present(alertController, animated: true)
                
            }),
            
            false/*curFile.isFavorite == "false"*/ ?
            UIAction(title: "Add to Favorite",image: UIImage(systemName: "heart") ,handler: { _ in
//                if let index = appDelegate.arrPDFinfo.firstIndex(where: { $0.lastAccessedDate == curFile.lastAccessedDate }) {
//                    appDelegate.arrPDFinfo[index].isFavorite = "true"
//                    self.tblView_documents.reloadData()
//                }
            }) :
                UIAction(title: "Remove from Favorite",image: UIImage(systemName: "heart.fill") ,handler: { _ in
//                    if let index = appDelegate.arrPDFinfo.firstIndex(where: { $0.lastAccessedDate == curFile.lastAccessedDate }) {
//                        appDelegate.arrPDFinfo[index].isFavorite = "false"
//                        self.tblView_documents.reloadData()
//                    }
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
//        let slashCount = self.currentFolderPath.split(separator: "/").count
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isRecent {
            return appDelegate.arrPDFinfo.count
        }
        
        if isFav {
            return appDelegate.arrPDFinfo.filter {$0.isFavorite == "true"}.count
        }
        
        
        if showFixedFolders {
            return section == 0 ? fixedFolders.count : otherFolders.count
        } else {
            let slashCount = self.currentFolderPath.split(separator: "/").count
            
            let blogSlashCount = blobdetailModel.blobs.blob.filter({ blob in
                let arrSplit = (blob.name?.split(separator: "/"))
                return (arrSplit?.count ?? 0) == (slashCount+2)
            }).count
            
            
            let arrFolderNames = blobdetailModel.blobs.blob.filter({ blob in
                let arrSplit = (blob.name?.split(separator: "/"))
                return (arrSplit?.count ?? 0) == (slashCount+2)
            }).map { Blob in
                (Blob.name?.split(separator: "/"))?.first?.string ?? ""
            }
            
            let arrFolder = Dictionary.init(grouping: arrFolderNames, by: {$0}).keys
            
            let documentCount = blobdetailModel.blobs.blob.filter({ blob in
                let arrSplit = (blob.name?.split(separator: "/"))
                return arrSplit?.count == (slashCount+1)
            }).count
            return section == 0 ? arrFolder.count : documentCount
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      
        let cell = tableView.dequeueReusableCell(withIdentifier: "DocumentsTableViewCell") as! DocumentsTableViewCell
        if isRecent {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "d MMM yyyy HH mm ss"
            
            let sortedPdfArray = appDelegate.arrPDFinfo.sorted { (pdf1, pdf2) -> Bool in
                guard let date1 = dateFormatter.date(from: pdf1.lastAccessedDate),
                      let date2 = dateFormatter.date(from: pdf2.lastAccessedDate) else {
                    return false
                }
                return date1 > date2
            }
            
            let dict = sortedPdfArray[indexPath.row]
            let documentDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
            let docURL = documentDirectory.appendingPathComponent(dict.pdfName)
            
            cell.lbl_title.text = dict.pdfName
            cell.img_profile.image = UIImage(systemName: "document")
            cell.btn_editPdf.isHidden = false
            
            cell.selectionStyle = .gray
            cell.btn_editPdf.showsMenuAsPrimaryAction = true
            let pdfDocument = PDFDocument(url: docURL)
            cell.btn_editPdf.menu = self.menu(indexPath: indexPath,showRemovePass: pdfDocument?.isLocked ?? true, curFile: dict )
            appDelegate.setPdfInfoUserDefault()
            cell.btn_editPdf.isHidden = false
            cell.lbl_fileNum.isHidden = true
        } else if isFav {
            let dict = appDelegate.arrPDFinfo.filter {$0.isFavorite == "true"}[indexPath.row]
            let documentDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
            let docURL = documentDirectory.appendingPathComponent(dict.pdfName)
        
            cell.lbl_title.text = dict.pdfName
            cell.img_profile.image = UIImage(systemName: "document")
            cell.btn_editPdf.isHidden = false
            cell.lbl_fileNum.isHidden = true
            cell.selectionStyle = .gray
            cell.btn_editPdf.showsMenuAsPrimaryAction = true
            let pdfDocument = PDFDocument(url: docURL)
            cell.btn_editPdf.menu = self.menu(indexPath: indexPath,showRemovePass: pdfDocument?.isLocked ?? true, curFile: dict )
            appDelegate.setPdfInfoUserDefault()
            cell.btn_editPdf.isHidden = false
        } else if(showFixedFolders) {
            if indexPath.section == 0 {
                cell.lbl_fileNum.isHidden = false
                cell.lbl_title.text = fixedFolders[indexPath.row]
                if fixedFolders[indexPath.row] == "Recent" {
                    cell.lbl_fileNum.text = String(appDelegate.arrPDFinfo.count)
                    cell.img_profile?.image = UIImage(systemName: "clock") // Clock icon for Recent
                } else if fixedFolders[indexPath.row] == "Favorite" {
                    cell.img_profile?.image = UIImage(systemName: "star") // Star icon for Favorite
                    cell.lbl_fileNum.text = String(appDelegate.arrPDFinfo.filter {$0.isFavorite == "true"}.count)
                }
                
            } else {
                cell.lbl_fileNum.isHidden = true
                cell.lbl_title.text = otherFolders[indexPath.row].name
                cell.img_profile.image = UIImage(systemName: "folder")
            }
            cell.btn_editPdf.isHidden = true
            
        } else {
            cell.lbl_fileNum.isHidden = true
            if indexPath.section == 0 {
                let slashCount = self.currentFolderPath.split(separator: "/").count
//                let sortedDocumentArray = blobdetailModel.blobs.blob.filter({ blob in
//                    let arrSplit = (blob.name?.split(separator: "/"))
//                    return (arrSplit?.count ?? 0) == (slashCount+2)
//                }).sorted { (pdf1, pdf2) -> Bool in
//                    guard let date1 = dateFormatter.date(from: pdf1.properties?.lastModified ?? ""),
//                          let date2 = dateFormatter.date(from: pdf2.properties?.lastModified ?? "") else {
//                        return false
//                    }
//                    return date1 > date2 // Ascending order: change to date1 > date2 for descending order
//                }
//                
                let arrFolderNames = blobdetailModel.blobs.blob.filter({ blob in
                    let arrSplit = (blob.name?.split(separator: "/"))
                    return (arrSplit?.count ?? 0) == (slashCount+2)
                }).map { Blob in
                    var blobname = (Blob.name?.split(separator: "/"))
                    blobname?.removeLast()
                    return blobname?.last?.string ?? ""
                }
                
                let arrFolder = Dictionary.init(grouping: arrFolderNames, by: {$0}).keys.sorted()
                
//                let dict = sortedDocumentArray[indexPath.row]
                cell.lbl_title.text = arrFolder[indexPath.row]///dict.name ?? ""
                cell.img_profile.image = UIImage(systemName: "folder")
                cell.btn_editPdf.isHidden = true
            } else {
                print(self.currentFolderPath)
                print(appDelegate.arrPDFinfo)
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "d MMM yyyy HH mm ss"
                
                let slashCount = self.currentFolderPath.split(separator: "/").count
                
                let sortedPdfArray = blobdetailModel.blobs.blob.filter({ blob in
                    let arrSplit = (blob.name?.split(separator: "/"))
                    return arrSplit?.count == (slashCount+1)
                }).sorted { (pdf1, pdf2) -> Bool in
                    guard let date1 = dateFormatter.date(from: pdf1.properties?.lastModified ?? ""),
                          let date2 = dateFormatter.date(from: pdf2.properties?.lastModified ?? "") else {
                        return false
                    }
                    return date1 > date2 // Ascending order: change to date1 > date2 for descending order
                }
                
                let dict = sortedPdfArray[indexPath.row]
                
                let documentDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
                let docURL = documentDirectory.appendingPathComponent(dict.name ?? "")
//                if !(dict.properties?.contentType.hasPrefix("multipart/form-data") ?? false){
                    cell.lbl_title.text = (dict.name?.split(separator: "/"))?.last?.string ?? ""
                    cell.img_profile.image = UIImage(systemName: "document")
                    cell.btn_editPdf.isHidden = false
                    
                    cell.selectionStyle = .gray
                    cell.btn_editPdf.showsMenuAsPrimaryAction = true
                    let pdfDocument = PDFDocument(url: docURL)
                    cell.btn_editPdf.menu = self.menu(indexPath: indexPath,showRemovePass: pdfDocument?.isLocked ?? true, curFile: dict)
                    appDelegate.setPdfInfoUserDefault()
                    cell.btn_editPdf.isHidden = false
                    cell.lbl_fileNum.isHidden = true
//                }else{
//                    cell.lbl_title.text = dict.name ?? ""
//                    cell.img_profile.image = UIImage(systemName: "folder")
//                    cell.btn_editPdf.isHidden = true
//                }
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.backBtn.isHidden = false
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMM yyyy HH mm ss"
        if isRecent {
            let sortedPdfArray = appDelegate.arrPDFinfo.sorted { (pdf1, pdf2) -> Bool in
                guard let date1 = dateFormatter.date(from: pdf1.lastAccessedDate),
                      let date2 = dateFormatter.date(from: pdf2.lastAccessedDate) else {
                    return false
                }
                return date1 > date2 // Ascending order: change to date1 > date2 for descending order
            }
            
            let modelPDF = sortedPdfArray[indexPath.row]
            if let index = appDelegate.arrPDFinfo.firstIndex(where: { $0.title == modelPDF.title }) {
                appDelegate.arrPDFinfo[index].lastAccessedDate = dateFormatter.string(from: Date())
            }
            self.pdfName = modelPDF.pdfName
            let previewController = QLPreviewController()
            previewController.dataSource = self
            previewController.delegate = self
            previewController.setEditing(false, animated: true)
            self.present(previewController, animated: true, completion: nil)
        } else if isFav {
            
            let modelPDF = appDelegate.arrPDFinfo.filter {$0.isFavorite == "true"}[indexPath.row]
            if let index = appDelegate.arrPDFinfo.firstIndex(where: { $0.title == modelPDF.title }) {
                appDelegate.arrPDFinfo[index].lastAccessedDate = dateFormatter.string(from: Date())
            }
            self.pdfName = modelPDF.pdfName
            let previewController = QLPreviewController()
            previewController.dataSource = self
            previewController.delegate = self
            previewController.setEditing(false, animated: true)
            self.present(previewController, animated: true, completion: nil)
        } else if showFixedFolders == true {
            if indexPath.section == 0 {
                NotificationCenter.default.post(name: Notification.Name("ToggleButtonVisibility"), object: nil, userInfo: ["isVisible": false])
                if fixedFolders[indexPath.row] == "Recent" {
                    isRecent = true
                } else {
                    isFav = true
                }
                self.tblView_documents.reloadData()
            } else {
                blobdetailModel = EnumerationBlobResults(serviceEndpoint: "", containerName: "", blobs: BlobName(blob: []))
                showFixedFolders = false
                currentFolderPath = ""//+= otherFolders[indexPath.row].name
                fetchBlogs(containerName: otherFolders[indexPath.row].name)
                self.tblView_documents.reloadData()
            }
        } else {
            if indexPath.section == 0 {
                let slashCount = self.currentFolderPath.split(separator: "/").count
                let documentCount = blobdetailModel.blobs.blob.filter({ blob in
                    let arrSplit = (blob.name?.split(separator: "/"))
                    return arrSplit?.count == (slashCount+2)
                }).first
                
                var name = documentCount?.name?.split(separator: "/")
                name?.removeLast()
                currentFolderPath = name?.joined(separator: "/") ?? ""
                self.tblView_documents.reloadData()
            } else {
                let slashCount = self.currentFolderPath.split(separator: "/").count
                let sortedPdfArray = blobdetailModel.blobs.blob.filter({ blob in
                    let arrSplit = (blob.name?.split(separator: "/"))
                    return arrSplit?.count == (slashCount+1)
                }).sorted { (pdf1, pdf2) -> Bool in
                    guard let date1 = dateFormatter.date(from: pdf1.properties?.lastModified ?? ""),
                          let date2 = dateFormatter.date(from: pdf2.properties?.lastModified ?? "") else {
                        return false
                    }
                    return date1 > date2 // Ascending order: change to date1 > date2 for descending order
                }
                
                pdfName = blobdetailModel.containerName+(sortedPdfArray[indexPath.row].name ?? "")
                let documentDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
                let tempURL = documentDirectory.appendingPathComponent(pdfName)
                if FileManager.default.fileExists(atPath: tempURL.path){
                    let previewController = QLPreviewController()
                    previewController.dataSource = self
                    previewController.delegate = self
                    previewController.setEditing(false, animated: true)
                    self.present(previewController, animated: true, completion: nil)
                }else{
                    downloadPDF(containerName: blobdetailModel.containerName, blobName: (sortedPdfArray[indexPath.row].name ?? "")){
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
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "d MMM yyyy HH mm ss"
            let sortedPdfArray = appDelegate.arrPDFinfo.sorted { (pdf1, pdf2) -> Bool in
                guard let date1 = dateFormatter.date(from: pdf1.lastAccessedDate),
                      let date2 = dateFormatter.date(from: pdf2.lastAccessedDate) else {
                    return false
                }
                return date1 > date2 // Ascending order: change to date1 > date2 for descending order
            }
            
            let dict = sortedPdfArray[indexPath.row]
            if let deleteIndex = appDelegate.arrPDFinfo.firstIndex(of: dict){
                appDelegate.arrPDFinfo.remove(at: deleteIndex)
            }

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
        let documentDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let tempURL = documentDirectory.appendingPathComponent(pdfName)
        return tempURL as QLPreviewItem
    }
    
    func previewController(_ controller: QLPreviewController, didUpdateContentsOf previewItem: QLPreviewItem) {
        print("updatedURL:\(self.pdfName)")
    }
    func previewController(_ controller: QLPreviewController, editingModeFor previewItem: QLPreviewItem) -> QLPreviewItemEditingMode {
        return .disabled }
    
    func previewControllerDidDismiss(_ controller: QLPreviewController) {
        // Remove the temporary file after you're done
    }
}
