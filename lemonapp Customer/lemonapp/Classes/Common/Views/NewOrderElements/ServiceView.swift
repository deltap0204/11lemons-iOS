import Foundation
import UIKit
import Bond

class ServiceView: UIView {
    
    fileprivate static let buttonSize: CGFloat = 75
    fileprivate static let buttonSmallSize: CGFloat = 65
    fileprivate static let checkMarkSize: CGFloat = 32
    fileprivate static let titleHeight: CGFloat = 21
    fileprivate static let titleMarginTop: CGFloat = 4
    fileprivate static let spacerSize: CGFloat = 20
    fileprivate static let containerSize: CGFloat = buttonSize + titleMarginTop + titleHeight
    fileprivate static let containerSmallSize: CGFloat = buttonSmallSize + titleMarginTop + titleHeight
    
    @IBOutlet fileprivate weak var titleView: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet fileprivate weak var scrollView: UIScrollView!
    @IBOutlet fileprivate weak var btnSetVisibility: UIButton!
    @IBOutlet fileprivate weak var btnEdit: UIButton!
    
    var items = MutableObservableArray<ServiceItem>()
    var isRoundButtons: Bool
    var isLabelVisible: Bool
    var canChangeVisibility: Bool
    var lineCount: Int
    var isMultiSelect: Bool
    var isSmallButton: Bool
    var currentServiceView: UIView?
    
    fileprivate(set) var isVisible: Bool = true
    fileprivate var isEditMode: Bool = false
    fileprivate var buttons: [UIButton] = []
    fileprivate var checkMarks: [UIImageView] = []
    
    var onSelectClosure: ((_ position: Int, _ isSelected: Bool) -> ())?
    
    var onHiddenAll: (() -> ())?
    
    var onHoldAndEdit: ((_ service:Service) -> ())?
    
    var onHoldAndEditAttribute: ((_ attribute:Attribute) -> ())?
    
    var onEdit: (() -> ())?
    
    var onAddElement: (() -> ())?
    
    convenience init (items: [ServiceItem]) {
        self.init(frame: CGRect.zero, items: items, lineCount: 1, isRoundButtons: true, isLabelVisible: true, canChangeVisibility: true, isMultiSelect: true, isSmallButton: false)
    }
    
    convenience init (items: [ServiceItem], lineCount: Int, isRoundButtons: Bool = true, isLabelVisible: Bool = true,
                      canChangeVisibility: Bool = true, isMultiSelect: Bool = true, isSmallButton: Bool = false) {
        self.init(frame: CGRect.zero, items: items, lineCount: lineCount, isRoundButtons: isRoundButtons, isLabelVisible: isLabelVisible, canChangeVisibility: canChangeVisibility, isMultiSelect: isMultiSelect, isSmallButton: isSmallButton)
    }
    
    init(frame: CGRect, items: [ServiceItem], lineCount: Int, isRoundButtons: Bool, isLabelVisible: Bool, canChangeVisibility: Bool, isMultiSelect: Bool, isSmallButton: Bool) {
        self.isRoundButtons = isRoundButtons
        self.isLabelVisible = isLabelVisible
        self.lineCount = lineCount > 0 ? lineCount : 1
        self.items.replace(with: items)
        self.canChangeVisibility = canChangeVisibility
        self.isMultiSelect = isMultiSelect
        self.isSmallButton = isSmallButton
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.isRoundButtons = true
        self.isLabelVisible = true
        self.lineCount = 1
        self.canChangeVisibility = true
        self.isMultiSelect = true
        self.isSmallButton = false
        super.init(coder: aDecoder)
        initialize()
    }
    
