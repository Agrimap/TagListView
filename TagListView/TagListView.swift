//
//  TagListView.swift
//  TagListViewDemo
//
//  Created by Dongyuan Liu on 2015-05-09.
//  Copyright (c) 2015 Ela. All rights reserved.
//

import UIKit

@objc public protocol TagListViewDelegate {
    @objc optional func tagPressed(_ title: String, tagView: TagView, sender: TagListView) -> Void
    @objc optional func didTappedShowMore(_ sender: TagListView)
    @objc optional func tagRemoveButtonPressed(_ title: String, tagView: TagView, sender: TagListView) -> Void
}

@IBDesignable
open class TagListView: UIView {
    
    var generalLineNumber:UInt = 1
    open var showMore: TagView = TagView()
    
    func initData() {
        clipsToBounds = true
        setupShowMore()
        showMore.onTap = { [weak self] _ in
            self?.lineNumber = self?.lineNumber == self?.generalLineNumber ? 0 : self?.generalLineNumber            
            self?.delegate?.didTappedShowMore?(self!)
        }
    }
    
    public init() {
        super.init(frame: CGRect.zero)
        initData()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initData()
    }
    
    @IBInspectable open dynamic var showMoreTextColor: UIColor = UIColor.gray
    @IBInspectable open dynamic var showMoreFont: UIFont = UIFont.systemFont(ofSize: 3)
    @IBInspectable open dynamic var showMoreBorderWidth: CGFloat = 0
    @IBInspectable open dynamic var showMorePaddingX: CGFloat = 5
    @IBInspectable open dynamic var showMoreBorderColor: UIColor?
    @IBInspectable open dynamic var textColor: UIColor = UIColor.white
    @IBInspectable open dynamic var selectedTextColor: UIColor = UIColor.white
    @IBInspectable open dynamic var tagBackgroundColor: UIColor = UIColor.gray
    @IBInspectable open dynamic var tagHighlightedBackgroundColor: UIColor?
    @IBInspectable open dynamic var tagSelectedBackgroundColor: UIColor?
    @IBInspectable open dynamic var cornerRadius: CGFloat = 0
    @IBInspectable open dynamic var borderWidth: CGFloat = 0
    @IBInspectable open dynamic var borderColor: UIColor?
    @IBInspectable open dynamic var selectedBorderColor: UIColor?
    @IBInspectable open dynamic var paddingY: CGFloat = 2
    @IBInspectable open dynamic var paddingX: CGFloat = 5
    @IBInspectable open dynamic var marginY: CGFloat = 2
    @IBInspectable open dynamic var marginX: CGFloat = 5
    @objc public enum Alignment: Int {
        case left
        case center
        case right
    }
    @IBInspectable open var alignment: Alignment = .left
    @IBInspectable open dynamic var shadowColor: UIColor = UIColor.white
    @IBInspectable open dynamic var shadowRadius: CGFloat = 0
    @IBInspectable open dynamic var shadowOffset: CGSize = CGSize.zero
    @IBInspectable open dynamic var shadowOpacity: Float = 0
    @IBInspectable open dynamic var enableRemoveButton: Bool = false
    @IBInspectable open dynamic var removeButtonIconSize: CGFloat = 12
    @IBInspectable open dynamic var removeIconLineWidth: CGFloat = 1
    @IBInspectable open dynamic var removeIconLineColor: UIColor = UIColor.white.withAlphaComponent(0.54)
    open dynamic var textFont: UIFont = UIFont.systemFont(ofSize: 12)
    @IBOutlet open weak var delegate: TagListViewDelegate?
    
    open fileprivate(set) var tagsInActive: [TagView] = []
    open fileprivate(set) var tagViews: [TagView] = []
    fileprivate(set) var tagBackgroundViews: [UIView] = []
    fileprivate(set) var rowViews: [UIView] = []
    var tagViewHeight: CGFloat = 0
    open var lineNumber: UInt! = 0
    fileprivate(set) var rows: UInt = 0 {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
    
    // MARK: - Layout
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        relayoutSubviews()
    }
    
    open func relayoutSubviews() {
        refreshStyle()
        rearrangeViews()
    }
    
    fileprivate func refreshStyle() {
        for tagView in tagViews {
            setupTagView(tagView)
        }
        setupShowMore()
    }
    
