//
//  TestVC.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 6/5/19.
//  Copyright © 2019 Christopher Perkins. All rights reserved.
//

import ClingConstraints

class TestVC: UIViewController {
    public let testButtonThing: UIButton = {
        let button = UIButton()
        button.setTitle("yo", for: .normal)
        button.setTitleColor(UIColor.red, for: .normal)
        button.addTarget(self, action: #selector(test), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        view.addSubview(testButtonThing)
        testButtonThing.copy(.centerX, .centerY, of: view)
    }

    @objc func test() {
        navigationController?.pushViewController(TestVC(), animated: true)
    }
}
