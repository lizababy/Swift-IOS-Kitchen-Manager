//
//  CheckListTableViewCell.swift
//  Kitchen Manager
//
//  Created by Liza Linto on 11/29/15.
//  Copyright © 2015 Liza Linto. All rights reserved.
//

import UIKit

// A protocol that the TableViewCell uses to inform its delegate of state change
protocol TableViewCellDelegate {
    
    // indicates that the given item has been deleted
    func checkListItemDeleted(checkListItem: CheckListItem)
    
    // indicates that the given item has been striked
    func checkListItemStriked(checkListItem: CheckListItem)
    
    // indicates that the given item has been edited
    func checkListItemEdited(oldText : String? , checkListItem: CheckListItem)
    
    // Indicates that the edit process has begun for the given cell
    func cellDidBeginEditing(editingCell: CheckListTableViewCell)
    
    // Indicates that the edit process has committed for the given cell
    func cellDidEndEditing(editingCell: CheckListTableViewCell)
    
}

class CheckListTableViewCell: UITableViewCell, UITextFieldDelegate {
    
    var originalCenter = CGPoint()
    var deleteOnDragRelease = false, strikeOnDragRelease = false
    var tickLabel: UILabel, crossLabel: UILabel
    let label: UITextField
    let kLabelLeftMargin: CGFloat = 15.0
    let kUICuesMargin: CGFloat = 10.0, kUICuesWidth: CGFloat = 50.0
    var oldLabelText :String?
    let gradientLayer = CAGradientLayer()
    
    var itemCheckedLayer = CALayer()
    
    // The object that acts as delegate for this cell.
    var delegate: TableViewCellDelegate?
    // The item that this cell renders.
    var checkListItem: CheckListItem?{
        didSet {
            itemCheckedLayer.hidden = !checkListItem!.striked
            label.text = checkListItem!.text
        }
    }

    
    required init(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        
        // create a label that renders the to-do item text
        label = UITextField(frame: CGRect.null)
        label.textColor = UIColor.blackColor()
        label.font = UIFont.boldSystemFontOfSize(16)
        label.backgroundColor = UIColor.clearColor()
        
        // utility method for creating the contextual cues
        func createCueLabel() -> UILabel {
            let label = UILabel(frame: CGRect.null)
            label.textColor = UIColor.blackColor()
            label.font = UIFont.boldSystemFontOfSize(32.0)
            label.backgroundColor = UIColor.clearColor()
            return label
        }
        
        // tick and cross labels for context cues
        tickLabel = createCueLabel()
        tickLabel.text = "\u{2713}"
        tickLabel.textAlignment = .Right
        crossLabel = createCueLabel()
        crossLabel.text = "\u{2717}"
        crossLabel.textAlignment = .Left
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        
        label.delegate = self
        label.contentVerticalAlignment = .Center
        addSubview(label)
        addSubview(tickLabel)
        addSubview(crossLabel)
        
        // gradient layer for cell
        gradientLayer.frame = bounds
        let color1 = UIColor(white: 1.0, alpha: 0.2).CGColor as CGColorRef
        let color2 = UIColor(white: 1.0, alpha: 0.1).CGColor as CGColorRef
        let color3 = UIColor.clearColor().CGColor as CGColorRef
        let color4 = UIColor(white: 0.0, alpha: 0.1).CGColor as CGColorRef
        gradientLayer.colors = [color1, color2, color3, color4]
        gradientLayer.locations = [0.0, 0.01, 0.95, 1.0]
        layer.insertSublayer(gradientLayer, atIndex: 0)
        
        // add a layer that renders a green background when an item is checked
        itemCheckedLayer = CALayer(layer: layer)
        itemCheckedLayer.backgroundColor = UIColor(red: 0.0, green: 0.6, blue: 0.0, alpha: 1.0).CGColor
        itemCheckedLayer.hidden = true
        layer.insertSublayer(itemCheckedLayer, atIndex: 0)
        
        // add a pan recognizer
        let recognizer = UIPanGestureRecognizer(target: self, action: "handlePan:")
        recognizer.delegate = self
        addGestureRecognizer(recognizer)
    }
    
   
    override func layoutSubviews() {
        super.layoutSubviews()
        // ensure the gradient layer occupies the full bounds
        gradientLayer.frame = bounds
        itemCheckedLayer.frame = bounds
        
        label.frame = CGRect(x: kLabelLeftMargin, y: 0,
            width: bounds.size.width - kLabelLeftMargin, height: bounds.size.height)
        tickLabel.frame = CGRect(x: -kUICuesWidth - kUICuesMargin, y: 0,
            width: kUICuesWidth, height: bounds.size.height)
        crossLabel.frame = CGRect(x: bounds.size.width + kUICuesMargin, y: 0,
            width: kUICuesWidth, height: bounds.size.height)
    }

