//
//  TagListView.swift
//  TagListViewDemo
//
//  Created by Dongyuan Liu on 2015-05-09.
//  Copyright (c) 2015 Ela. All rights reserved.
//

import UIKit

@objc public protocol TagListViewDelegate {
    optional func tagPressed(title: String, tagView: TagView, sender: TagListView) -> Void
    optional func didTappedShowMore(sender: TagListView)
    optional func tagRemoveButtonPressed(title: String, tagView: TagView, sender: TagListView) -> Void
}

@IBDesignable
public class TagListView: UIView {
    
    var generalLineNumber:UInt = 1
    private var showMore: TagView = TagView()
    
    func initData() {
        clipsToBounds = true
        setupShowMore()
        showMore.onTap = { [weak self] _ in
            self?.lineNumber = self?.lineNumber == self?.generalLineNumber ? 0 : self?.generalLineNumber            
            self?.delegate?.didTappedShowMore?(self!)
        }
    }
    
    public init() {
        super.init(frame: CGRectZero)
        initData()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initData()
    }
    
    @IBInspectable public dynamic var showMoreTextColor: UIColor = UIColor.grayColor()
    @IBInspectable public dynamic var showMoreFont: UIFont = UIFont.systemFontOfSize(3)
    @IBInspectable public dynamic var showMoreBorderWidth: CGFloat = 0
    @IBInspectable public dynamic var showMorePaddingX: CGFloat = 5
    @IBInspectable public dynamic var showMoreBorderColor: UIColor?
    @IBInspectable public dynamic var textColor: UIColor = UIColor.whiteColor()
    @IBInspectable public dynamic var selectedTextColor: UIColor = UIColor.whiteColor()
    @IBInspectable public dynamic var tagBackgroundColor: UIColor = UIColor.grayColor()
    @IBInspectable public dynamic var tagHighlightedBackgroundColor: UIColor?
    @IBInspectable public dynamic var tagSelectedBackgroundColor: UIColor?
    @IBInspectable public dynamic var cornerRadius: CGFloat = 0
    @IBInspectable public dynamic var borderWidth: CGFloat = 0
    @IBInspectable public dynamic var borderColor: UIColor?
    @IBInspectable public dynamic var selectedBorderColor: UIColor?
    @IBInspectable public dynamic var paddingY: CGFloat = 2
    @IBInspectable public dynamic var paddingX: CGFloat = 5
    @IBInspectable public dynamic var marginY: CGFloat = 2
    @IBInspectable public dynamic var marginX: CGFloat = 5
    @objc public enum Alignment: Int {
        case Left
        case Center
        case Right
    }
    @IBInspectable public var alignment: Alignment = .Left
    @IBInspectable public dynamic var shadowColor: UIColor = UIColor.whiteColor()
    @IBInspectable public dynamic var shadowRadius: CGFloat = 0
    @IBInspectable public dynamic var shadowOffset: CGSize = CGSizeZero
    @IBInspectable public dynamic var shadowOpacity: Float = 0
    @IBInspectable public dynamic var enableRemoveButton: Bool = false
    @IBInspectable public dynamic var removeButtonIconSize: CGFloat = 12
    @IBInspectable public dynamic var removeIconLineWidth: CGFloat = 1
    @IBInspectable public dynamic var removeIconLineColor: UIColor = UIColor.whiteColor().colorWithAlphaComponent(0.54)
    public dynamic var textFont: UIFont = UIFont.systemFontOfSize(12)
    @IBOutlet public weak var delegate: TagListViewDelegate?
    
    public private(set) var tagsInActive: [TagView] = []
    public private(set) var tagViews: [TagView] = []
    private(set) var tagBackgroundViews: [UIView] = []
    private(set) var rowViews: [UIView] = []
    var tagViewHeight: CGFloat = 0
    public var lineNumber: UInt! = 0
    private(set) var rows: UInt = 0 {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
    
    // MARK: - Layout
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        relayoutSubviews()
    }
    
    public func relayoutSubviews() {
        refreshStyle()
        rearrangeViews()
    }
    
    private func refreshStyle() {
        for tagView in tagViews {
            setupTagView(tagView)
        }
        setupShowMore()
    }
    
