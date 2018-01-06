//
//  SettingsViewController.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 1/5/18.
//  Copyright © 2018 Christopher Perkins. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    let prettyButton = PrettyButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(prettyButton)
        
        NSLayoutConstraint.clingViewToView(view: prettyButton, toView: view)
        
        prettyButton.setDefaultProperties()
        prettyButton.addTarget(self, action: #selector(buttonPress(button:)), for: .touchUpInside)
    }
    
    @objc func buttonPress(button: PrettyButton) {
        performBackSegue()
    }
    
    private func performBackSegue() {
        performSegue(withIdentifier: "fromSettings", sender: self)
    }
}
