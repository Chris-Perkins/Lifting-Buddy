//
//  TestVC.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 6/5/19.
//  Copyright © 2019 Christopher Perkins. All rights reserved.
//

import ClingConstraints

class TestVC: UIViewController {

    public let contractingContainer: SizeChangeOnPressViewContainer = {
        let container = SizeChangeOnPressViewContainer()
        container.sizeChangingView.backgroundColor = UIColor.blue
        return container
    }()

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

        view.addSubview(contractingContainer)
        contractingContainer.sizeChangingView.addSubview(testButtonThing)

        contractingContainer.copy(.centerX, .centerY, of: view)
        contractingContainer.copy(.width, .height, of: view).withMultipliers(0.5)

        testButtonThing.copy(.centerX, .centerY, of: contractingContainer.sizeChangingView)
        testButtonThing.backgroundColor = UIColor.black
        testButtonThing.copy(.width, of: contractingContainer.sizeChangingView).withMultipliers(0.5)
    }

    @objc func test() {
        navigationController?.pushViewController(TestVC(), animated: true)
    }
}
