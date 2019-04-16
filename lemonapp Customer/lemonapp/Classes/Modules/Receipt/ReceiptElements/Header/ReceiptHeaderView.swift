//
//  ReceiptHeaderView.swift
//  lemonapp
//
//  Created by Lucas Pelizza on 9/29/17.
//  Copyright © 2017 11lemons. All rights reserved.
//

import UIKit
import Bond
import ReactiveKit

final class ReceiptHeaderView: UIView {
    
    static let Height: Double = 168.0
    
    @IBOutlet fileprivate weak var lblName: UILabel!
    @IBOutlet fileprivate weak var imgUser: UIImageView!
    @IBOutlet fileprivate weak var lblCity: UILabel!
    @IBOutlet fileprivate weak var lblAddress: UILabel!
    @IBOutlet fileprivate weak var lblDate: UILabel!
    
    @IBOutlet fileprivate weak var viewHeaderBackground: UIView!
    @IBOutlet fileprivate weak var lblStatus: UILabel!
    @IBOutlet fileprivate weak var viewBackgroundAvatar: UIView!
    @IBOutlet fileprivate weak var lblOrderNumber: UILabel!
    @IBOutlet fileprivate weak var imgBarCode: UIImageView!
    
    var viewModel = Observable<ReceiptHeaderViewModel?>(nil)
    let disposeBag = DisposeBag()
    convenience init(viewModel: Observable<ReceiptHeaderViewModel?>) {
        self.init(frame: CGRect.zero, viewModel: viewModel)
    }
    
    init(frame: CGRect,viewModel: Observable<ReceiptHeaderViewModel?>) {
        super.init(frame: frame)
        self.viewModel = viewModel
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    fileprivate func initialize() {
        
        if let view = Bundle.main.loadNibNamed("ReceiptHeaderView", owner: self, options: nil)![0] as? UIView {
            self.frame = CGRect(origin: self.frame.origin, size: view.frame.size)
            view.isUserInteractionEnabled = true
            self.frame = CGRect(origin: self.frame.origin, size: CGSize(width: view.frame.width, height: CGFloat(ReceiptHeaderView.Height)))
            view.frame = self.frame
            view.isUserInteractionEnabled = true
            self.addSubview(view)
        }
        
        viewModel.observeNext(with: { [weak self] viewModel in
            self?.bindViewModel(viewModel)
        }).dispose(in:self.disposeBag)
    }
    
    fileprivate func bindViewModel(_ viewModelLocal: ReceiptHeaderViewModel?) {
        guard let viewModel = viewModelLocal else { return }
        
        imgUser.cornerRadius = imgUser.frame.height / 2
        viewModel.photoRequest.bind(to: imgUser.bnd_image)
        
        viewModel.orderNumber.map {"Order# \($0)"}.bind(to: lblOrderNumber.bnd_text)
        viewModel.city.bind(to: lblCity.bnd_text)
        viewModel.address.bind(to: lblAddress.bnd_text)
        viewModel.userName.bind(to: lblName.bnd_text)
        viewModel.avatarBackgroundColor.bind(to: viewBackgroundAvatar.bnd_backgroundColor)
        viewModel.status.bind(to: lblStatus.bnd_text)
        viewModel.statusColor.bind(to: viewHeaderBackground.bnd_backgroundColor)
        viewModel.orderDate.map { date in
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "h:mm a"
            dateFormatter.amSymbol = "am"
            dateFormatter.pmSymbol = "pm"
            return dateFormatter.string(from: date)
            }.bind(to: lblDate.bnd_text)
    }

}