    private func rearrangeViews() {        
        let views = tagViews as [UIView] + tagBackgroundViews + rowViews
        for view in views {
            view.removeFromSuperview()
        }
        showMore.removeFromSuperview()
        rowViews.removeAll(keepCapacity: true)

        var currentRow: UInt = 0
        var currentRowView: UIView!
        var currentRowTagCount = 0
        var currentRowWidth: CGFloat = 0
        for (index, nextTagView) in tagViews.enumerate() {
            var tagView = nextTagView
            tagView.frame.size = tagView.intrinsicContentSize()
            tagViewHeight = tagView.frame.height
            showMore.setTitle("\(tagViews.count - index) MORE...", forState: .Normal)
            
//            print(">>>>>>> \(tagView.titleLabel?.text) \(showMore.titleLabel?.text)")
//            if tagView.titleLabel?.text == "Tag - 4"
//                && showMore.titleLabel?.text == "1 MORE..."{
//                print("<<<<")
//            }
            
            if lineNumber != 0
                && lineNumber <= currentRow { // is full
                showMore.frame.size = showMore.intrinsicContentSize()
                if frame.width != 0 && currentRowWidth + showMore.frame.width > frame.width {
                    NSException(name: "Tag name is too long", reason: "I don't know how to deal with this situation", userInfo: nil).raise()
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
            tagBackgroundView.layer.shadowColor = shadowColor.CGColor
            tagBackgroundView.layer.shadowPath = UIBezierPath(roundedRect: tagBackgroundView.bounds, cornerRadius: cornerRadius).CGPath
            tagBackgroundView.layer.shadowOffset = shadowOffset
            tagBackgroundView.layer.shadowOpacity = shadowOpacity
            tagBackgroundView.layer.shadowRadius = shadowRadius
            
            tagBackgroundView.addSubview(tagView)
            currentRowView.addSubview(tagBackgroundView)

            currentRowTagCount += 1
            currentRowWidth += tagView.frame.width + marginX
            
            switch alignment {
            case .Left:
                currentRowView.frame.origin.x = 0
            case .Center:
                currentRowView.frame.origin.x = (frame.width - (currentRowWidth - marginX)) / 2
            case .Right:
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
    
    public override func intrinsicContentSize() -> CGSize {
        var height: CGFloat
        if lineNumber == 0 {
            height = CGFloat(rows) * (tagViewHeight + marginY)
        } else {
            height = CGFloat(min(rows, lineNumber)) * (tagViewHeight + marginY)
        }
        
        if rows > 0 {
            height -= marginY
        }
        return CGSizeMake(frame.width, height)
    }
    
    public func setupShowMore() {
        let tagView = showMore
        tagView.textColor = showMoreTextColor
        tagView.textFont = showMoreFont
        tagView.borderWidth = showMoreBorderWidth
        tagView.borderColor = showMoreBorderColor
        tagView.cornerRadius = cornerRadius
        tagView.paddingX = showMorePaddingX
        tagView.paddingY = paddingY
        tagView.tagBackgroundColor = UIColor.clearColor()
        tagView.addTarget(self, action: #selector(tagPressed(_:)), forControlEvents: .TouchUpInside)
    }
    
    public func setupTagViews() {
        for tagView in tagViews {
            setupTagView(tagView)
        }
    }
    
    public func setupTagView(tagView: TagView) {
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
        tagView.addTarget(self, action: #selector(tagPressed(_:)), forControlEvents: .TouchUpInside)
        tagView.removeButton.addTarget(self, action: #selector(removeButtonPressed(_:)), forControlEvents: .TouchUpInside)
        
        // Deselect all tags except this one
        tagView.onLongPress = { this in
            for tag in self.tagViews {
                tag.selected = (tag == this)
            }
        }
    }
    
    public func reuseTagView(title: String) -> TagView {
        var tagView: TagView
        if tagsInActive.count > 0 {
            tagView = tagsInActive.removeFirst()
            tagView.setTitle(title, forState: .Normal)
        } else {
            tagView = TagView(title: title)
        }
        return tagView
    }
    
    public func addTags(titles: [String]) {
        for title in titles {
            let tagView = reuseTagView(title)
            setupTagView(tagView)
            tagViews.append(tagView)
            tagBackgroundViews.append(UIView(frame: tagView.bounds))
        }
        rearrangeViews()
    }
    
    public func addTag(title: String) -> TagView {
        let tagView = reuseTagView(title)
        setupTagView(tagView)
        return addTagView(tagView)
    }
    
    public func addTagView(tagView: TagView) -> TagView {
        tagViews.append(tagView)
        tagBackgroundViews.append(UIView(frame: tagView.bounds))
        rearrangeViews()
        
        return tagView
    }
    
    public func removeTag(title: String) {
        // loop the array in reversed order to remove items during loop
        for index in (tagViews.count - 1).stride(through: 0, by: -1) {
            let tagView = tagViews[index]
            if tagView.currentTitle == title {
                removeTagView(tagView)
            }
        }
    }
    
    public func removeTagView(tagView: TagView) {
        tagsInActive.append(tagView)
        tagView.removeFromSuperview()
        let index = tagViews.indexOf(tagView)!
        tagViews.removeAtIndex(index)
        tagBackgroundViews.removeAtIndex(index)
        
        rearrangeViews()
    }
    
    public func removeAllTags() {
        let views = tagViews as [UIView] + tagBackgroundViews
        for view in views {
            view.removeFromSuperview()
        }
        tagsInActive.appendContentsOf(tagViews)
        tagViews = []
        tagBackgroundViews = []
        rearrangeViews()
    }

    public func selectedTags() -> [TagView] {
        return tagViews.filter() { $0.selected == true }
    }
    
    // MARK: - Events
    
    func tagPressed(sender: TagView!) {
        sender.onTap?(sender)
        delegate?.tagPressed?(sender.currentTitle ?? "", tagView: sender, sender: self)
    }
    
    func removeButtonPressed(closeButton: CloseButton!) {
        if let tagView = closeButton.tagView {
            delegate?.tagRemoveButtonPressed?(tagView.currentTitle ?? "", tagView: tagView, sender: self)
        }
    }
}
