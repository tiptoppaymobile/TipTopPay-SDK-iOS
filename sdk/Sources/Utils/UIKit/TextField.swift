//
//  TextField.swift
//  sdk
//
//  Created by TipTopPay on 18.09.2020.
//  Copyright © 2020 TipTopPay. All rights reserved.
//

import UIKit

class TextField: UITextField, UITextFieldDelegate {
    private var underlineView : UIView?
    
    @IBInspectable var defaultTextColor: UIColor = UIColor.black
    @IBInspectable var activeColor: UIColor = UIColor.mainBlue
    @IBInspectable var passiveColor: UIColor = UIColor.border
    @IBInspectable var errorColor: UIColor = UIColor.border
    @IBInspectable var insetX: CGFloat = 0
    @IBInspectable var insetY: CGFloat = 0
    
    // placeholder position on textfield
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: insetX, dy: insetY)
    }
    
    // text position on textfield
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: insetX, dy: insetY)
    }
    
    var isEmpty: Bool {
        if let text = self.text, !text.isEmpty {
            return false
        }
        return true
    }
    
    var isErrorMode = false {
        didSet {
            DispatchQueue.main.async {
                self.updateColors()
            }
        }
    }
    
    var shouldBeginEditing : (() -> Bool)? {
        didSet {
            delegateIfNeeded()
        }
    }
    var didBeginEditing : (() -> ())? {
        didSet {
            delegateIfNeeded()
        }
    }
    var shouldEndEditing : (() -> Bool)? {
        didSet {
            delegateIfNeeded()
        }
    }
    var didEndEditing : (() -> ())? {
        didSet {
            delegateIfNeeded()
        }
    }
    var shouldChangeCharactersInRange : ((_ range: NSRange, _ replacement: String) -> Bool)? {
        didSet{
            delegateIfNeeded()
        }
    }
    var shouldClear : (() -> Bool)?{
        didSet {
            delegateIfNeeded()
        }
    }
    var shouldReturn : (() -> Bool)?{
        didSet {
            delegateIfNeeded()
        }
    }
    var didChange : (() -> ())?
    
    @IBInspectable var leftImage : UIImage?{
        didSet {
            let imageView = UIImageView.init(image:leftImage)
            imageView.contentMode = UIView.ContentMode.center
            imageView.frame = CGRect.init(origin: CGPoint.zero, size: self.leftViewSize)
            self.leftView = imageView
            self.leftViewMode = UITextField.ViewMode.always
        }
    }
    @IBInspectable var leftViewSize = CGSize.zero {
        didSet{
            if let view = self.leftView {
                view.frame = CGRect.init(origin: CGPoint.zero, size: leftViewSize)
            }
        }
    }
    
    @IBInspectable var rightImage : UIImage?{
        didSet {
            let imageView = UIImageView.init(image:rightImage)
            imageView.contentMode = UIView.ContentMode.center
            imageView.frame = CGRect.init(origin: CGPoint.zero, size: self.rightViewSize)
            self.rightView = imageView
            self.rightViewMode = UITextField.ViewMode.always
        }
    }
    @IBInspectable var rightViewSize = CGSize.zero {
        didSet{
            if let view = self.rightView {
                view.frame = CGRect.init(origin: CGPoint.zero, size: rightViewSize)
            }
        }
    }
    
    @IBInspectable var borderWidth : CGFloat = 0.0 {
        didSet {
            layer.borderWidth = borderWidth;
        }
    }
    @IBInspectable var borderColor : UIColor = UIColor.clear {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }
    @IBInspectable var cornerRadius : CGFloat = 0.0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initialize()
        self.addTarget(self, action:#selector(textFieldDidChange(textField:)), for: .editingChanged)
    }
    
    func delegateIfNeeded() -> Void {
        if self.delegate == nil {
            self.delegate = self
        } else if !self.delegate!.isEqual(self){
            self.delegate = self
        }
    }
    
    private func getActiveColor() -> UIColor {
        var color = self.activeColor
        if isErrorMode {
            color = self.errorColor
        }
        
        return color
    }
    
    private func getPassiveColor() -> UIColor {
        var color = self.passiveColor
        if isErrorMode {
            color = self.errorColor
        }
        
        return color
    }
    
    private func getTextColor() -> UIColor {
        var color = self.defaultTextColor
        if isErrorMode {
            color = self.errorColor
        }
        
        return color
    }
    
    private func updateColors(){
        if self.isEditing {
            self.underlineView?.backgroundColor = getActiveColor()
        } else {
            self.underlineView?.backgroundColor = getPassiveColor()
        }
        
        self.textColor = getTextColor()
    }
    
    @objc func textFieldDidChange(textField: UITextField) -> Void {
        didChange?()
        setNeedsDisplay()
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return shouldBeginEditing?() ?? true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        didBeginEditing?()
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return shouldEndEditing?() ?? true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        self.underlineView?.backgroundColor = getPassiveColor()
        
        didEndEditing?()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return shouldChangeCharactersInRange?(range, string) ?? true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return shouldClear?() ?? true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return shouldReturn?() ?? true
    }
    
    private func initialize(){
        self.clipsToBounds = false
        self.delegateIfNeeded()
    }
}

extension TextField {
    var cardExpText: String? {
        get {self.text?.replacingOccurrences(of: " ", with: "") }
        set {self.text = newValue?.onlyNumbers().formattedString(mask: "XX / XX", ignoredSymbols: nil)}
    }
}
