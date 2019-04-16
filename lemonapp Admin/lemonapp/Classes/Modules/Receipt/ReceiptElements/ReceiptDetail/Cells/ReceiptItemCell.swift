//
//  ReceiptItemCell.swift
//  lemonapp
//
//  Created by Lucas Pelizza on 9/28/17.
//  Copyright © 2017 11lemons. All rights reserved.
//

import UIKit
import MGSwipeTableCell

final class ReceiptItemCell: MGSwipeTableCell {

    static let identifier = "ReceiptItemCell"
    static let Height = CGFloat(64)
    static let BUTTON_WIDTH: CGFloat = 60
    
    @IBOutlet fileprivate weak var constraintNameWidth: NSLayoutConstraint!
    @IBOutlet fileprivate weak var lblLibras: UILabel!
    @IBOutlet fileprivate weak var lblProductPrice: UILabel!
    @IBOutlet fileprivate weak var lblProductName: UILabel!
    @IBOutlet fileprivate weak var imgProduct: UIImageView!
    @IBOutlet var lblDescriptionList: [UILabel]!
    @IBOutlet var lblPriceList: [UILabel]!
    
    var deleteButton: MGSwipeButton!
    var viewModel: GarmentCardViewModel?
    
    func setup(_ vm: GarmentCardViewModel) {
        self.selectionStyle = UITableViewCellSelectionStyle.none
        self.viewModel = vm
        
        self.deleteButton = MGSwipeButton(title: "", icon: UIImage(named: "ic_delete"), backgroundColor: AddressCell.DELETE_BUTTON_COLOR)
        self.deleteButton.buttonWidth = ReceiptItemCell.BUTTON_WIDTH
        
        self.rightButtons = [deleteButton]
        self.initialize()
    }
    
    fileprivate func initialize() {
        self.frame = CGRect(origin: self.frame.origin, size: CGSize(width: contentView.frame.width, height: self.getHeight()))
        contentView.frame = self.frame
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
            
            if let shouldDisplayLbsLabel = strongSelf.viewModel?.shouldDisplayLbsLabel(), shouldDisplayLbsLabel {
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
            else {
                strongSelf.lblLibras.isHidden = true
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
            return ReceiptItemCell.Height
        }
    }
}