    //MARK: - horizontal pan gesture methods
    func handlePan(recognizer: UIPanGestureRecognizer) {
        
        if recognizer.state == .Began {
            // when the gesture begins, record the current center location
            originalCenter = center
        }
        
        if recognizer.state == .Changed {
            let translation = recognizer.translationInView(self)
            center = CGPointMake(originalCenter.x + translation.x, originalCenter.y)
            // has the user dragged the item far enough to initiate a delete/check?
            deleteOnDragRelease = frame.origin.x < -frame.size.width / 2.0
            strikeOnDragRelease = frame.origin.x > frame.size.width / 2.0
            
            // fade the contextual clues
            let cueAlpha = fabs(frame.origin.x) / (frame.size.width / 2.0)
            tickLabel.alpha = cueAlpha
            crossLabel.alpha = cueAlpha
            // indicate when the user has pulled the item far enough to invoke the given action
            tickLabel.textColor = strikeOnDragRelease ? UIColor.greenColor() : UIColor.whiteColor()
            crossLabel.textColor = deleteOnDragRelease ? UIColor.redColor() : UIColor.whiteColor()

        }
        
        if recognizer.state == .Ended {
            // the frame this cell had before user dragged it
            let originalFrame = CGRect(x: 0, y: frame.origin.y,
                width: bounds.size.width, height: bounds.size.height)
            
            if deleteOnDragRelease {
                if delegate != nil && checkListItem != nil {
                    // notify the delegate that this item should be deleted
                    delegate!.checkListItemDeleted(checkListItem!)
                }
            } else if strikeOnDragRelease {
                
                checkListItem!.striked = checkListItem!.striked ? false : true
                strikeCell(checkListItem)
                // notify the delegate that this item should be striked
                delegate!.checkListItemStriked(checkListItem!)
                UIView.animateWithDuration(0.2, animations: {self.frame = originalFrame})
            }else {
                // if the item is not being deleted, snap back to the original location
                UIView.animateWithDuration(0.2, animations: {self.frame = originalFrame})
            }
        }
    }
    func strikeCell(item : CheckListItem?) {
        if let checkListItem = item {
            
            itemCheckedLayer.hidden = !checkListItem.striked
            
            let attributes = [
                NSStrikethroughStyleAttributeName : NSUnderlineStyle.StyleThick.rawValue,
                NSStrikethroughColorAttributeName : UIColor.redColor()]
            
            if checkListItem.striked{
                
                let checkedText = NSAttributedString(string: checkListItem.text, attributes: attributes)
                label.attributedText = checkedText
                
            }else{
                
                let unCheckedText = NSAttributedString(string: checkListItem.text, attributes: nil)
                label.attributedText = unCheckedText
                
            }
            
            
        }

    }
    override func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
            let translation = panGestureRecognizer.translationInView(superview!)
            if fabs(translation.x) > fabs(translation.y) {
                return true
            }
            return false
        }
        return false
    }
    // MARK: - UITextFieldDelegate methods
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if delegate != nil {
            
            delegate!.cellDidBeginEditing(self)
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        // close the keyboard on Enter
        textField.resignFirstResponder()
        return false
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        // disable editing of checked items
        if checkListItem != nil {
            oldLabelText = textField.text
            return !checkListItem!.striked
        }
        return false
    }
    
    
    func textFieldDidEndEditing(textField: UITextField) {
        if checkListItem != nil {
            checkListItem!.text = textField.text!
            delegate?.checkListItemEdited(oldLabelText,checkListItem: checkListItem!)
        }
        if delegate != nil {
            delegate!.cellDidEndEditing(self)
        }
    }
    

}
