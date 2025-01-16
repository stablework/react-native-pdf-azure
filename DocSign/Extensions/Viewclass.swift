//
//  Viewclass.swift
//
//  Created by Apple on 11/04/16.
//  Copyright © 2016 Apple. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore
import AVFoundation

/// This extesion adds some useful functions to UIView
extension UIView
{
        func addBottomShadow() {
            layer.masksToBounds = false
            layer.shadowRadius = 4
            layer.shadowOpacity = 1
            layer.shadowColor = UIColor.gray.cgColor
            layer.shadowOffset = CGSize(width: 0 , height: 2)
            layer.shadowPath = UIBezierPath(rect: CGRect(x: 0,
                                                         y: bounds.maxY - layer.shadowRadius,
                                                         width: bounds.width,
                                                         height: layer.shadowRadius)).cgPath
        }
    
    func setShadow(scale: Bool = true,shadowColor:CGColor,opacity:Float,radius:CGFloat,offset:CGSize = .zero) {
//        layer.masksToBounds = false
        layer.shadowColor = shadowColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offset
        layer.shadowRadius = radius
//        layer.shouldRasterize = true
//        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    
    func setGradientColor(_ colors:[CGColor],locations:[NSNumber],startPoint:CGPoint = CGPoint(x: 0, y: 0),endPoint:CGPoint = CGPoint(x: 0, y: 1)){
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colors
        gradientLayer.locations = locations
        gradientLayer.frame = self.bounds
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
        gradientLayer.cornerRadius = self.layer.cornerRadius
        if let _ = self.layer.sublayers?.last{
            self.layer.insertSublayer(gradientLayer, at:0)
        }
    }
    
    func setVerticalGrayGradientColor(){
        let color1 = (UIColor(named: "buttonGradientColor4") ?? UIColor.clear).cgColor
        let color2 = (UIColor(named: "buttonGradientColor5") ?? UIColor.clear).cgColor
        let color3 = (UIColor(named: "buttonGradientColor6") ?? UIColor.clear).cgColor
        let color4 = (UIColor(named: "buttonGradientColor7") ?? UIColor.clear).cgColor

        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [color1, color2, color3,color4,color4]
        gradientLayer.locations = [0.0,0.3,0.6,0.8,0.1]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0)
        gradientLayer.frame = self.bounds
        gradientLayer.cornerRadius = self.layer.cornerRadius
        if let _ = self.layer.sublayers?.last{
            self.layer.insertSublayer(gradientLayer, at:0)
        }
    }
    
    func createBordersWithColor(_ color: UIColor, radius: CGFloat, width: CGFloat) {
        self.layer.borderWidth = width
        self.layer.cornerRadius = radius
        self.layer.shouldRasterize = false
        self.layer.rasterizationScale = 2
        self.clipsToBounds = true
        self.layer.masksToBounds = true
        let cgColor: CGColor = color.cgColor
        self.layer.borderColor = cgColor
    }

    func removeBorders() {
        self.layer.borderWidth = 0
        self.layer.cornerRadius = 0
        self.layer.borderColor = nil
    }

    func setCornerRadius(_ radius: CGFloat) {
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
    }
    func setCornerRadiusWithMask(_ radius: CGFloat,byRoundingCorner:UIRectCorner) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: byRoundingCorner, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
        self.layer.masksToBounds = true
    }
    
    /**
     Removes all subviews from current view
     */
    func removeAllSubviews() {
        self.subviews.forEach { (subview) -> () in
            subview.removeFromSuperview()
        }
    }


    func blink() {
        UIView.animate(withDuration: 0.5, //Time duration you want,
            delay: 0.0,
            options: [.curveEaseInOut, .autoreverse, .repeat],
            animations: { [weak self] in self?.alpha = 0.0 },
            completion: { [weak self] _ in self?.alpha = 1.0 })

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            self.layer.removeAllAnimations()
        }

    }

    func fadeIn(withDuration duration: TimeInterval = 0.50) {
        UIView.animate(withDuration: duration, animations: {
            self.alpha = 1.0
        })
    }

    func fadeOut(withDuration duration: TimeInterval = 0.50) {
        UIView.animate(withDuration: duration, animations: {
            self.alpha = 0.0
        })
    }

    func dropShadow() {

        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = CGSize(width: -1, height: 1)
        self.layer.shadowRadius = 1

        self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        self.layer.shouldRasterize = true

        self.layer.rasterizationScale = UIScreen.main.scale

    }
}
extension UIView {

