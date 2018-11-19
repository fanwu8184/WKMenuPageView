//
//  MenuItem.swift
//  workDictionary
//
//  Created by Fan Wu on 10/17/18.
//  Copyright © 2018 8184. All rights reserved.
//

import Foundation
import UIKit

struct MenuPage {
    var title: String
    var menuView: UIView
    var pageView: UIView
    
    init(title: String, menuView: UIView? = nil, pageView: UIView) {
        self.title = title
        self.pageView = pageView
        
        if let mv = menuView {
            self.menuView = mv
        } else {
            let label = UILabel()
            label.text = title
            self.menuView = label
        }
    }
}
