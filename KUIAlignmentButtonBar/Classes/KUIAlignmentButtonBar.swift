//
//  KUIAlignmentButtonBar.swift
//  KUIAlignmentButtonBar
//
//  Created by kofktu on 2016. 10. 5..
//  Copyright © 2016년 Kofktu. All rights reserved.
//

import UIKit

@objc
public protocol KUIAlignmentButtonBarDelegate: class {
    
    // Required
    func render(buttonBar: KUIAlignmentButtonBar, button: UIButton, index: Int)
    
    // Optional
    optional func click(buttonBar: KUIAlignmentButtonBar, button: UIButton, index: Int)
    optional func selected(buttonBar: KUIAlignmentButtonBar, button: UIButton, index: Int)
    
}

public enum KUIAlignment : Int {
    case Left
    case Right
    case Top
    case Bottom
}

public class KUIAlignmentButtonBar: UIView {

    public weak var delegate: KUIAlignmentButtonBarDelegate?
    
    @IBInspectable public var numberOfButtons: Int = 1
    @IBInspectable public var buttonGap: CGFloat = 4.0
    public var alignment: KUIAlignment = .Left
    public var insets: UIEdgeInsets = UIEdgeInsetsZero
    public private(set) var buttons = [UIButton]()
    
    // selectable
    public var toggle: Bool = false
    public var defaultSelectedIndex: Int = -1
    public private(set) var selectedIndex: Int = -1
    public var selectedButton: UIButton? {
        guard selectedIndex >= 0 else { return nil }
        return buttons[selectedIndex]
    }
    
    deinit {
        removeButtons()
    }
    
    public func refresh() {
        let currentSelectedIndex = selectedIndex
        
        removeButtons()
        
        if toggle {
            selectedIndex = currentSelectedIndex >= 0 ? currentSelectedIndex : defaultSelectedIndex
        }
        
        createButtons()
    }
    
    // MARK: - Private
    private func createButtons() {
        guard buttons.isEmpty else { return }
        
        var lastButton: UIButton?
        
        for index in 0 ..< numberOfButtons {
            let button = createButton()
            button.selected = (index == selectedIndex)
            button.userInteractionEnabled = button.selected ? false : true
            delegate?.render(self, button: button, index: index)
            addSubview(button)
            buttons.append(button)
            
            switch alignment {
            case .Left:
                addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-\(insets.top)-[button]-\(insets.bottom)-|",
                    options: NSLayoutFormatOptions(rawValue: 0),
                    metrics: nil,
                    views: ["button": button]))
                
                if let lastButton = lastButton {
                    addConstraint(NSLayoutConstraint(item: button, attribute: .Leading, relatedBy: .Equal, toItem: lastButton, attribute: .Trailing, multiplier: 1.0, constant: buttonGap))
                } else {
                    addConstraint(NSLayoutConstraint(item: button, attribute: .Leading, relatedBy: .Equal, toItem: self, attribute: .Leading, multiplier: 1.0, constant: insets.left))
                }
            case .Right:
                addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-\(insets.top)-[button]-\(insets.bottom)-|",
                    options: NSLayoutFormatOptions(rawValue: 0),
                    metrics: nil,
                    views: ["button": button]))
                
                if let lastButton = lastButton {
                    addConstraint(NSLayoutConstraint(item: lastButton, attribute: .Leading, relatedBy: .Equal, toItem: button, attribute: .Trailing, multiplier: 1.0, constant: buttonGap))
                } else {
                    addConstraint(NSLayoutConstraint(item: button, attribute: .Trailing, relatedBy: .Equal, toItem: self, attribute: .Trailing, multiplier: 1.0, constant: insets.left))
                }
            case .Top:
                addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-\(insets.left)-[button]-\(insets.right)-|",
                    options: NSLayoutFormatOptions(rawValue: 0),
                    metrics: nil,
                    views: ["button": button]))
                
                if let lastButton = lastButton {
                    addConstraint(NSLayoutConstraint(item: button, attribute: .Top, relatedBy: .Equal, toItem: lastButton, attribute: .Bottom, multiplier: 1.0, constant: buttonGap))
                } else {
                    addConstraint(NSLayoutConstraint(item: button, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1.0, constant: insets.top))
                }
            case .Bottom:
                addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-\(insets.left)-[button]-\(insets.right)-|",
                    options: NSLayoutFormatOptions(rawValue: 0),
                    metrics: nil,
                    views: ["button": button]))
                
                if let lastButton = lastButton {
                    addConstraint(NSLayoutConstraint(item: lastButton, attribute: .Top, relatedBy: .Equal, toItem: button, attribute: .Bottom, multiplier: 1.0, constant: buttonGap))
                } else {
                    addConstraint(NSLayoutConstraint(item: button, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1.0, constant: insets.bottom))
                }
            }
            
            lastButton = button
        }
        
        if let lastButton = lastButton {
            switch alignment {
            case .Left:
                addConstraint(NSLayoutConstraint(item: self, attribute: .Trailing, relatedBy: .Equal, toItem: lastButton, attribute: .Trailing, multiplier: 1.0, constant: insets.right))
            case .Right:
                addConstraint(NSLayoutConstraint(item: self, attribute: .Leading, relatedBy: .Equal, toItem: lastButton, attribute: .Leading, multiplier: 1.0, constant: insets.left))
            case .Top:
                addConstraint(NSLayoutConstraint(item: self, attribute: .Bottom, relatedBy: .Equal, toItem: lastButton, attribute: .Bottom, multiplier: 1.0, constant: insets.bottom))
            case .Bottom:
                addConstraint(NSLayoutConstraint(item: self, attribute: .Top, relatedBy: .Equal, toItem: lastButton, attribute: .Top, multiplier: 1.0, constant: insets.top))
            }
        }
    }
    
    private func createButton() -> UIButton {
        let button = UIButton(type: .Custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(onPressed(_:)), forControlEvents: .TouchUpInside)
        return button
    }
    
    private func removeButtons() {
        guard buttons.count > 0 else { return }
        
        for button in buttons {
            button.removeFromSuperview()
        }
        
        buttons.removeAll()
        selectedIndex = -1
    }
    
    private func clearForSelectedButton() {
        selectedButton?.selected = false
        selectedButton?.userInteractionEnabled = true
    }
    
    // MARK: - Action
    internal func onPressed(button: UIButton) {
        guard let index = buttons.indexOf(button) else { return }
        
        delegate?.click?(self, button: button, index: index)
        
        guard toggle else { return }
        
        if button != selectedButton {
            clearForSelectedButton()
            
            button.userInteractionEnabled = false
            button.selected = true
            selectedIndex = index
            
            delegate?.selected?(self, button: button, index: index)
        }
    }
}