    fileprivate func rearrangeViews() {        
        let views = tagViews as [UIView] + tagBackgroundViews + rowViews
        for view in views {
            view.removeFromSuperview()
        }
        showMore.removeFromSuperview()
        rowViews.removeAll(keepingCapacity: true)

        var currentRow: UInt = 0
        var currentRowView: UIView!
        var currentRowTagCount = 0
        var currentRowWidth: CGFloat = 0
        for (index, nextTagView) in tagViews.enumerated() {
            var tagView = nextTagView
            tagView.frame.size = tagView.intrinsicContentSize
            tagViewHeight = tagView.frame.height
            showMore.setTitle("\(tagViews.count - index) MORE...", for: UIControlState())
            
//            print(">>>>>>> \(tagView.titleLabel?.text) \(showMore.titleLabel?.text)")
//            if tagView.titleLabel?.text == "Tag - 4"
//                && showMore.titleLabel?.text == "1 MORE..."{
//                print("<<<<")
//            }
            
            if lineNumber != 0
                && lineNumber <= currentRow { // is full
                showMore.frame.size = showMore.intrinsicContentSize
                if frame.width != 0 && currentRowWidth + showMore.frame.width > frame.width {
                    NSException(name: NSExceptionName(rawValue: "Tag name is too long"), reason: "I don't know how to deal with this situation", userInfo: nil).raise()
                } else if currentRowWidth + tagView.frame.width + showMore.frame.width + marginX > frame.width
                    && !(index + 1 == tagViews.count
                        && currentRowWidth + tagView.frame.width <= frame.width) {
                    tagView = showMore
                }
            } else if currentRowTagCount == 0 || currentRowWidth + tagView.frame.width > frame.width {
                currentRow += 1
                currentRowWidth = 0
                currentRowTagCount = 0
                currentRowView = UIView()
                currentRowView.frame.origin.y = CGFloat(currentRow - 1) * (tagViewHeight + marginY)
                
                rowViews.append(currentRowView)
                addSubview(currentRowView)
            }
            let tagBackgroundView = tagBackgroundViews[index]
            if tagView == showMore {
                tagBackgroundView.frame.origin = CGPoint(x: currentRowWidth, y: (currentRowView.frame.size.height - tagView.bounds.size.height) / 2 )
            } else {
                tagBackgroundView.frame.origin = CGPoint(x: currentRowWidth, y: 0)
            }
            tagBackgroundView.frame.size = tagView.bounds.size
            tagBackgroundView.layer.shadowColor = shadowColor.cgColor
            tagBackgroundView.layer.shadowPath = UIBezierPath(roundedRect: tagBackgroundView.bounds, cornerRadius: cornerRadius).cgPath
            tagBackgroundView.layer.shadowOffset = shadowOffset
            tagBackgroundView.layer.shadowOpacity = shadowOpacity
            tagBackgroundView.layer.shadowRadius = shadowRadius
            
            tagBackgroundView.addSubview(tagView)
            currentRowView.addSubview(tagBackgroundView)

            currentRowTagCount += 1
            currentRowWidth += tagView.frame.width + marginX
            
            switch alignment {
            case .left:
                currentRowView.frame.origin.x = 0
            case .center:
                currentRowView.frame.origin.x = (frame.width - (currentRowWidth - marginX)) / 2
            case .right:
                currentRowView.frame.origin.x = frame.width - (currentRowWidth - marginX)
            }
            currentRowView.frame.size.width = currentRowWidth
            currentRowView.frame.size.height = max(tagViewHeight, currentRowView.frame.height)
            
            if tagView == showMore {
                break
            }
        }
        rows = currentRow
        
        invalidateIntrinsicContentSize()
    }
    
    // MARK: - Manage tags
    
    open override var intrinsicContentSize : CGSize {
        var height: CGFloat
        if lineNumber == 0 {
            height = CGFloat(rows) * (tagViewHeight + marginY)
        } else {
            height = CGFloat(min(rows, lineNumber)) * (tagViewHeight + marginY)
        }
        
        if rows > 0 {
            height -= marginY
        }
        return CGSize(width: frame.width, height: height)
    }
    
