//
//	clsFirebaseModelData.swift
//
//	Create by Sahil Moradiya on 26/5/2022
//	Copyright © 2022. All rights reserved.
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation


class clsFirebaseModelData : NSObject, NSCoding{

	var categories : [clsFirebaseModelCategory]!
	var clrName : String!
	var imgLink : String!
	var typeId : String!
	var typeName : String!


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
		categories = [clsFirebaseModelCategory]()
		if let categoriesArray = dictionary["categories"] as? [NSDictionary]{
			for dic in categoriesArray{
				let value = clsFirebaseModelCategory(fromDictionary: dic)
				categories.append(value)
			}
		}
		clrName = dictionary["clr_name"] as? String == nil ? "" : dictionary["clr_name"] as? String
		imgLink = dictionary["img_link"] as? String == nil ? "" : dictionary["img_link"] as? String
		typeId = dictionary["type_id"] as? String == nil ? "" : dictionary["type_id"] as? String
		typeName = dictionary["type_name"] as? String == nil ? "" : dictionary["type_name"] as? String
	}

	/**
	 * Returns all the available property values in the form of NSDictionary object where the key is the approperiate json key and the value is the value of the corresponding property
	 */
	func toDictionary() -> NSDictionary
	{
		let dictionary = NSMutableDictionary()
		if categories != nil{
			var dictionaryElements = [NSDictionary]()
			for categoriesElement in categories {
				dictionaryElements.append(categoriesElement.toDictionary())
			}
			dictionary["categories"] = dictionaryElements
		}
		if clrName != nil{
			dictionary["clr_name"] = clrName
		}
		if imgLink != nil{
			dictionary["img_link"] = imgLink
		}
		if typeId != nil{
			dictionary["type_id"] = typeId
		}
		if typeName != nil{
			dictionary["type_name"] = typeName
		}
		return dictionary
	}

    /**
    * NSCoding required initializer.
    * Fills the data from the passed decoder
    */
    @objc required init(coder aDecoder: NSCoder)
	{
         categories = aDecoder.decodeObject(forKey: "categories") as? [clsFirebaseModelCategory]
         clrName = aDecoder.decodeObject(forKey: "clr_name") as? String
         imgLink = aDecoder.decodeObject(forKey: "img_link") as? String
         typeId = aDecoder.decodeObject(forKey: "type_id") as? String
         typeName = aDecoder.decodeObject(forKey: "type_name") as? String

	}

    /**
    * NSCoding required method.
    * Encodes mode properties into the decoder
    */
    public func encode(with aCoder: NSCoder) 
	{
		if categories != nil{
			aCoder.encode(categories, forKey: "categories")
		}
		if clrName != nil{
			aCoder.encode(clrName, forKey: "clr_name")
		}
		if imgLink != nil{
			aCoder.encode(imgLink, forKey: "img_link")
		}
		if typeId != nil{
			aCoder.encode(typeId, forKey: "type_id")
		}
		if typeName != nil{
			aCoder.encode(typeName, forKey: "type_name")
		}

	}

}