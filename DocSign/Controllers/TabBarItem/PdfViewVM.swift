//
//  PdfViewVM.swift
//  DocSign
//
//  Created by Mac on 09/04/24.
//

import UIKit
import PDFKit
import QuickLook

class PdfViewVM: UIViewController {
//    @IBOutlet weak var lbl_pdfName: UILabel!
//    @IBOutlet weak var btn_back: UIButton!
//    
//    @IBOutlet weak var btn_edit: UIButton!
//    @IBOutlet weak var btn_printer: UIButton!
//    @IBOutlet weak var view_pdf: UIView!
//    var pdfName:String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
//        lbl_pdfName.text = pdfName
//        self.tabBarController?.tabBar.isHidden = true
//        let tabBar = self.tabBarController as? TabBarViewController
//        tabBar?.menuButton.isHidden = true
//        displayPdf()
    }
    

//    @IBAction func homeButtonClick(_ sender: Any) {
//        self.navigationController?.popViewController(animated: true)
//        self.tabBarController?.tabBar.isHidden = false
//    }
//    private func displayPdf() {
//        
//        let pdfView = PDFView(frame: self.view_pdf.bounds)
//        
//        //        let myFileName = "sample"
//        //        guard let url = Bundle.main.url(forResource: myFileName, withExtension: "pdf") else {
//        //                 return
//        //        }
//        pdfView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        pdfView.autoScales = true
//        pdfView.displaysPageBreaks = true
//        pdfView.displayMode = .singlePageContinuous
//                
//        pdfView.displayDirection = .vertical
//        pdfView.translatesAutoresizingMaskIntoConstraints = false
//       
//        //For fit image in pdfView:
//        pdfView.usePageViewController(true, withViewOptions: nil)
//        self.view_pdf.addSubview(pdfView)
//        
//        let fileManager = FileManager()
//        
//       
//            let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//            let docURL = documentDirectory.appendingPathComponent(self.pdfName)
//            print(self.pdfName)
//            if fileManager.fileExists(atPath: docURL.path){
//                let pdfDoc = PDFDocument(url: docURL)
//                print( pdfDoc?.isEncrypted)
//                if !(pdfDoc?.isEncrypted ?? false) {
//                    pdfView.document = pdfDoc
//                }
//               
//            }
//        
//        
//        
////        let currentPageIndex = pdfView.document?.pageCount //pdfDocument.index(for: pdfView.currentPage!)
////        self.lbl_pgNumbers.text = "\(currentPageIndex ?? 0)"
//        
//       
// //       pageController.numberOfPages = pdfView.document?.pageCount ?? 0
//        
//        
////        pdfView.detectScrollView()?.isScrollEnabled = true
//        pdfView.detectScrollView()?.showsVerticalScrollIndicator = false
//        pdfView.detectScrollView()?.showsHorizontalScrollIndicator = false
//                
//    }
//    
}
