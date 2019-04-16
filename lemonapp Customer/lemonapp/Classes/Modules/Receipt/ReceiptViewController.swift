//
//  ReceiptViewController.swift
//  lemonapp
//
//  Created by Lucas Pelizza on 9/29/17.
//  Copyright © 2017 11lemons. All rights reserved.
//

import UIKit
import MGSwipeTableCell
import ReactiveKit

final class ReceiptViewController: UIViewController {

    @IBOutlet fileprivate weak var issueReportButton: UIBarButtonItem!
    @IBOutlet fileprivate weak var scrollView: UIScrollView!
    @IBOutlet fileprivate weak var totalBundle: HighlightedButton!
    
    @IBOutlet fileprivate weak var btnDone: UIButton!
    @IBOutlet var doneBtnHeight: NSLayoutConstraint!
    
    var order: Order?
    fileprivate var yPosition: CGFloat = 0
    var viewModel: ReceiptViewModel?
    var disposeBag = DisposeBag()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let order = order {
            self.viewModel = ReceiptViewModel(order: order, delegate: self)
        }
        
        makeConstraintUnderSafeAreaIfIsIphoneX(constraint: doneBtnHeight, baseValue: 60)
        makeButtonBottomContentInsetIfIsIphoneX(button: btnDone)
        self.scrollView.isUserInteractionEnabled = true
        self.scrollView.isExclusiveTouch = true
        self.scrollView.canCancelContentTouches = true
        self.scrollView.delaysContentTouches = true
        addViewToScrollView(initPaddingHeader(), withBackground: false)
        addViewToScrollView(initBillHeader())
        addViewToScrollView(initTableViewItems(), isFullWidth: false)
        addViewToScrollView(initPaymentMethod(), isFullWidth: false, yPadding: CGFloat(25))
        addViewToScrollView(initFeedback(), isFullWidth: false, yPadding: CGFloat(30))
        scrollView.contentSize = CGSize(width: self.scrollView.frame.width, height: scrollView.contentSize.height + 20)
        if let viewModel = viewModel {
            viewModel.totalPriceToShow.map{ String(format: "Total: $%.2f", $0) }.bind(to: totalBundle.bnd_title).dispose(in:self.disposeBag)
            viewModel.totalBundleImage.observeNext {[weak self] img in
                self?.totalBundle.setImage(img, for: UIControlState() )
                }.dispose(in:self.disposeBag)
            
            viewModel.paymentStatusColor.bind(to: totalBundle.bnd_backgroundColor).dispose(in:self.disposeBag)
            viewModel.paymentStatusColor.bind(to: btnDone.bnd_backgroundColor).dispose(in:self.disposeBag)
        }
        
