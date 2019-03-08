import Foundation
import UIKit

class PickupColorView: UIView {
    
    @IBOutlet fileprivate weak var lblTitle: UILabel!
    @IBOutlet fileprivate weak var containerView: UIView!
    var onSelectClosure: ((_ attributes: [Attribute]) -> ())?
    
    fileprivate var attributes: [Attribute] = []
    
    fileprivate let spaceW: CGFloat = 20
    fileprivate let spaceH: CGFloat = 8
    fileprivate let btnSizeH: CGFloat = 30
    fileprivate let btnSizeW: CGFloat = 30
    var buttonsViews: [UIButton] = []
    
    var onHoldAndEdit: ((_ attribute:Attribute) -> ())?
    var currentPickupColorView: UIView?
    
    convenience init(attributes: [Attribute]) {
        self.init(frame: CGRect.zero, attributes: attributes)
    }
    
    init(frame: CGRect, attributes: [Attribute]) {
        super.init(frame: frame)
        self.attributes = attributes
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    fileprivate func initialize() {
        
        let lineCount = Int(ceil(Double(attributes.count) / 9.0))
        var startYPos: CGFloat = 0
        
        if currentPickupColorView != nil {

            startYPos = 74
            self.buttonsViews.forEach({ $0.removeFromSuperview() })
            self.buttonsViews = []
        }
        else {
            if let view = Bundle.main.loadNibNamed("PickupColorView", owner: self, options: nil)![0] as? UIView {
                self.frame = CGRect(origin: self.frame.origin, size: view.frame.size)
                view.isUserInteractionEnabled = true
                
                let height: CGFloat = CGFloat(lineCount) * btnSizeH + CGFloat(lineCount) * spaceH
                
                startYPos = view.frame.height - 136 + spaceH
                self.frame = CGRect(origin: self.frame.origin, size: CGSize(width: view.frame.width, height: startYPos + height))
                view.frame = self.frame
                view.isUserInteractionEnabled = true
                
                currentPickupColorView = view
                self.addSubview(view)
            }
        }
        
        
        let centerPos = (UIScreen.main.bounds.width / 2) - (btnSizeW / 2) - btnSizeW
        let leftPos = centerPos - spaceW - btnSizeW * 3
        let rightPos = centerPos + btnSizeW * 3 + spaceW
        
        var line = -1
        for i in 0..<attributes.count {
            if (i % 9) == 0 {
                line = line + 1
            }
            
            let yPos = startYPos + CGFloat(line) * btnSizeH + CGFloat(line) * spaceH
            var xPos: CGFloat = 0
            switch (i % 9) {
            case 0..<3:
                xPos = leftPos + CGFloat((i % 3)) * btnSizeW
                break;
            case 3..<6:
                xPos = centerPos + CGFloat((i % 3)) * btnSizeW
                break;
            default:
                xPos = rightPos + CGFloat((i % 3)) * btnSizeW
            }
            
            let button = UIButton()
            button.backgroundColor = UIColor.bt_color(fromHex: attributes[i].description, alpha: 1)
            button.tag = attributes[i].id
            button.frame.origin.y = yPos
            button.frame.origin.x = xPos
            button.frame.size.width = btnSizeW
            button.frame.size.height = btnSizeH
            button.isUserInteractionEnabled = true
            button.isSelected = attributes[i].isSelected
            button.setImage(UIImage(named: "ic_default_on"), for: .selected)
            button.addTarget(self, action: #selector(PickupColorView.didColorButtonPressed(_:)), for: .touchUpInside)
            let holdGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(ServiceView.showHoldAndEditEvent(_:)));
            holdGestureRecognizer.minimumPressDuration = 1.00;
            button.addGestureRecognizer(holdGestureRecognizer);
            self.addSubview(button)
            buttonsViews.append(button)
        }
    }
    
    @objc fileprivate func didColorButtonPressed(_ sender: AnyObject) {
        if let button = sender as? UIButton {
            button.isSelected = !button.isSelected
            let id = button.tag
            if button.isSelected {
                UIColor.appBlueColor.hexString(false)
                attributes.filter{$0.id == id}.filter{$0 != nil}.forEach{$0.isSelected = true}
            } else {
                attributes.filter{$0.id == id}.filter{$0 != nil}.forEach{$0.isSelected = false}
            }
            if let onSelectClosure = onSelectClosure {
                onSelectClosure(self.attributes)
            }
        }
    }
    
    @objc func showHoldAndEditEvent(_ sender: UILongPressGestureRecognizer) {
        
        if sender.state == UIGestureRecognizerState.began {
            if let attributeID = sender.view?.tag {
                var attributeSelected: Attribute? = nil
                self.attributes.forEach({ (attribute) in
                    if attribute.id == attributeID {
                        attributeSelected = attribute
                    }
                })
                if let attrSelected = attributeSelected {
                    self.onHoldAndEdit?(attrSelected)
                }
            }
        }
    }
    
    func updateView(attributes: [Attribute]) {
        self.attributes = attributes
        initialize()
    }
}