    fileprivate func initialize() {
        let containerS = isSmallButton ? ServiceView.containerSmallSize : ServiceView.containerSize
        
        let lineHeight = self.isLabelVisible ? containerS : containerS - ServiceView.titleHeight - ServiceView.titleMarginTop
        
        if currentServiceView == nil {
            if let view = Bundle.main.loadNibNamed("ServiceView", owner: self, options: nil)![0] as? UIView {
                self.frame = CGRect(origin: self.frame.origin, size: CGSize(width: view.frame.width, height: view.frame.height - 131 + lineHeight * CGFloat(self.lineCount)))
                view.frame = self.frame
                view.isUserInteractionEnabled = true
                currentServiceView = view
                self.addSubview(view)
            }
        }
        
        self.items.observeNext { [weak self] event in
            self?.scrollView.subviews.forEach({ $0.removeFromSuperview() })
            
            if let items = self?.items.array, let lineCount = self?.lineCount {
                var maxScrollViewContentSize: CGFloat = 0
                for i in 0..<lineCount {
                    
                    var scrollViewContentSize: CGFloat = 0
                    var xPosition: CGFloat = 0
                    
                    for j in 0..<items.count {
                        
                        if (j % lineCount != i) {
                            continue
                        }
                        
                        let containerView = UIView()
                        let isSmall = self?.isSmallButton ?? false
                        let containerS = isSmall ? ServiceView.containerSmallSize : ServiceView.containerSize
                        
                        containerView.frame.size.width = containerS
                        containerView.frame.size.height = containerS
                        containerView.frame.origin.y = lineHeight * CGFloat(i)
                        containerView.frame.origin.x = xPosition
                        containerView.isUserInteractionEnabled = true
                        
                        let button = UIButton()
                        button.contentMode = UIViewContentMode.scaleAspectFit
                        button.backgroundColor = UIColor.white
                        button.tintColor = UIColor.appBlueColor
                        button.contentHorizontalAlignment = .center
                        button.contentVerticalAlignment = .center
                        button.isSelected = items[j].isSelected
                        button.frame.size.width = ServiceView.buttonSize
                        button.frame.size.height = ServiceView.buttonSize
                        
                        let isAttribute = items[j].attribute != nil
                        let checkMark = UIImageView(image: UIImage(named: "ic_default_on"))
                        if isAttribute && items[j].selectedImage == nil {
                            checkMark.isHidden = !items[j].attribute!.isSelected
                            checkMark.contentMode = UIViewContentMode.scaleAspectFit
                            checkMark.alpha = 0.75
                            checkMark.frame.size.width = ServiceView.checkMarkSize
                            checkMark.frame.size.height = ServiceView.checkMarkSize
                            checkMark.frame.origin.x = (ServiceView.buttonSize / 2) - (ServiceView.checkMarkSize / 2)
                            checkMark.frame.origin.y = (ServiceView.buttonSize / 2) - (ServiceView.checkMarkSize / 2)
                            button.addSubview(checkMark)
                            self?.checkMarks.append(checkMark)
                        }
                        
                        if (self?.isRoundButtons ?? true) {
                            if items[j].isRectangle == nil || items[j].isRectangle == false {
                                button.cornerRadius = ServiceView.buttonSize / 2
                            }
                        }
                        button.isUserInteractionEnabled = true
                        button.setImage(items[j].image, for: UIControlState())
                        button.setTitleColor(UIColor.appBlueColor, for: UIControlState())
                        if items[j].image != nil {
                            button.backgroundColor = UIColor.clear
                            button.setTitleColor(UIColor.clear, for: UIControlState())
                        }
                        
                        if !isAttribute  || items[j].selectedImage != nil {
                            button.setImage(items[j].selectedImage, for: .selected)
                            button.setTitleColor(UIColor.clear, for: .selected)
                        }
                        
                        //add touch long here
                        let holdGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(ServiceView.showHoldAndEditEvent(_:)));
                        containerView.tag = j
                        holdGestureRecognizer.minimumPressDuration = 1.00;
                        containerView.addGestureRecognizer(holdGestureRecognizer);
                        
                        button.bnd_tap.observeNext { [weak self] in
                            if let items = self?.items.array {
                                if !(self?.isMultiSelect ?? true) {
                                    //No MultiSelect
                                    if button.isSelected {
                                        items.forEach {
                                            $0.isSelected = false
                                        }
                                        self?.buttons.forEach {
                                            $0.isSelected = false
                                            if !isAttribute || items[j].selectedImage != nil {
                                                if items[j].image != nil {
                                                    button.backgroundColor = UIColor.clear
                                                } else {
                                                    $0.backgroundColor = items[j].isSelected ? UIColor.appBlueColor : UIColor.white
                                                }
                                            }
                                        }
                                        self?.checkMarks.forEach {
                                            $0.isHidden = true
                                        }
                                        
                                        button.isSelected = items[j].isSelected
                                        if isAttribute && items[j].selectedImage == nil  {
                                            checkMark.isHidden = !items[j].isSelected
                                        }
                                    } else {
                                        items.forEach {
                                            $0.isSelected = false
                                        }
                                        self?.buttons.forEach {
                                            $0.isSelected = false
                                            if !isAttribute || items[j].selectedImage != nil {
                                                if items[j].image != nil {
                                                    button.backgroundColor = UIColor.clear
                                                } else {
                                                    $0.backgroundColor = items[j].isSelected ? UIColor.appBlueColor : UIColor.white
                                                }
                                            }
                                        }
                                        self?.checkMarks.forEach {
                                            $0.isHidden = true
                                        }
                                        items[j].isSelected = true
                                        button.isSelected = true
                                        if isAttribute && items[j].selectedImage == nil  {
                                            checkMark.isHidden = false
                                        }
                                    }
                                } else {
                                    items[j].isSelected = !items[j].isSelected
                                    button.isSelected = items[j].isSelected
                                    if isAttribute && items[j].selectedImage == nil  {
                                        checkMark.isHidden = !items[j].isSelected
                                    }
                                }
                                if !isAttribute || items[j].selectedImage != nil {
                                    if items[j].image != nil {
                                        button.backgroundColor = UIColor.clear
                                    } else {
                                        button.backgroundColor = items[j].isSelected ? UIColor.appBlueColor : UIColor.white
                                    }
                                }
                                
                                if let onSelectClosure = self?.onSelectClosure {
                                    onSelectClosure(j, items[j].isSelected)
                                }
                            }
                        }
                        self?.buttons.append(button)
                        
                        if !(self?.isLabelVisible ?? true) {
                            button.setTitle(items[j].title)
                            button.titleLabel?.numberOfLines = 1
                            button.titleLabel?.adjustsFontSizeToFitWidth = true
                            button.titleLabel?.lineBreakMode = .byClipping
                        }
                        containerView.addSubview(button)
                        
                        if (self?.isLabelVisible ?? true) {
                            let label = UILabel()
                            label.text = items[j].title
                            label.frame.origin.y = button.frame.size.height + ServiceView.titleMarginTop
                            label.frame.size.width = button.bounds.width
                            label.frame.size.height = ServiceView.titleHeight
                            label.textColor = UIColor.appBlueColor
                            label.font = label.font.withSize(11)
                            label.textAlignment = .center
                            containerView.addSubview(label)
                        }
                        let spacerS: CGFloat = isSmall ? 0 : ServiceView.spacerSize
                        xPosition += ServiceView.buttonSize + spacerS
                        scrollViewContentSize += ServiceView.buttonSize + spacerS
                        self?.scrollView.addSubview(containerView)
                    }
                    
                    if (scrollViewContentSize > maxScrollViewContentSize) {
                        maxScrollViewContentSize = scrollViewContentSize
                        self?.scrollView.contentSize = CGSize(width: maxScrollViewContentSize, height: lineHeight * CGFloat(lineCount))
                    }
                    
                }
            }
        }
        