    @IBInspectable
    /// Should the corner be as circle
    public var circleCorner: Bool {
        get {
            return min(bounds.size.height, bounds.size.width) / 2 == cornerRadius
        }
        set {
            cornerRadius = newValue ? min(bounds.size.height, bounds.size.width) / 2 : cornerRadius
        }
    }
    
    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }

    @IBInspectable
    var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }

    @IBInspectable
    var borderColor: UIColor? {
        get {
            if let color = layer.borderColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.borderColor = color.cgColor
            } else {
                layer.borderColor = nil
            }
        }
    }

    @IBInspectable
    var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.shadowRadius = newValue
        }
    }

    @IBInspectable
    var shadowOpacity: Float {
        get {
            return layer.shadowOpacity
        }
        set {
            layer.shadowOpacity = newValue
        }
    }

    @IBInspectable
    var shadowOffset: CGSize {
        get {
            return layer.shadowOffset
        }
        set {
            layer.shadowOffset = newValue
        }
    }

    @IBInspectable
    var shadowColor: UIColor? {
        get {
            if let color = layer.shadowColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.shadowColor = color.cgColor
            } else {
                layer.shadowColor = nil
            }
        }
    }

    func addRedBorder(borderWidth:CGFloat = 1){
        self.borderColor = UIColor.red
        self.borderWidth = borderWidth
    }
    func removeBorder(){
        self.borderColor = UIColor.clear
        self.borderWidth = 0
    }
    func addBlackBorder(borderWidth:CGFloat = 1){
        self.borderColor = UIColor.black
        self.borderWidth = borderWidth
    }
    enum ViewBorder: String {
        case left, right, top, bottom
    }


    func add(border: ViewBorder, color: UIColor, width: CGFloat) {
        let borderLayer = CALayer()
        borderLayer.backgroundColor = color.cgColor
        borderLayer.name = border.rawValue
        switch border {
        case .left:
            borderLayer.frame = CGRect(x: 0, y: 0, width: width, height: self.frame.size.height)
        case .right:
            borderLayer.frame = CGRect(x: self.frame.size.width - width, y: 0, width: width, height: self.frame.size.height)
        case .top:
            borderLayer.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: width)
        case .bottom:
            borderLayer.frame = CGRect(x: 0, y: self.frame.size.height - width, width: self.frame.size.width, height: width)
        }
        self.layer.addSublayer(borderLayer)
    }

    func remove(border: ViewBorder) {
        guard let sublayers = self.layer.sublayers else { return }
        var layerForRemove: CALayer?
        for layer in sublayers {
            if layer.name == border.rawValue {
                layerForRemove = layer
            }
        }
        if let layer = layerForRemove {
            layer.removeFromSuperlayer()
        }
    }


    func copyView<T: UIView>() -> T {
        return NSKeyedUnarchiver.unarchiveObject(with: NSKeyedArchiver.archivedData(withRootObject: self)) as! T
    }

}

extension UITableViewCell{
    static var identifire:String{
        return String.init(describing: self)
    }
}

extension UICollectionViewCell{
    static var identifire:String{
        return String.init(describing: self)
    }
}

extension UICollectionView {
//    func reloadData(completion: @escaping ()->()) {
//        UIView.animate(withDuration: 0, animations: { self.reloadData() })
//        { _ in completion() }
//    }
}

extension UIPageViewController {
    var isPagingEnabled: Bool {
        get {
            var isEnabled: Bool = true
            for view in view.subviews {
                if let subView = view as? UIScrollView {
                    isEnabled = subView.isScrollEnabled
                }
            }
            return isEnabled
        }
        set {
            for view in view.subviews {
                if let subView = view as? UIScrollView {
                    subView.isScrollEnabled = newValue
                }
            }
        }
    }
}

extension UIViewController {

    func bgColor(_ color: UIColor) {
        self.view.backgroundColor=color
    }
    
    static let identifire = String.init(describing: self)
}

extension UIImage{

    // Rotate inage

    func correctlyOrientedImage() -> UIImage
    {
        if self.imageOrientation == UIImage.Orientation.up {
            return self
        }

        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        let normalizedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!;
        UIGraphicsEndImageContext();

        return normalizedImage;
    }

    func compressImage(_ image:UIImage) -> UIImage {
        // Reducing file size to a 10th

        var actualHeight : CGFloat = image.size.height
        var actualWidth : CGFloat = image.size.width
        let maxHeight : CGFloat = 800
        let maxWidth : CGFloat = 600
        var imgRatio : CGFloat = actualWidth/actualHeight
        let maxRatio : CGFloat = maxWidth/maxHeight
        //var compressionQuality : CGFloat = 0.7

        if (actualHeight > maxHeight || actualWidth > maxWidth){
            if(imgRatio < maxRatio){
                //adjust width according to maxHeight
                imgRatio = maxHeight / actualHeight;
                actualWidth = imgRatio * actualWidth;
                actualHeight = maxHeight;
            }
            else if(imgRatio > maxRatio){
                //adjust height according to maxWidth
                imgRatio = maxWidth / actualWidth;
                actualHeight = imgRatio * actualHeight;
                actualWidth = maxWidth;
            }
            else{
                actualHeight = maxHeight;
                actualWidth = maxWidth;
                //compressionQuality = 1;
            }
        }

        let rect = CGRect(x: 0.0, y: 0.0, width: actualWidth, height: actualHeight);
        UIGraphicsBeginImageContext(rect.size);
        image.draw(in: rect)
        let img = UIGraphicsGetImageFromCurrentImageContext();
        //let imageData = UIImageJPEGRepresentation(img!, compressionQuality);
        //UIGraphicsEndImageContext();

        return img!;
    }

