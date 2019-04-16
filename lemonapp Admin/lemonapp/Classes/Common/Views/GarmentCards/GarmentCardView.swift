//
//  GarmentCardView.swift
//  lemonapp
//
//  Created by Lucas Pelizza on 12/1/17.
//  Copyright © 2017 11lemons. All rights reserved.
//

import Foundation
import Bond
import SDWebImage

final class GarmentCardView: UIView {
    
    fileprivate let height: CGFloat = CGFloat(64)
    fileprivate var currentView: UIView?
    
    @IBOutlet fileprivate weak var constraintNameWidth: NSLayoutConstraint!
    @IBOutlet fileprivate weak var lblLibras: UILabel!
    @IBOutlet fileprivate weak var lblProductPrice: UILabel!
    @IBOutlet fileprivate weak var lblProductName: UILabel!
    @IBOutlet fileprivate weak var imgProduct: UIImageView!
    @IBOutlet var lblDescriptionList: [UILabel]!
    @IBOutlet var lblPriceList: [UILabel]!
    
    var heightChanged: ((_ height:CGFloat) -> ())?
    var withRadius: Bool
    var viewModel: GarmentCardViewModel?
    
    convenience init(viewModel: GarmentCardViewModel, withRadius:Bool = false) {
        self.init(frame: CGRect.zero, viewModel: viewModel, withRadius: withRadius)
    }
    
    init(frame: CGRect, viewModel: GarmentCardViewModel, withRadius:Bool) {
        self.withRadius = withRadius
        self.viewModel = viewModel
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.withRadius = false
        super.init(coder: aDecoder)
        initialize()
    }
    
    fileprivate func initialize() {
        if let view = Bundle.main.loadNibNamed("GarmentCardView", owner: self, options: nil)![0] as? UIView {
            self.frame = CGRect(origin: self.frame.origin, size: CGSize(width: view.frame.width, height: self.getHeight()))
            view.frame = self.frame
            self.currentView = view
            self.addSubview(self.currentView!)
            let constraintWidth = NSLayoutConstraint(item: currentView!, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 1.0, constant: 0)
            let constraintHeight = NSLayoutConstraint(item: currentView!, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 1.0, constant: 0)
            
            let xConstraint = NSLayoutConstraint(item: currentView!, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0)
            let yConstraint = NSLayoutConstraint(item: currentView!, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0)
            NSLayoutConstraint.activate([constraintWidth, constraintHeight, xConstraint, yConstraint])
        }
        bindViewModel()
    }
    
    fileprivate func bindViewModel() {
        guard let viewModel = self.viewModel else { return }

        resetLbls()
        viewModel.orderName.observeNext { [weak self] name in
            guard let strongSelf = self else { return }
            strongSelf.lblProductName.text = name
            
            let myString: NSString = name as NSString
            let size: CGSize = myString.size(withAttributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 15.0)])
            strongSelf.constraintNameWidth.constant = size.width
            
        }
        
        viewModel.orderProductPrice.map{ return String(format: "$%.2f", $0)}.bind(to: lblProductPrice.bnd_text)
        
        viewModel.productImageRounded.observeNext { [weak self] rounded in
            guard let strongSelf = self else { return }
            
            if rounded {
                strongSelf.imgProduct.cornerRadius = 18
            } else {
                strongSelf.imgProduct.cornerRadius = 0
            }
        }
        
        viewModel.productImage.observeNext { [weak self] image in
            guard let strongSelf = self else { return }
            
            if let img = image {
                strongSelf.imgProduct.image = img
                
            }
        }
        
        viewModel.listOfLines.observeNext { [weak self] lines in
            var index = 0
            guard let strongSelf = self else { return }
            
            strongSelf.resetLbls()
            for lineVM in lines.dataSource.array {
                guard index <= 5 else { return }
                strongSelf.lblDescriptionList[index].text = lineVM.text
                strongSelf.lblDescriptionList[index].isHidden = false
                if lineVM.price > 0 {
                    strongSelf.lblPriceList[index].text = String(format: "$%.2f", lineVM.price)
                    strongSelf.lblPriceList[index].isHidden = false
                }
                index = index + 1
            }
        }
        
        viewModel.lbs.observeNext { [weak self] lbs in
            guard let strongSelf = self else { return }
            
            if lbs == nil {
                strongSelf.lblLibras.isHidden = true
            } else {
                strongSelf.lblLibras.isHidden = false
                if lbs == 0.0 {
                    strongSelf.lblLibras.text = "0.0 lbs"
                    strongSelf.lblLibras.alpha = 0.5
                } else {
                    strongSelf.lblLibras.text = String(format: "%.1f lbs", lbs!)
                    strongSelf.lblLibras.alpha = 1.0
                }
            }
        }
    }
    
    fileprivate func resetLbls() {
        lblPriceList.forEach {
            $0.text = ""
            $0.isHidden = true
        }
        
        lblDescriptionList.forEach {
            $0.text = ""
            $0.isHidden = true
        }
    }
    
    fileprivate func getHeight() -> CGFloat {
        if let viewModel = self.viewModel {
            return viewModel.getHeight()
        } else {
            return height
        }
    }
    
    @IBInspectable var cRadius: CGFloat = 8
    @IBInspectable var shadowOffsetWidth: Int = 0
    @IBInspectable var shadowOffsetHeight: Int = 3
    @IBInspectable var shadowColor: UIColor? = UIColor.black
    @IBInspectable var shadowOpacity: Float = 0.5
    
    override func layoutSubviews() {
        if withRadius {
            applyCornerRadius(self)
            if let currentView = self.currentView {
                applyCornerRadius(currentView)
            }
        }
    }
    
    fileprivate func applyCornerRadius(_ view: UIView) {
        view.layer.cornerRadius = cRadius
        let shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cRadius)
        
        view.layer.masksToBounds = false
        view.layer.shadowColor = shadowColor?.cgColor
        view.layer.shadowOffset = CGSize(width: shadowOffsetWidth, height: shadowOffsetHeight);
        view.layer.shadowOpacity = shadowOpacity
        view.layer.shadowPath = shadowPath.cgPath
    }
}
