//
//  PageCellView.swift
//  workDictionary
//
//  Created by Fan Wu on 10/18/18.
//  Copyright © 2018 8184. All rights reserved.
//

import Foundation
import UIKit

class PageCellView: BasicCollectionViewCell {
    
    var page = UIView() {
        didSet {
            page.translatesAutoresizingMaskIntoConstraints = false
            setupPageView()
        }
    }
    
    private func setupPageView() {
        subviews.forEach { $0.removeFromSuperview() }  //this is needed because of reusable cells
        addSubview(page)
        page.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        page.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
        page.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
        page.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true
    }
}
