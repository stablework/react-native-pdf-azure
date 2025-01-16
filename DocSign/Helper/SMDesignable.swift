//
//  AGDesignable.swift
//  Nhyira Premium
//
//  Created by Sahil Moradiya on 02/01/21.
//  Copyright © 2021 Ankit Gabani. All rights reserved.
//

import UIKit
import CoreLocation
import Foundation
// you can set cornerRadius,borderWidth., ect in side storeboard.
@IBDesignable
class DesignableView: UIView {
}

@IBDesignable
class DesignableTextView: UITextView {
}

@IBDesignable
class DesignableButton: UIButton {
}

@IBDesignable
class DesignableLabel: UILabel {
}

@IBDesignable
class DesignableImageView: UIImageView {
}

@IBDesignable
class DesignablePlaceHolder: UITextView {
}

extension UITextField{
    @IBInspectable var placeHolderColor: UIColor? {
        get {
            return self.placeHolderColor
        }
        set {
            self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSAttributedString.Key.foregroundColor: newValue!])
        }
    }
}

@IBDesignable
class PlaceHolderTextView: UITextView {

    @IBInspectable var placeholder: String = "" {
         didSet{
             updatePlaceHolder()
        }
    }

    @IBInspectable var placeholderColor: UIColor = UIColor.gray {
        didSet {
            updatePlaceHolder()
        }
    }

    private var originalTextColor = UIColor.darkText
    private var originalText: String = ""

    private func updatePlaceHolder() {

        if self.text == "" || self.text == placeholder  {

            self.text = placeholder
            self.textColor = placeholderColor
            if let color = self.textColor {

                self.originalTextColor = color
            }
            self.originalText = ""
        } else {
            self.textColor = self.originalTextColor
            self.originalText = self.text
        }

    }

    override func becomeFirstResponder() -> Bool {
        let result = super.becomeFirstResponder()
        self.text = self.originalText
        self.textColor = self.originalTextColor
        return result
    }
    override func resignFirstResponder() -> Bool {
        let result = super.resignFirstResponder()
        updatePlaceHolder()

        return result
    }
}
