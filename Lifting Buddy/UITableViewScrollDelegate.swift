//
//  UITableViewScrollDelegate.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 1/28/18.
//  Copyright © 2018 Christopher Perkins. All rights reserved.
//

protocol UITableViewScrollDelegate {
    func scrollToCell(atIndexPath indexPath: IndexPath, position: UITableViewScrollPosition,
                      animated: Bool)
}
