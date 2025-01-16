//
//	clsFirebaseModel.swift
//
//	Create by Sahil Moradiya on 26/5/2022
//	Copyright © 2022. All rights reserved.
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation


class clsFirebaseModel : NSObject, NSCoding{

	var data : [clsFirebaseModelData]!
	var flag : Int!
	var msg : String!


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
		data = [clsFirebaseModelData]()
		if let dataArray = dictionary["data"] as? [NSDictionary]{
			for dic in dataArray{
				let value = clsFirebaseModelData(fromDictionary: dic)
				data.append(value)
			}
		}
		flag = dictionary["flag"] as? Int == nil ? 0 : dictionary["flag"] as? Int
		msg = dictionary["msg"] as? String == nil ? "" : dictionary["msg"] as? String
	}

	/**
	 * Returns all the available property values in the form of NSDictionary object where the key is the approperiate json key and the value is the value of the corresponding property
	 */
	func toDictionary() -> NSDictionary
	{
		let dictionary = NSMutableDictionary()
		if data != nil{
			var dictionaryElements = [NSDictionary]()
			for dataElement in data {
				dictionaryElements.append(dataElement.toDictionary())
			}
			dictionary["data"] = dictionaryElements
		}
		if flag != nil{
			dictionary["flag"] = flag
		}
		if msg != nil{
			dictionary["msg"] = msg
		}
		return dictionary
	}

    /**
    * NSCoding required initializer.
    * Fills the data from the passed decoder
    */
    @objc required init(coder aDecoder: NSCoder)
	{
         data = aDecoder.decodeObject(forKey: "data") as? [clsFirebaseModelData]
         flag = aDecoder.decodeObject(forKey: "flag") as? Int
         msg = aDecoder.decodeObject(forKey: "msg") as? String
	}

    /**
    * NSCoding required method.
    * Encodes mode properties into the decoder
    */
    public func encode(with aCoder: NSCoder) 
	{
		if data != nil{
			aCoder.encode(data, forKey: "data")
		}
		if flag != nil{
			aCoder.encode(flag, forKey: "flag")
		}
		if msg != nil{
			aCoder.encode(msg, forKey: "msg")
		}

	}

}