        self.scrollView.isUserInteractionEnabled = true
        self.scrollView.isExclusiveTouch = true
        self.scrollView.canCancelContentTouches = true
        self.scrollView.delaysContentTouches = true
        self.scrollView.bounces = true
        
        if canChangeVisibility {
            let longTap = UILongPressGestureRecognizer(target: self, action: #selector(ServiceView.onTitleLongPress(_:)))
            longTap.minimumPressDuration = 1.00
            self.titleView.addGestureRecognizer(longTap)
        }
        enterEditMode(false)
    }
    
    fileprivate func setVisibility(_ isVisible: Bool) {
        self.scrollView.isUserInteractionEnabled = isVisible
        self.alpha = isVisible ? 1 : 0.5
        self.isVisible = isVisible
        self.isUserInteractionEnabled = true
        self.titleView.isUserInteractionEnabled = true
        self.btnSetVisibility.isUserInteractionEnabled = true
        self.btnSetVisibility.setImage((isVisible ? UIImage(named: "ic_visibility") : UIImage(named: "ic_visibility_off")), for: UIControlState())
    }
    
    func enterEditMode(_ isEdit: Bool) {
        btnSetVisibility.isHidden = !isEdit
        btnEdit.isHidden = !isEdit
        self.isEditMode = isEdit
    }
    
    func resetSelection() {
        buttons.forEach {
            $0.isSelected = false
            $0.backgroundColor = UIColor.white
            if $0.imageView != nil && $0.imageView!.image != nil {
                $0.backgroundColor = UIColor.clear
            }
        }
        checkMarks.forEach {
            $0.isHidden = true
        }
        items.array.forEach { $0.isSelected = false }
    }
    
    @IBAction func didButtonEditPressed(_ sender: AnyObject) {
        self.onEdit?()
    }
    
    @IBAction func didButtonAddPressed(_ sender: AnyObject) {
        self.onAddElement?()
    }
    
    @IBAction func didSetVisibilityButtonPressed(_ sender: AnyObject) {
        setVisibility(!self.isVisible)
    }
    
    @objc func onTitleLongPress(_ sender: UILongPressGestureRecognizer) {
        if sender.state != .began {
            return
        }
        enterEditMode(!isEditMode)
    }
    
    @objc func showHoldAndEditEvent(_ sender: UILongPressGestureRecognizer) {
        if sender.state == UIGestureRecognizerState.began {
            
            if let index = sender.view?.tag {
                let itemsArray = self.items.array
                let itemView = itemsArray[index]
                if let service = itemView.service {
                    self.onHoldAndEdit?(service)
                }
                
                if let attribute = itemView.attribute {
                    self.onHoldAndEditAttribute?(attribute)
                }
                
                
            }
        }
    }
    
    //init(frame: CGRect, items: [ServiceItem], lineCount: Int, isRoundButtons: Bool, isLabelVisible: Bool, canChangeVisibility: Bool, isMultiSelect: Bool, isSmallButton: Bool) {
    
    func updateView(items: [ServiceItem], lineCount: Int, isRoundButtons: Bool = true, isLabelVisible: Bool = true, canChangeVisibility: Bool = true, isMultiSelect: Bool = true, isSmallButton: Bool = false) {
        print("updateView")
        
        self.isRoundButtons = isRoundButtons
        self.isLabelVisible = isLabelVisible
        self.lineCount = lineCount > 0 ? lineCount : 1
        self.canChangeVisibility = canChangeVisibility
        self.isMultiSelect = isMultiSelect
        self.isSmallButton = isSmallButton
        
        self.items.replace(with: items)
        initialize()
    }
}