    func convertToBase64String() -> String
    {
        let imageData = self.jpegData(compressionQuality: 0.5)
        let base64String = imageData?.base64EncodedString(options: .lineLength64Characters)
        return base64String!
    }
}

//extension Date {
//
//    var formatted: String {
//        let formatter = DateFormatter()
//        formatter.setLocale()
//        formatter.dateFormat = "yyyy-MM-dd"
//        return  formatter.string(from: self as Date)
//    }
//    
//    var timeFormatted: String {
//        let formatter = DateFormatter()
//        formatter.setLocale()
//        formatter.dateFormat = "HH:mm"
//        return  formatter.string(from: self as Date)
//    }
//    
//    var formattedWithUTC : String
//    {
//        let formatter = DateFormatter()
//        formatter.setLocale()
//        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
//        formatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
//        return  formatter.string(from: self as Date)
//    }
//
//    func add(years: Int = 0, months: Int = 0, days: Int = 0, hours: Int = 0, minutes: Int = 0, seconds: Int = 0) -> Date {
//        var targetDay: Date
//        targetDay = Calendar.current.date(byAdding: .year, value: years, to: self)!
//        targetDay = Calendar.current.date(byAdding: .month, value: months, to: targetDay)!
//        targetDay = Calendar.current.date(byAdding: .day, value: days, to: targetDay)!
//        targetDay = Calendar.current.date(byAdding: .hour, value: hours, to: targetDay)!
//        targetDay = Calendar.current.date(byAdding: .minute, value: minutes, to: targetDay)!
//        targetDay = Calendar.current.date(byAdding: .second, value: seconds, to: targetDay)!
//        return targetDay
//    }
//}

extension UIDevice {

    var modelName: String {

        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }

        switch identifier {
        case "iPod5,1":                                 return "iPod Touch 5"
        case "iPod7,1":                                 return "iPod Touch 6"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
        case "iPhone4,1":                               return "iPhone 4s"
        case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
        case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
        case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
        case "iPhone7,2":                               return "iPhone 6"
        case "iPhone7,1":                               return "iPhone 6 Plus"
        case "iPhone8,1":                               return "iPhone 6s"
        case "iPhone8,2":                               return "iPhone 6s Plus"
        case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
        case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
        case "iPhone8,4":                               return "iPhone SE"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
        case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
        case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
        case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
        case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
        case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
        case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
        case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
        case "iPad6,3", "iPad6,4", "iPad6,7", "iPad6,8":return "iPad Pro"
        case "AppleTV5,3":                              return "Apple TV"
        case "i386", "x86_64":                          return "Simulator"
        default:                                        return identifier
        }
    }
}

extension Bundle {
    var releaseVersionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    var buildVersionNumber: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
}

extension NSObject
{
    class func fromClassName(className : String) -> NSObject
    {
        let className = Bundle.main.infoDictionary!["CFBundleName"] as! String + "." + className
        let aClass = NSClassFromString(className) as! NSObject.Type
        return aClass.init()
    }

    class func parseJSONData(fromDictionary dictionary: NSDictionary)
    {

    }
}


extension UITextField
{
    func set_Left_Padding_field(width: Int, height:Int) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height)))
        self.leftView = paddingView
        self.leftViewMode = .always
    }

    func set_Right_Padding_field(width: Int, height:Int) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height)))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}

extension UITextField
{
    open override func awakeFromNib() {
        self.isDefaultValidation = true
    }

    private struct defaultValidation{
        static var val1 : Bool = true
    }

    var isDefaultValidation : Bool?
    {
        get{
            return objc_getAssociatedObject(self, &defaultValidation.val1) as? Bool
        }
        set{
            if let unwrapeValue = newValue
            {
                objc_setAssociatedObject(self, &defaultValidation.val1, unwrapeValue as Bool?, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }

        }
    }

}

extension UITextView
{
    open override func awakeFromNib() {
        self.isDefaultValidation = true
    }

    private struct defaultValidation{
        static var val1 : Bool = true
    }

    var isDefaultValidation : Bool?
    {
        get{
            return objc_getAssociatedObject(self, &defaultValidation.val1) as? Bool
        }
        set{
            if let unwrapeValue = newValue
            {
                objc_setAssociatedObject(self, &defaultValidation.val1, unwrapeValue as Bool?, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }

        }
    }

}
extension UISearchBar {

    func change(textFont : UIFont?) {

        for view : UIView in (self.subviews[0]).subviews {

            if let textField = view as? UITextField {
                textField.font = textFont
                textField.backgroundColor = UIColor.white
            }
        }
    }
}

class CustumTextField: UITextField {

    override func canPerformAction(_ action: Selector, withSender sender: (Any)?) -> Bool {
        UIMenuController.shared.isMenuVisible = false
        return false
    }
}
