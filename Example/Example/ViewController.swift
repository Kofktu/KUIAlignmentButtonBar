//
//  ViewController.swift
//  Example
//
//  Created by kofktu on 2016. 10. 5..
//  Copyright © 2016년 Kofktu. All rights reserved.
//

import UIKit
import KUIAlignmentButtonBar

class ViewController: UIViewController, KUIAlignmentButtonBarDelegate {

    @IBOutlet weak var horizontalButtonBar: KUIAlignmentButtonBar!
    @IBOutlet weak var verticalButtonBar: KUIAlignmentButtonBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        horizontalButtonBar.alignment = .right
        horizontalButtonBar.delegate = self
        horizontalButtonBar.refresh()
        
        verticalButtonBar.alignment = .bottom
        verticalButtonBar.delegate = self
        verticalButtonBar.refresh()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    // MARK: - KUIAlignmentButtonBarDelegate
    func render(_ buttonBar: KUIAlignmentButtonBar, button: UIButton, index: Int) {
        let title = "Title_\(index)"
        
        button.layer.borderColor = UIColor.blue.cgColor
        button.layer.borderWidth = 1.0
        
        button.setTitle(title, for: [])
        button.setTitleColor(UIColor.black, for: [])
    }
    
    // Optional
    func click(_ buttonBar: KUIAlignmentButtonBar, button: UIButton, index: Int) {
        print("index : \(index)")
    }
}

