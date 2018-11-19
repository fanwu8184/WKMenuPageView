//
//  WKMenuView.swift
//  workDictionary
//
//  Created by Fan Wu on 11/13/18.
//  Copyright © 2018 8184. All rights reserved.
//

import Foundation
import UIKit

enum CustomContainerPosition {
    case right
    case left
    case top
    case bottom
}

class WKMenuView: BasicView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    private let reuseIdentifier = "MenuCell"
    
    var menuItems = [UIView]() {
        didSet {
            menuCollectionView.reloadData()
            layoutIfNeeded()
            currentIndex = IndexPath(item: 0, section: 0)
        }
    }
    
    var menuItemHeight: CGFloat = 50 {
        didSet {
            menuCollectionView.collectionViewLayout.invalidateLayout()
            Animation.generalAnimate(animations: { self.layoutIfNeeded() })
            updateIndicationViewConstraint()
            Animation.generalAnimate(animations: { self.layoutIfNeeded() })
        }
    }
    
    var wkMenuPageView: WKMenuPageView?
    private var currentIndex = IndexPath(item: 0, section: 0) {
        didSet {
            selectMenuItemAt(currentIndex)
            updateIndicationViewConstraint()
            updateMenuCellUI(oldValue)
            updateMenuCellUI(currentIndex)
            Animation.generalAnimate(animations: { self.layoutIfNeeded() })
            wkMenuPageView?.scrollToMenuIndex(currentIndex)
            wkMenuPageView?.currentIndexDidChange?(currentIndex)
        }
    }
    
    private let customContainer = UIView()
    
    var customView: UIView! {
        didSet {
            if oldValue != nil {
                oldValue.removeFromSuperview()
            }
            customContainerAddSubView()
        }
    }
    
    var customContainerPosition: CustomContainerPosition = .top {
        didSet {
            updateViewsConstraint()
            Animation.generalAnimate(animations: { self.layoutIfNeeded() })
            updateIndicationViewConstraint()
            Animation.generalAnimate(animations: { self.layoutIfNeeded() })
        }
    }
    
    private var customContainerFactor: CGFloat = 0.25 {
        didSet {
            updateViewsConstraint()
            Animation.generalAnimate(animations: { self.layoutIfNeeded() })
            updateIndicationViewConstraint()
            Animation.generalAnimate(animations: { self.layoutIfNeeded() })
        }
    }
    
    private lazy var menuCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.register(MenuCellView.self, forCellWithReuseIdentifier: reuseIdentifier)
        cv.backgroundColor = .clear
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()
    
    var selectedColor: UIColor = .red {
        didSet {
            menuCollectionView.visibleCells.forEach { (cell) in
                if let menuCell = cell as? MenuCellView {
                    menuCell.selectedColor = selectedColor
                    menuCell.updateUI()
                }
            }
        }
    }
    
    var notSelectedColor: UIColor = .blue {
        didSet {
            menuCollectionView.visibleCells.forEach { (cell) in
                if let menuCell = cell as? MenuCellView {
                    menuCell.notSelectedColor = notSelectedColor
                    menuCell.updateUI()
                }
            }
        }
    }
    
    let indicationView = UIView()
    
    private var scrollViewContentOffsetY: CGFloat = 0 {
        didSet {
            updateIndicationViewConstraint()
            Animation.generalAnimate(animations: { self.layoutIfNeeded() })
        }
    }
    
    override var bounds: CGRect {
        didSet {
            updateViewsConstraint()
            //select and scroll to indexPath after Constraints updating are done
            layoutIfNeeded()
            selectMenuItemAt(currentIndex)
            updateIndicationViewConstraint()
        }
    }
    
    private var customContainerLeftConstraint: NSLayoutConstraint?
    private var customContainerTopConstraint: NSLayoutConstraint?
    private var customContainerHeightConstraint: NSLayoutConstraint?
    private var customContainerWidthConstraint: NSLayoutConstraint?
    
    private var menuCollectionViewLeftConstraint: NSLayoutConstraint?
    private var menuCollectionViewTopConstraint: NSLayoutConstraint?
    private var menuCollectionViewHeightConstraint: NSLayoutConstraint?
    private var menuCollectionViewWidthConstraint: NSLayoutConstraint?
    
    private var indicationViewLeftConstraint: NSLayoutConstraint?
    private var indicationViewTopConstraint: NSLayoutConstraint?
    private var indicationViewHeightConstraint: NSLayoutConstraint?
    private var indicationViewWidthConstraint: NSLayoutConstraint?
    
    override func setupViews() {
        super.setupViews()
        backgroundColor = .white
        setupIndicationView()
        setupMenuCollectionView()
        setupCustomContainer()
    }
    
    private func setupCustomContainer() {
        addSubview(customContainer)
        customContainer.translatesAutoresizingMaskIntoConstraints = false
        customContainerLeftConstraint = customContainer.leftAnchor.constraint(equalTo: leftAnchor, constant: 0)
        customContainerTopConstraint = customContainer.topAnchor.constraint(equalTo: topAnchor, constant: 0)
        customContainerHeightConstraint = customContainer.heightAnchor.constraint(equalToConstant: 0)
        customContainerWidthConstraint = customContainer.widthAnchor.constraint(equalToConstant: 0)
        customContainerLeftConstraint?.isActive = true
        customContainerTopConstraint?.isActive = true
        customContainerHeightConstraint?.isActive = true
        customContainerWidthConstraint?.isActive = true
    }
    
    private func setupMenuCollectionView() {
        addSubview(menuCollectionView)
        menuCollectionView.translatesAutoresizingMaskIntoConstraints = false
        menuCollectionViewLeftConstraint = menuCollectionView.leftAnchor.constraint(equalTo: leftAnchor, constant: 0)
        menuCollectionViewTopConstraint = menuCollectionView.topAnchor.constraint(equalTo: topAnchor, constant: 0)
        menuCollectionViewHeightConstraint = menuCollectionView.heightAnchor.constraint(equalToConstant: 0)
        menuCollectionViewWidthConstraint = menuCollectionView.widthAnchor.constraint(equalToConstant: 0)
        menuCollectionViewLeftConstraint?.isActive = true
        menuCollectionViewTopConstraint?.isActive = true
        menuCollectionViewHeightConstraint?.isActive = true
        menuCollectionViewWidthConstraint?.isActive = true
    }
    
    private func setupIndicationView() {
        addSubview(indicationView)
        indicationView.translatesAutoresizingMaskIntoConstraints = false
        indicationViewLeftConstraint = indicationView.leftAnchor.constraint(equalTo: leftAnchor, constant: 0)
        indicationViewTopConstraint = indicationView.topAnchor.constraint(equalTo: topAnchor, constant: 0)
        indicationViewHeightConstraint = indicationView.heightAnchor.constraint(equalToConstant: 0)
        indicationViewWidthConstraint = indicationView.widthAnchor.constraint(equalToConstant: 0)
        indicationViewLeftConstraint?.isActive = true
        indicationViewTopConstraint?.isActive = true
        indicationViewHeightConstraint?.isActive = true
        indicationViewWidthConstraint?.isActive = true
    }
    
    // MARK: currentIndex Functions
    func getCurrentIndex() -> IndexPath {
        return currentIndex
    }
    
    func setCurrentIndex(_ indexPath: IndexPath) {
        if indexPath.row < menuItems.count && indexPath.row >= 0 {
            currentIndex = indexPath
        }
    }
    
    // MARK: CustomContainer Functions
    private func customContainerAddSubView() {
        customContainer.addSubview(customView)
        customView.translatesAutoresizingMaskIntoConstraints = false
        customView.leadingAnchor.constraint(equalTo: customContainer.leadingAnchor, constant: 0).isActive = true
        customView.trailingAnchor.constraint(equalTo: customContainer.trailingAnchor, constant: 0).isActive = true
        customView.topAnchor.constraint(equalTo: customContainer.topAnchor, constant: 0).isActive = true
        customView.bottomAnchor.constraint(equalTo: customContainer.bottomAnchor, constant: 0).isActive = true
    }
    
    // MARK: CustomContainerFactor Functions
    func getCustomContainerFactor() -> CGFloat {
        return customContainerFactor
    }
    
    func setCustomContainerFactor(_ value: CGFloat) {
        if value > 1 {
            customContainerFactor = 1
        } else if value < 0 {
            customContainerFactor = 0
        } else {
            customContainerFactor = value
        }
    }
    
    // MARK: CustomContainer And MenuCollectionView Constraints Funtions
    private func updateViewsConstraint() {
        switch customContainerPosition {
        case .top:
            updateCustomContainerVerticalPositionConstraint()
            customContainerTopConstraint?.constant = 0
            updateMenuCollectionViewVerticalPositionConstraint()
            menuCollectionViewTopConstraint?.constant = bounds.height * customContainerFactor
        case .bottom:
            updateCustomContainerVerticalPositionConstraint()
            customContainerTopConstraint?.constant = bounds.height * (1 - customContainerFactor)
            updateMenuCollectionViewVerticalPositionConstraint()
            menuCollectionViewTopConstraint?.constant = 0
        case .left:
            updateCustomContainerHorizontalPositionConstraint()
            customContainerLeftConstraint?.constant = 0
            updateMenuCollectionViewHorizontalPositionConstraint()
            menuCollectionViewLeftConstraint?.constant = bounds.width * customContainerFactor
        case .right:
            updateCustomContainerHorizontalPositionConstraint()
            customContainerLeftConstraint?.constant = bounds.width * (1 - customContainerFactor)
            updateMenuCollectionViewHorizontalPositionConstraint()
            menuCollectionViewLeftConstraint?.constant = 0
        }
        menuCollectionView.collectionViewLayout.invalidateLayout()
    }
    
    private func updateCustomContainerVerticalPositionConstraint() {
        customContainerLeftConstraint?.constant = 0
        customContainerHeightConstraint?.constant = bounds.height * customContainerFactor
        customContainerWidthConstraint?.constant = bounds.width
    }
    
    private func updateCustomContainerHorizontalPositionConstraint() {
        customContainerTopConstraint?.constant = 0
        customContainerHeightConstraint?.constant = bounds.height
        customContainerWidthConstraint?.constant = bounds.width * customContainerFactor
    }
    
    private func updateMenuCollectionViewVerticalPositionConstraint() {
        menuCollectionViewLeftConstraint?.constant = 0
        menuCollectionViewHeightConstraint?.constant = bounds.height * (1 - customContainerFactor)
        menuCollectionViewWidthConstraint?.constant = bounds.width
    }
    
    private func updateMenuCollectionViewHorizontalPositionConstraint() {
        menuCollectionViewTopConstraint?.constant = 0
        menuCollectionViewHeightConstraint?.constant = bounds.height
        menuCollectionViewWidthConstraint?.constant = bounds.width * (1 - customContainerFactor)
    }
    
    // MARK: IndicationView Constraints Funtions
    private func updateIndicationViewConstraint() {
        if let seletedCell = menuCollectionView.cellForItem(at: currentIndex) {
            indicationViewLeftConstraint?.constant = menuCollectionView.frame.origin.x + seletedCell.frame.origin.x
            indicationViewTopConstraint?.constant = menuCollectionView.frame.origin.y + seletedCell.frame.origin.y - scrollViewContentOffsetY
            indicationViewHeightConstraint?.constant = seletedCell.frame.height
            indicationViewWidthConstraint?.constant = seletedCell.frame.width
        } else {
            if bounds.width == 0 || bounds.height == 0 {
                indicationViewHeightConstraint?.constant = 0
                indicationViewWidthConstraint?.constant = 0
            }
        }
    }
    
    // MARK: Miscellaneous Functions
    private func selectMenuItemAt(_ indexPath: IndexPath) {
        if menuItems.count > 0 && indexPath.row < menuItems.count {
            menuCollectionView.scrollToItem(at: indexPath, at: [], animated: true)
            menuCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: [])
        }
    }
    
    private func updateMenuCellUI(_ indexPath: IndexPath) {
        if let menuCell = menuCollectionView.cellForItem(at: indexPath) as? MenuCellView {
            menuCell.updateUI()
        }
    }
    
    // MARK: ScrollView Functions
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollViewContentOffsetY = scrollView.contentOffset.y
    }
    
    // MARK: CollectionView Functions
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let menuCell = cell as? MenuCellView {
            
            menuCell.selectedColor = selectedColor
            menuCell.notSelectedColor = notSelectedColor
            menuCell.item = menuItems[indexPath.row]
            
            //not visible cells cause problems (selectMenuItemAt not working properly), so have to run the code below to update UI
            if indexPath == currentIndex {
                menuCell.isSelected = true
                menuCell.updateUI()
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: menuItemHeight)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        currentIndex = indexPath
    }
}
