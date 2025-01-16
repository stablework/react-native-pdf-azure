//
//  AppIntroViewController.swift
//  DocSign
//
//  Created by MAC on 03/02/23.
//

import UIKit

struct OverView{
    var image: String
    var lblTitle: String
    var lblDescription: String
}  

class AppIntroViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    //MARK: - Outlets
    //UICollectionView:
    @IBOutlet weak var collectionView_appIntro: UICollectionView!
    //PageControl:
    @IBOutlet weak var pageControl: UIPageControl!
    //UIButton:
    @IBOutlet weak var btn_skip: UIButton!
    @IBOutlet weak var btn_start: UIButton!
    
    //MARK: - Properties
    var overViews = [OverView(image: AppConstants.AppIntro_images.img1, lblTitle: AppConstants.AppIntro_lblTitle.lbl_title1, lblDescription:                         AppConstants.AppIntro_lblDescription.lbl_description1),
                     OverView(image: AppConstants.AppIntro_images.img2, lblTitle: AppConstants.AppIntro_lblTitle.lbl_title2, lblDescription: AppConstants.AppIntro_lblDescription.lbl_description2),
                     OverView(image: AppConstants.AppIntro_images.img3, lblTitle: AppConstants.AppIntro_lblTitle.lbl_title3, lblDescription: AppConstants.AppIntro_lblDescription.lbl_description3),
                     OverView(image: AppConstants.AppIntro_images.img4, lblTitle: AppConstants.AppIntro_lblTitle.lbl_title4, lblDescription: AppConstants.AppIntro_lblDescription.lbl_description4)]
    
    //For display appIntro only first time when app installed:
    let firstRun = UserDefaults.standard.bool(forKey: "AppIntroCollectionViewCell") as Bool
    
//MARK: - ViewController life cycle method
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        
        self.collectionView_appIntro.delegate = self
        self.collectionView_appIntro.dataSource = self
        
        //For display appIntro only first time when app installed:
//        if firstRun {
//            btn_skip(AnyObject.self)
//        } else {
//            runFirst() //will only run once
//        }
        
    }
    
//MARK: - Actions
    @IBAction func btn_skip(_ sender: Any) {
        setInt(value: 1, key: ISSHOWINTROSCREEN)
        let vc = storyboard?.instantiateViewController(withIdentifier: "TabBarViewController") as! TabBarViewController
        let navigationController = UINavigationController(rootViewController: vc)
        navigationController.navigationBar.isHidden = true
        appDelegate.window?.rootViewController = navigationController
        appDelegate.window?.makeKeyAndVisible()
    }
    
    @IBAction func btn_start(_ sender: Any) {
        setInt(value: 1, key: ISSHOWINTROSCREEN)
        let vc = storyboard?.instantiateViewController(withIdentifier: "TabBarViewController") as! TabBarViewController
        let navigationController = UINavigationController(rootViewController: vc)
        navigationController.navigationBar.isHidden = true
        appDelegate.window?.rootViewController = navigationController
        appDelegate.window?.makeKeyAndVisible()
    }
    
//MARK: - Functions
    //For display appIntro only first time when app installed:
    func runFirst() {
        UserDefaults.standard.set(true, forKey: "AppIntroCollectionViewCell")
    }
    
//MARK: - CollectionView delegates
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return overViews.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AppIntroCollectionViewCell", for: indexPath) as! AppIntroCollectionViewCell
        
        let dictOverview = overViews[indexPath.row]
        
        cell.lbl_title.text = dictOverview.lblTitle
        cell.lbl_description.text = dictOverview.lblDescription
        
        DispatchQueue.main.async {
            cell.img.loadGif(name: self.overViews[indexPath.row].image)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.width, height: self.view.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        self.pageControl.currentPage = indexPath.row
    }
    
}
