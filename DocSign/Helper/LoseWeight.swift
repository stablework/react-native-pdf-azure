//
//  LoseWeight.swift
//  LoseWeight
//
//  Created by Sahil Moradiya on 21/05/22.
//

import Foundation
//import SVProgressHUD

func showIndicator() {
//    SVProgressHUD.show()
}

func hideIndicator() {
//    SVProgressHUD.dismiss()
}


// Favourite Videos

func saveFavouriteVideos(array: NSMutableArray)
{
    let data = NSKeyedArchiver.archivedData(withRootObject: array)
    UserDefaults.standard.setValue(data, forKey: "favVideo")
    UserDefaults.standard.synchronize()
}

func getSaveFavouriteVideos() -> NSMutableArray {
    
    if let data = UserDefaults.standard.value(forKey: "favVideo")
    {
        let arrData = NSKeyedUnarchiver.unarchiveObject(with: data as! Data)
        return (arrData as? NSMutableArray)!
    }
    return NSMutableArray()
}

func getYoutubeId(youtubeUrl: String) -> String? {
    return URLComponents(string: youtubeUrl)?.queryItems?.first(where: { $0.name == "v" })?.value
}
