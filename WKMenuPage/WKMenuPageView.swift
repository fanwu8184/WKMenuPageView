//
//  WKMenuPageView.swift
//  workDictionary
//
//  Created by Fan Wu on 11/13/18.
//  Copyright © 2018 8184. All rights reserved.
//

import Foundation
import UIKit

class WKMenuPageView: BasicView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    private let reuseIdentifier = "PageCell"
    
    enum MenuDirection {
        case right
        case left
        case up
        case down
        case none
    }
    
    private var menuDirection: MenuDirection = .none
    var horizontalMenuOutFactor: CGFloat = 0.8
    var verticalOutMenuFactor: CGFloat = 0.8
    
    var currentIndexDidChange: ((IndexPath)->())?
    var currentIndex: IndexPath {
        get {
            return menuView.getCurrentIndex()
        }
        set {
            if newValue != currentIndex {
                menuView.setCurrentIndex(newValue)
            }
        }
    }
    
    var menuPages = [MenuPage]() {
        didSet {
            pageCollectionView.reloadData()
            populateMenuItems()
        }
    }
    
    private lazy var menuView: WKMenuView = {
        let wkm = WKMenuView()
        wkm.wkMenuPageView = self
        return wkm
    }()
    
    var menuViewCustomView: UIView {
        get {
            return menuView.customView
        }
        set {
            menuView.customView = newValue
        }
    }
    
    var menuViewBackgroundColor: UIColor? {
        get {
            return menuView.backgroundColor
        }
        set {
            menuView.backgroundColor = newValue
        }
    }
    
    var selectedMenuColor: UIColor! {
        didSet {
            menuView.selectedColor = selectedMenuColor
        }
    }
    var notSelectedMenuColor: UIColor! {
        didSet {
            menuView.notSelectedColor = notSelectedMenuColor
        }
    }
    
    var menuItemHeight: CGFloat {
        get {
            return menuView.menuItemHeight
        }
        set {
            menuView.menuItemHeight = newValue
        }
    }
    
    var menuCustomContainerPosition: CustomContainerPosition {
        get {
            return menuView.customContainerPosition
        }
        set {
            menuView.customContainerPosition = newValue
        }
    }
    
    var menuCustomContainerFactor: CGFloat {
        get {
            return menuView.getCustomContainerFactor()
        }
        set {
            menuView.setCustomContainerFactor(newValue)
        }
    }
    
    var menuIndicationView: UIView {
        return menuView.indicationView
    }
    
    private lazy var pageCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.register(PageCellView.self, forCellWithReuseIdentifier: reuseIdentifier)
        cv.backgroundColor = .clear
        cv.dataSource = self
        cv.delegate = self
        cv.isPagingEnabled = true
        return cv
    }()
    
    var pageScrollDirection: UICollectionView.ScrollDirection! {
        didSet {
            if let flowLayout = pageCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                flowLayout.scrollDirection = pageScrollDirection
                scrollToMenuIndex(currentIndex)
            }
        }
    }
    
    override var bounds: CGRect {
        didSet {
            updateMenuViewConstraintWhenItIsOut()
        }
    }
    
    private var menuViewLeftConstraint: NSLayoutConstraint?
    private var menuViewRightConstraint: NSLayoutConstraint?
    private var menuViewTopConstraint: NSLayoutConstraint?
    private var menuViewBottomConstraint: NSLayoutConstraint?
    
    convenience init(menuPages: [MenuPage], currentIndexDidChange: ((IndexPath)->())? = nil) {
        self.init(frame: .zero)
        self.menuPages = menuPages
        self.currentIndexDidChange = currentIndexDidChange
        populateMenuItems()
    }
    
    override func setupViews() {
        super.setupViews()
        setupPageCollectionView()
        setupMenuView()
        addSwipeGestureRecognizers()
    }
    
    private func setupMenuView() {
        addSubview(menuView)
        menuViewLeftConstraint = menuView.leftAnchor.constraint(equalTo: leftAnchor, constant: 0)
        menuViewRightConstraint = menuView.rightAnchor.constraint(equalTo: rightAnchor, constant: 0)
        menuViewTopConstraint = menuView.topAnchor.constraint(equalTo: topAnchor, constant: 0)
        menuViewBottomConstraint = menuView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0)
    }
    
    private func setupPageCollectionView() {
        addSubview(pageCollectionView)
        pageCollectionView.translatesAutoresizingMaskIntoConstraints = false
        pageCollectionView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0).isActive = true
        pageCollectionView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0).isActive = true
        pageCollectionView.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        pageCollectionView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
    }
    
    // MARK: MenuView Constraints Funtions
    private func menuDirectionRightBase() {
        menuViewLeftConstraint?.constant = 0
        menuViewRightConstraint?.constant = -bounds.width
        menuViewTopConstraint?.constant = 0
        menuViewBottomConstraint?.constant = 0
    }
    
    private func menuDirectionLeftBase() {
        menuViewLeftConstraint?.constant = bounds.width
        menuViewRightConstraint?.constant = 0
        menuViewTopConstraint?.constant = 0
        menuViewBottomConstraint?.constant = 0
    }
    
    private func menuDirectionUpBase() {
        menuViewLeftConstraint?.constant = 0
        menuViewRightConstraint?.constant = 0
        menuViewTopConstraint?.constant = bounds.height
        menuViewBottomConstraint?.constant = 0
    }
    private func menuDirectionDownBase() {
        menuViewLeftConstraint?.constant = 0
        menuViewRightConstraint?.constant = 0
        menuViewTopConstraint?.constant = 0
        menuViewBottomConstraint?.constant = -bounds.height
    }
    
    private func updateMenuViewConstraintWhenItIsOut() {
        switch menuDirection {
        case .up:
            menuViewTopConstraint?.constant = bounds.height * (1 - verticalOutMenuFactor)
        case .down:
            menuViewBottomConstraint?.constant = bounds.height * (verticalOutMenuFactor - 1)
        case .right:
            menuViewRightConstraint?.constant = bounds.width * (horizontalMenuOutFactor - 1)
        case .left:
            menuViewLeftConstraint?.constant = bounds.width * (1 - horizontalMenuOutFactor)
        default:
            break
        }
    }
    
    // MARK: Gesture Recognizers' Functions
    private func addSwipeGestureRecognizers() {
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGesture))
        swipeUp.direction = .up
        addGestureRecognizer(swipeUp)

        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGesture))
        swipeDown.direction = .down
        addGestureRecognizer(swipeDown)

        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGesture))
        swipeLeft.direction = .left
        addGestureRecognizer(swipeLeft)

        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGesture))
        swipeRight.direction = .right
        addGestureRecognizer(swipeRight)
    }
    
    @objc private func handleSwipeGesture(gesture: UISwipeGestureRecognizer) -> Void {
        menuViewLeftConstraint?.isActive = true
        menuViewRightConstraint?.isActive = true
        menuViewTopConstraint?.isActive = true
        menuViewBottomConstraint?.isActive = true
        
        if menuDirection == .none {
            pullOutMenu(gesture)
        } else {
            pullBackMenu(gesture)
        }
    }
    
    private func pullOutMenu(_ gesture: UISwipeGestureRecognizer) {
        switch gesture.direction {
        case .up:
            menuDirectionUpBase()
            layoutIfNeeded()
            menuDirection = .up
        case .down:
            menuDirectionDownBase()
            layoutIfNeeded()
            menuDirection = .down
        case .right:
            menuDirectionRightBase()
            layoutIfNeeded()
            menuDirection = .right
        case .left:
            menuDirectionLeftBase()
            layoutIfNeeded()
            menuDirection = .left
        default:
            break
        }
        updateMenuViewConstraintWhenItIsOut()
        Animation.generalAnimate(animations: { self.layoutIfNeeded() })
    }
    
    private func pullBackMenu(_ gesture: UISwipeGestureRecognizer) {
        switch gesture.direction {
        case .up:
            if menuDirection == .down {
                menuDirectionDownBase()
                menuDirection = .none
            }
        case .down:
            if menuDirection == .up {
                menuDirectionUpBase()
                menuDirection = .none
            }
        case .right:
            if menuDirection == .left {
                menuDirectionLeftBase()
                menuDirection = .none
            }
        case .left:
            if menuDirection == .right {
                menuDirectionRightBase()
                menuDirection = .none
            }
        default:
            break
        }
        Animation.generalAnimate(animations: { self.layoutIfNeeded() })
        
        menuViewLeftConstraint?.isActive = false
        menuViewRightConstraint?.isActive = false
        menuViewTopConstraint?.isActive = false
        menuViewBottomConstraint?.isActive = false
    }
    
    // MARK: Miscellaneous Functions
    //The reason update collectionView layout in layoutSubviews not in bounds didSet is because putting in bounds didSet will cause layout error message
    override func layoutSubviews() {
        super.layoutSubviews()
        pageCollectionView.collectionViewLayout.invalidateLayout()
        pageCollectionView.layoutIfNeeded()
        scrollToMenuIndex(currentIndex)  //needed after device rotation
    }
    
    private func populateMenuItems() {
        menuView.menuItems = menuPages.map({ $0.menuView })
    }
    
    func scrollToMenuIndex(_ indexPath: IndexPath) {
        if indexPath.row >= 0 && indexPath.row < menuPages.count {
            pageCollectionView.scrollToItem(at: indexPath, at: [], animated: true)
        }
    }
    
    // MARK: ScrollView Functions
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if let flowLayout = pageCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            if flowLayout.scrollDirection.rawValue == 0 {
                currentIndex = IndexPath(item: Int(targetContentOffset.pointee.y / frame.height), section: 0)
            } else {
                currentIndex = IndexPath(item: Int(targetContentOffset.pointee.x / frame.width), section: 0)
            }
        }
    }
    
    // MARK: CollectionView Functions
    func setPagesBounce(_ bounce: Bool) {
        pageCollectionView.bounces = bounce
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return menuPages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let pageCell = cell as? PageCellView {
            pageCell.page = menuPages[indexPath.row].pageView
        }
    }
}
