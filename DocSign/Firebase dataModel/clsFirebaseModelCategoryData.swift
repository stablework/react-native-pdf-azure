//
//	clsFirebaseModelCategoryData.swift
//
//	Create by Sahil Moradiya on 26/5/2022
//	Copyright © 2022. All rights reserved.
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation


class clsFirebaseModelCategoryData : NSObject, NSCoding{

	var link : String!
	var name : String!
	var thumpImg : String!
    var title : String!


	/**
	 * Overiding init method
	 */
	init(fromDictionary dictionary: NSDictionary)
	{
		super.init()
		parseJSONData(fromDictionary: dictionary)
	}

	/**
	 * Overiding init method
	 */
	override init(){
	}

	/**
	 * Instantiate the instance using the passed dictionary values to set the properties values
	 */
	@objc func parseJSONData(fromDictionary dictionary: NSDictionary)
	{
		link = dictionary["link"] as? String == nil ? "" : dictionary["link"] as? String
		name = dictionary["name"] as? String == nil ? "" : dictionary["name"] as? String
		thumpImg = dictionary["thump_img"] as? String == nil ? "" : dictionary["thump_img"] as? String
        title = dictionary["title"] as? String == nil ? "" : dictionary["title"] as? String
	}

	/**
	 * Returns all the available property values in the form of NSDictionary object where the key is the approperiate json key and the value is the value of the corresponding property
	 */
	func toDictionary() -> NSDictionary
	{
		let dictionary = NSMutableDictionary()
		if link != nil{
			dictionary["link"] = link
		}
		if name != nil{
			dictionary["name"] = name
		}
		if thumpImg != nil{
			dictionary["thump_img"] = thumpImg
		}
        if title != nil{
            dictionary["title"] = title
        }
		return dictionary
	}

    /**
    * NSCoding required initializer.
    * Fills the data from the passed decoder
    */
    @objc required init(coder aDecoder: NSCoder)
	{
         link = aDecoder.decodeObject(forKey: "link") as? String
         name = aDecoder.decodeObject(forKey: "name") as? String
         thumpImg = aDecoder.decodeObject(forKey: "thump_img") as? String
         title = aDecoder.decodeObject(forKey: "title") as? String
	}

    /**
    * NSCoding required method.
    * Encodes mode properties into the decoder
    */
    public func encode(with aCoder: NSCoder) 
	{
		if link != nil{
			aCoder.encode(link, forKey: "link")
		}
		if name != nil{
			aCoder.encode(name, forKey: "name")
		}
		if thumpImg != nil{
			aCoder.encode(thumpImg, forKey: "thump_img")
		}
        if title != nil{
            aCoder.encode(title, forKey: "title")
        }
	}

}
