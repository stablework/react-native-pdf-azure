//
//	clsFirebaseModelCategory.swift
//
//	Create by Sahil Moradiya on 26/5/2022
//	Copyright © 2022. All rights reserved.
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation


class clsFirebaseModelCategory : NSObject, NSCoding{

	var categoryData : [clsFirebaseModelCategoryData]!
	var categoryName : String!
    var image : String!


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
		categoryData = [clsFirebaseModelCategoryData]()
		if let categoryDataArray = dictionary["category_data"] as? [NSDictionary]{
			for dic in categoryDataArray{
				let value = clsFirebaseModelCategoryData(fromDictionary: dic)
				categoryData.append(value)
			}
		}
		categoryName = dictionary["category_name"] as? String == nil ? "" : dictionary["category_name"] as? String
        image = dictionary["image"] as? String == nil ? "" : dictionary["image"] as? String
	}

	/**
	 * Returns all the available property values in the form of NSDictionary object where the key is the approperiate json key and the value is the value of the corresponding property
	 */
	func toDictionary() -> NSDictionary
	{
		let dictionary = NSMutableDictionary()
		if categoryData != nil{
			var dictionaryElements = [NSDictionary]()
			for categoryDataElement in categoryData {
				dictionaryElements.append(categoryDataElement.toDictionary())
			}
			dictionary["category_data"] = dictionaryElements
		}
		if categoryName != nil{
			dictionary["category_name"] = categoryName
		}
        if image != nil{
            dictionary["image"] = image
        }
		return dictionary
	}

    /**
    * NSCoding required initializer.
    * Fills the data from the passed decoder
    */
    @objc required init(coder aDecoder: NSCoder)
	{
         categoryData = aDecoder.decodeObject(forKey: "category_data") as? [clsFirebaseModelCategoryData]
         categoryName = aDecoder.decodeObject(forKey: "category_name") as? String
         image = aDecoder.decodeObject(forKey: "image") as? String
	}

    /**
    * NSCoding required method.
    * Encodes mode properties into the decoder
    */
    public func encode(with aCoder: NSCoder) 
	{
		if categoryData != nil{
			aCoder.encode(categoryData, forKey: "category_data")
		}
		if categoryName != nil{
			aCoder.encode(categoryName, forKey: "category_name")
		}
        if image != nil{
            aCoder.encode(image, forKey: "image")
        }

	}

}