    open func setupShowMore() {
        let tagView = showMore
        tagView.textColor = showMoreTextColor
        tagView.textFont = showMoreFont
        tagView.borderWidth = showMoreBorderWidth
        tagView.borderColor = showMoreBorderColor
        tagView.cornerRadius = cornerRadius
        tagView.paddingX = showMorePaddingX
        tagView.paddingY = paddingY
        tagView.tagBackgroundColor = UIColor.clear
        tagView.addTarget(self, action: #selector(tagPressed(_:)), for: .touchUpInside)
    }
    
    open func setupTagViews() {
        for tagView in tagViews {
            setupTagView(tagView)
        }
    }
    
    open func setupTagView(_ tagView: TagView) {
        tagView.textColor = textColor
        tagView.selectedTextColor = selectedTextColor
        tagView.tagBackgroundColor = tagBackgroundColor
        tagView.highlightedBackgroundColor = tagHighlightedBackgroundColor
        tagView.selectedBackgroundColor = tagSelectedBackgroundColor
        tagView.cornerRadius = cornerRadius
        tagView.borderWidth = borderWidth
        tagView.borderColor = borderColor
        tagView.selectedBorderColor = selectedBorderColor
        tagView.paddingX = paddingX
        tagView.paddingY = paddingY
        tagView.textFont = textFont
        tagView.removeIconLineWidth = removeIconLineWidth
        tagView.removeButtonIconSize = removeButtonIconSize
        tagView.enableRemoveButton = enableRemoveButton
        tagView.removeIconLineColor = removeIconLineColor
        tagView.addTarget(self, action: #selector(tagPressed(_:)), for: .touchUpInside)
        tagView.removeButton.addTarget(self, action: #selector(removeButtonPressed(_:)), for: .touchUpInside)
        
        // Deselect all tags except this one
        tagView.onLongPress = { this in
            for tag in self.tagViews {
                tag.isSelected = (tag == this)
            }
        }
    }
    
    open func reuseTagView(_ title: String) -> TagView {
        var tagView: TagView
        if tagsInActive.count > 0 {
            tagView = tagsInActive.removeFirst()
            tagView.setTitle(title, for: UIControlState())
        } else {
            tagView = TagView(title: title)
        }
        return tagView
    }
    
    open func addTags(_ titles: [String]) {
        for title in titles {
            let tagView = reuseTagView(title)
            setupTagView(tagView)
            tagViews.append(tagView)
            tagBackgroundViews.append(UIView(frame: tagView.bounds))
        }
        rearrangeViews()
    }
    
    @discardableResult
    open func addTag(_ title: String) -> TagView {
        let tagView = reuseTagView(title)
        setupTagView(tagView)
        return addTagView(tagView)
    }
    
    open func addTagView(_ tagView: TagView) -> TagView {
        tagViews.append(tagView)
        tagBackgroundViews.append(UIView(frame: tagView.bounds))
        rearrangeViews()
        
        return tagView
    }
    
    open func removeTag(_ title: String) {
        // loop the array in reversed order to remove items during loop
        for index in stride(from: (tagViews.count - 1), through: 0, by: -1) {
            let tagView = tagViews[index]
            if tagView.currentTitle == title {
                removeTagView(tagView)
            }
        }
    }
    
    open func removeTagView(_ tagView: TagView) {
        tagsInActive.append(tagView)
        tagView.removeFromSuperview()
        let index = tagViews.index(of: tagView)!
        tagViews.remove(at: index)
        tagBackgroundViews.remove(at: index)
        
        rearrangeViews()
    }
    
    open func removeAllTags() {
        let views = tagViews as [UIView] + tagBackgroundViews
        for view in views {
            view.removeFromSuperview()
        }
        tagsInActive.append(contentsOf: tagViews)
        tagViews = []
        tagBackgroundViews = []
        rearrangeViews()
    }

    open func selectedTags() -> [TagView] {
        return tagViews.filter() { $0.isSelected == true }
    }
    
    // MARK: - Events
    
    func tagPressed(_ sender: TagView!) {
        sender.onTap?(sender)
        delegate?.tagPressed?(sender.currentTitle ?? "", tagView: sender, sender: self)
    }
    
    func removeButtonPressed(_ closeButton: CloseButton!) {
        if let tagView = closeButton.tagView {
            delegate?.tagRemoveButtonPressed?(tagView.currentTitle ?? "", tagView: tagView, sender: self)
        }
    }
}
