//
//  PaymentSectionView.swift
//  lemonapp
//
//  Created by Lucas Pelizza on 11/13/17.
//  Copyright © 2017 11lemons. All rights reserved.
//

import Foundation
import Bond
import ReactiveKit

final class PaymentSectionView: UIView {
    
    fileprivate let height: CGFloat = CGFloat(52)
    
    @IBOutlet var viewBackground: UIView!
    @IBOutlet fileprivate weak var imgStatus: UIImageView!
    @IBOutlet fileprivate weak var lblPaymentName: UILabel!
    @IBOutlet fileprivate weak var imgPayment: UIImageView!
    let disposeBag = DisposeBag()
    var viewModel = Observable<PaymentSectionViewModel?>(nil)
    
    convenience init(viewModel: Observable<PaymentSectionViewModel?>) {
        self.init(frame: CGRect.zero, viewModel: viewModel)
    }
    
    init(frame: CGRect, viewModel: Observable<PaymentSectionViewModel?>) {
        super.init(frame: frame)
        self.viewModel = viewModel
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    fileprivate func initialize() {
        
        if let view = Bundle.main.loadNibNamed("PaymentSectionView", owner: self, options: nil)![0] as? UIView {
            self.frame = CGRect(origin: self.frame.origin, size: view.frame.size)
            view.isUserInteractionEnabled = true
            view.frame = self.frame
            view.isUserInteractionEnabled = true
            self.addSubview(view)
            
            let gesture = UITapGestureRecognizer(target: self, action: #selector(PaymentSectionView.selected(_:)))
            
            self.viewBackground.addGestureRecognizer(gesture)
        }
        
        viewModel.observeNext { [weak self] vm in
            self?.bindViewModel()
        }.dispose(in:self.disposeBag)
    }
    
    fileprivate func bindViewModel() {
        guard let viewModel = viewModel.value else { return }
        
        imgStatus.image = viewModel.imageStatus
        viewModel.statusColor.bind(to: viewBackground.bnd_backgroundColor)
        viewModel.cardNumber.bind(to: lblPaymentName.bnd_text)
        viewModel.methodImageNamed.observeNext { [weak self] image in
            guard let strongSelf = self else { return }
            strongSelf.imgPayment.image = image
        }.dispose(in: self.disposeBag)
        self.imgStatus.contentMode = .scaleAspectFit
    }
    
    @objc func selected(_ sender:UITapGestureRecognizer){
        self.viewModel.value?.action?()
    }
}