        // Shadow and Radius
        self.setupBtnDone()
    }

    fileprivate func addViewToScrollView(_ view: UIView, isFullWidth: Bool = true, yPos: CGFloat? = nil, yPadding: CGFloat = CGFloat(0), withBackground: Bool = true ) {
        
        let y = yPos ?? self.yPosition
        let width = isFullWidth ? self.scrollView.frame.width : self.scrollView.frame.width * 0.9
        let xPosition = CGFloat(isFullWidth ? 0 : 20)
        let rect = CGRect(x: xPosition, y: yPadding, width: width, height: view.bounds.height)
        view.frame = rect
        view.isUserInteractionEnabled = true
        
        let backgroundViewHeight = view.bounds.height + yPadding + 6
        let backgroundViewFrame = CGRect(x: 0, y: y, width: self.scrollView.frame.width, height: backgroundViewHeight )
        let viewBackground = UIView(frame: backgroundViewFrame)
        viewBackground.backgroundColor = withBackground ? UIColor("#EFEFF4") : UIColor.clear
        
        viewBackground.addSubview(view)
        scrollView.addSubview(viewBackground)
        
        if yPos == nil {
            yPosition += backgroundViewHeight
            scrollView.contentSize = CGSize(width: self.scrollView.frame.width, height: yPosition)
        }
    }
    
    //MARK: - init components
    fileprivate func initPaddingHeader() -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: scrollView.frame.width, height: CGFloat(10)))
        view.backgroundColor = UIColor.clear
        return view
    }
    
    fileprivate func initBillHeader() -> UIView {
        guard let viewModel = viewModel else { return UIView()}
        let view = ReceiptHeaderView(viewModel: viewModel.billHeaderVM)
        return view
    }
    
    fileprivate func initTableViewItems() -> UIView {
        guard let viewModel = viewModel else { return UIView()}
        let tableView = ReceiptTableView(data: viewModel.receiptDetailViewModels, footerVM: viewModel.footerViewModel, swipeTableCellDelegate: self)
        tableView.layer.cornerRadius = 10.0
        tableView.clipsToBounds = true
        
        return addShadow(tableView)
    }
    
    fileprivate func initPaymentMethod() -> UIView {
        guard let viewModel = viewModel else { return UIView()}
        
        viewModel.paymentViewModel.value!.action = { [unowned self] in
            self.showPaymentsOptions()
        }
        let paymentView = PaymentSectionView(viewModel: viewModel.paymentViewModel)
        paymentView.layer.cornerRadius = 10.0
        paymentView.clipsToBounds = true
        
        return addShadow(paymentView)
    }
    
    fileprivate func initFeedback() -> UIView {
        guard let viewModel = viewModel else { return UIView()}
        
        let currentYPosition = yPosition
        let view = FeedbackView()
        view.viewModel = FeedbackViewModel(text: viewModel.order.feedbackText ?? "", rate: viewModel.order.feedbackRating ?? 0)
        view.heightChanged = { [weak self] height in
            guard let strongSelf = self else { return }
            view.removeFromSuperview()
            view.updateHeight(height)
            strongSelf.addViewToScrollView(view, isFullWidth: false, yPos: currentYPosition, yPadding: CGFloat(35))
        }
        return view
    }
    
    fileprivate func addShadow(_ view: UIView) -> UIView {
        let frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: self.scrollView.frame.width * 0.9, height: view.frame.height)
        
        let shadowView = UIView(frame: view.frame)
        shadowView.layer.cornerRadius = 10.0
        shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.shadowOpacity = 0.7;
        shadowView.layer.shadowOffset = CGSize(width: 2, height: 2);
        
        shadowView.addSubview(view)
        view.frame = frame
        return shadowView
    }

    //MARK: - buttons actions
    @IBAction func onDone(_ sender: AnyObject) {
        self.viewModel?.onDone()
    }
    
    fileprivate func showPaymentsOptions() {
        guard let viewModel = self.viewModel,
            viewModel.order.paymentStatus != .paymentProcessedSuccessfully else {return}
        
        self.showPickupPaymentAlert()
    }
    
    fileprivate func showPickupPaymentAlert() {
        if let userWrapper = DataProvider.sharedInstance.userWrapper {
            
            var cardList: [OptionItemProtocol] = userWrapper.activePaymentCards.map { $0 }
            if let applePay = userWrapper.applePayCard {
                cardList.append(applePay)
            }
            
            let paymentPicker = OptionPicker(optionItemList: cardList, optionsType: .paymentCards) { [weak self] selectedPaymentOption in
                guard let strongSelf = self, let viewModel = strongSelf.viewModel else {return}
                
                if let selectedOption = selectedPaymentOption {
                    switch selectedOption {
                    case Option.chose:
                        viewModel.paymentOption.value = selectedOption
                    case Option.new:
                        if let navigationController = strongSelf.navigationController as? YellowNavigationController {
                            navigationController.barStyle.value = .transparent
                        }
                        
                        strongSelf.performSegueWithIdentifier(.NewPayment, sender: viewModel.newPaymentViewModel)
                    }
                }
            }
            self.present(paymentPicker, animated: true, completion: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewModel = sender as? CommonContainerViewModel, let viewController = segue.destination as? CommonContainerViewController {
            viewController.viewModel = viewModel
        }
    }
    
    fileprivate func setupBtnDone() {
        if let viewModel = self.viewModel {
            if viewModel.order.paymentStatus == .applePayComplete || viewModel.order.paymentStatus == .paymentProcessedSuccessfully {

                btnDone.setTitle("Done")
            }
        }
        
        //btnDone.makeTopShadow()
    }
}

extension ReceiptViewController: MGSwipeTableCellDelegate {
    func swipeTableCell(_ cell: MGSwipeTableCell, canSwipe direction: MGSwipeDirection, from point: CGPoint) -> Bool {
        return false
    }
    
    func swipeTableCell(_ cell: MGSwipeTableCell, tappedButtonAt index: Int, direction: MGSwipeDirection, fromExpansion: Bool) -> Bool {
        return true
    }
}

extension ReceiptViewController:  ReceiptViewModelDelegate {
    func goBack() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    func showErrorNoCreatedByUser() {
        
        let actionSheet = UIAlertController(title: "Error", message: "This order has not a valid created user", preferredStyle: .alert)
        let downyAction = UIAlertAction(title: "Ok", style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.goBack()
            
        }
        actionSheet.addAction(downyAction)
        
        self.present(actionSheet, animated: true, completion: nil)
    }
}
