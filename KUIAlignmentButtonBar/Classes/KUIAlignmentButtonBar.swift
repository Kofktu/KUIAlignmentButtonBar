//
//  KUIAlignmentButtonBar.swift
//  KUIAlignmentButtonBar
//
//  Created by kofktu on 2016. 10. 5..
//  Copyright © 2016년 Kofktu. All rights reserved.
//

import UIKit

@objc public protocol KUIAlignmentButtonBarDelegate: class {
    
    // Required
    func render(_ buttonBar: KUIAlignmentButtonBar, button: UIButton, index: Int)
    
    // Optional
    @objc optional func click(_ buttonBar: KUIAlignmentButtonBar, button: UIButton, index: Int)
    @objc optional func selected(_ buttonBar: KUIAlignmentButtonBar, button: UIButton, index: Int)
    
}

public enum KUIAlignment : Int {
    case left
    case right
    case top
    case bottom
}

open class KUIAlignmentButtonBar: UIView {

    open weak var delegate: KUIAlignmentButtonBarDelegate?
    
    @IBInspectable open var numberOfButtons: Int = 1
    @IBInspectable open var buttonGap: CGFloat = 4.0
    open var alignment: KUIAlignment = .left
    open var insets: UIEdgeInsets = UIEdgeInsets.zero
    open fileprivate(set) var buttons = [UIButton]()
    
    // selectable
    open var isToggle: Bool = false
    open var defaultSelectedIndex: Int = -1
    open fileprivate(set) var selectedIndex: Int = -1
    open var selectedButton: UIButton? {
        guard selectedIndex >= 0 else { return nil }
        return buttons[selectedIndex]
    }
    
    deinit {
        removeButtons()
    }
    
    open func refresh() {
        let currentSelectedIndex = selectedIndex
        
        removeButtons()
        
        if isToggle {
            selectedIndex = currentSelectedIndex >= 0 ? currentSelectedIndex : defaultSelectedIndex
        }
        
        createButtons()
    }
    
    public func select(at index: Int) {
        guard isToggle else { return }
        guard selectedIndex != index else { return }
        
        clearForSelectedButton()
        selectedIndex = index
        
        let button = selectedButton
        button?.isUserInteractionEnabled = false
        button?.isSelected = true
    }
    
    // MARK: - Private
    private func createButtons() {
        guard buttons.isEmpty else { return }
        
        var lastButton: UIButton?
        
        for index in 0 ..< numberOfButtons {
            let button = createButton()
            button.isSelected = (index == selectedIndex)
            button.isUserInteractionEnabled = button.isSelected ? false : true
            delegate?.render(self, button: button, index: index)
            addSubview(button)
            buttons.append(button)
            
            switch alignment {
            case .left:
                addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-\(insets.top)-[button]-\(insets.bottom)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["button": button]))
                
                if let lastButton = lastButton {
                    addConstraint(NSLayoutConstraint(item: button, attribute: .leading, relatedBy: .equal, toItem: lastButton, attribute: .trailing, multiplier: 1.0, constant: buttonGap))
                } else {
                    addConstraint(NSLayoutConstraint(item: button, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: insets.left))
                }
            case .right:
                addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-\(insets.top)-[button]-\(insets.bottom)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["button": button]))
                
                if let lastButton = lastButton {
                    addConstraint(NSLayoutConstraint(item: lastButton, attribute: .leading, relatedBy: .equal, toItem: button, attribute: .trailing, multiplier: 1.0, constant: buttonGap))
                } else {
                    addConstraint(NSLayoutConstraint(item: button, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: insets.left))
                }
            case .top:
                addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-\(insets.left)-[button]-\(insets.right)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["button": button]))
                
                if let lastButton = lastButton {
                    addConstraint(NSLayoutConstraint(item: button, attribute: .top, relatedBy: .equal, toItem: lastButton, attribute: .bottom, multiplier: 1.0, constant: buttonGap))
                } else {
                    addConstraint(NSLayoutConstraint(item: button, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: insets.top))
                }
            case .bottom:
                addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-\(insets.left)-[button]-\(insets.right)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["button": button]))
                
                if let lastButton = lastButton {
                    addConstraint(NSLayoutConstraint(item: lastButton, attribute: .top, relatedBy: .equal, toItem: button, attribute: .bottom, multiplier: 1.0, constant: buttonGap))
                } else {
                    addConstraint(NSLayoutConstraint(item: button, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: insets.bottom))
                }
            }
            
            lastButton = button
        }
        
        if let lastButton = lastButton {
            switch alignment {
            case .left:
                addConstraint(NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: lastButton, attribute: .trailing, multiplier: 1.0, constant: insets.right))
            case .right:
                addConstraint(NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: lastButton, attribute: .leading, multiplier: 1.0, constant: insets.left))
            case .top:
                addConstraint(NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: lastButton, attribute: .bottom, multiplier: 1.0, constant: insets.bottom))
            case .bottom:
                addConstraint(NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: lastButton, attribute: .top, multiplier: 1.0, constant: insets.top))
            }
        }
    }
    
    private func createButton() -> UIButton {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(onPressed(_:)), for: .touchUpInside)
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
        selectedButton?.isSelected = false
        selectedButton?.isUserInteractionEnabled = true
    }
    
    // MARK: - Action
    internal func onPressed(_ button: UIButton) {
        guard let index = buttons.index(of: button) else { return }
        
        delegate?.click?(self, button: button, index: index)
        
        guard isToggle else { return }
        
        if button != selectedButton {
            clearForSelectedButton()
            
            button.isUserInteractionEnabled = false
            button.isSelected = true
            selectedIndex = index
            
            delegate?.selected?(self, button: button, index: index)
        }
    }
}
