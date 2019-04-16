//
//  ReceiptViewModel.swift
//  lemonapp
//
//  Created by Lucas Pelizza on 11/14/17.
//  Copyright © 2017 11lemons. All rights reserved.
//

import Foundation
import Bond
import ReactiveKit

typealias ActionB = () -> Void

protocol ReceiptViewModelDelegate : class {
    func goBack()
    func showErrorNoCreatedByUser()
    func showErrorNoCreditCardSelected()
}

final class ReceiptViewModel {
    var order: Order
    var totalPrice: Double = 0
    let totalPriceToShow = Observable<Double>(0)
    var totalBundleImage = Observable<UIImage?>(nil)
    
    var paymentViewModel = Observable<PaymentSectionViewModel?>(nil)
    var paymentOption: Option? = nil
    let newPaymentViewModel: CommonContainerViewModel?
    var activePaymentCards: [PaymentCard] = []
    
    var billHeaderVM = Observable<ReceiptHeaderViewModel?>(nil)
    var receiptDetailViewModels = MutableObservableArray<ReceiptItemsSectionVM>([])
    var footerViewModel = Observable<ReceiptFooterVM?>(nil)
    let paymentStatusColor = Observable<UIColor>(UIColor.paymentNotProcessedColor)
    var wallet: NewWallet? = nil
    var somethingHasChanged = false
    weak var delegate: ReceiptViewModelDelegate?
    var disposeBag = DisposeBag()
    
    init(order: Order, delegate: ReceiptViewModelDelegate) {
        self.delegate = delegate
        self.order = order
        self.paymentViewModel.value = PaymentSectionViewModel(order: order)
        if let userWrapper = DataProvider.sharedInstance.userWrapper {
            newPaymentViewModel = CommonContainerViewModel(userWrapper: userWrapper, screenIndetifier: .PaymentCardScreen, backButtonTitle: "Order")
        } else {
            newPaymentViewModel = nil
        }
        
        if let user = order.createdBy {
            self.getWallet(user.id)
        } else {
            self.delegate?.showErrorNoCreatedByUser()
        }
        
        // default payment is available
        if let card = order.card, !card.deleted {
            self.changePaymentOption(card: card)
        } else {
            self.delegate?.showErrorNoCreditCardSelected()
        }
        
        newPaymentViewModel?.result.observeNext { result in
            if let card = result as? PaymentCard {
                self.changePaymentOption(card: card)
            }
        }.dispose(in:self.disposeBag)

        self.setupOrder(order)
        
        if let user = order.createdBy {
            self.getPayments(for: user.id)
        }
        
    }

    func setupOrder(_ order: Order) {
        self.order = order
        self.totalBundleImage.value = OrderHelper.getPaymentStatusIcon(order)
        self.paymentStatusColor.value = order.paymentStatus.color
        self.billHeaderVM.value = ReceiptHeaderViewModel(order: order)
        self.footerViewModel.value = createFooterViewModel(order)
        self.receiptDetailViewModels.replace(with: getReceiptSectionViewModels(order))
        self.totalPrice = self.getTotalPlusTips(order)
        self.totalPriceToShow.value = self.getFinalTotal(order)
        self.paymentViewModel.value = PaymentSectionViewModel(order: order)
    }
    
    func showDeleteConfirmation(_ viewController: UIViewController, viewModel: GarmentCardViewModel) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            self.deleteService(viewModel)
        }))
        viewController.present(alert, animated: true, completion: nil)
    }
    
    func updateOrders() {
        if somethingHasChanged {
            DataProvider.sharedInstance.refreshAdminOrdersFromBackend() { _ in
            }
        }
    }
    
    func onDone() {
        if self.order.paymentStatus == .applePayComplete || self.order.paymentStatus == .paymentProcessedSuccessfully {
            self.delegate?.goBack()
        } else {
            self.processPayment()
        }
    }
    
    fileprivate func processPayment() {
        let newOrderProcess = OrderProcess(id: self.order.id,
                                           total: self.totalPrice,
                                           status: OrderProcessStatus.processing,
                                           retryCount: 0)
       
        
//        Si puedo pagar con la plata que tengo en el monedero {
//            api/v1/admineditpaystatus/{orderid}/{paymentstatusid}
//            
//            api/v1/admineditwallet/{amount}/{userid}/{orderid}
//        }
        
        OrderProcessHandler.sharedInstance.add(order: newOrderProcess)
        _ = LemonAPI.processPayment(amount: self.totalPrice, orderID: self.order.id).request().observeNext { (result: EventResolver<String>) in
            
            do {
                let resultString = try result()
                if resultString == "Success" {
                    OrderProcessHandler.sharedInstance.change(status: .accepted, to: newOrderProcess)
                } else {
                    OrderProcessHandler.sharedInstance.change(status: .failed, to: newOrderProcess)
                }
            } catch {
                OrderProcessHandler.sharedInstance.change(status: .failed, to: newOrderProcess)
            }
        }

        self.delegate?.goBack()
    }
    
    fileprivate func changeOrder() {
        _ = LemonAPI.setOrderStatus(editedOrder: self.order, status: self.order.status).request().observeNext { [weak self] (result: EventResolver<Order>) in
            guard let strongSelf = self else { return }
            do {
                let newOrder = try result()
                strongSelf.setupOrder(newOrder)
            } catch { }
            strongSelf.updateOrders()
        }
    }
    
    fileprivate func createFooterViewModel(_ order: Order) -> ReceiptFooterVM {
        let total = getFinalTotal(order)
        return ReceiptFooterVM(total: total)
    }
    
    fileprivate func deleteService(_ viewModel: GarmentCardViewModel) {
        somethingHasChanged = true
        _ = LemonAPI.deleteOrderDetail(orderDetailID: viewModel.orderDetail.id).request().observeNext { [weak self] (_: EventResolver<String>) in
                guard let strongSelf = self else { return }
                strongSelf.updateOrder()
            }
    }

    fileprivate func updateOrder() {
        _ = LemonAPI.getOrderByID(orderID: order.id).request().observeNext { [weak self] (result: EventResolver<Order>) in
            guard let strongSelf = self else { return }
            do {
                let newOrder = try result()

//                DataProvider.sharedInstance.saveOrderInDB(order: newOrder)
                DataProvider.sharedInstance.refreshAdminOrdersFromBackend()
                strongSelf.setupOrder(newOrder)
            } catch { }
        }
    }
    
    fileprivate func getReceiptSectionViewModels(_ order: Order) -> [ReceiptItemsSectionVM] {
        var rowSections: [ReceiptItemsSectionVM] = []
        
        order.orderDetails?.forEach { [weak self] orderDetail in
            guard let strongSelf = self, let orderDetailReceipt = orderDetail.jsonOrder, let product = orderDetail.product else { return }
            
            orderDetailReceipt.id = orderDetail.id
            let rowSection = rowSections.filter{ $0.departmentID == product.id }
            let newRow = strongSelf.createRowOfSection(order, orderDetail: orderDetailReceipt)
            if rowSection.count > 0 {
                rowSection[0].items.append(newRow)
            } else {
                let newSection = strongSelf.createNewSection(order, product: product)
                newSection.items.append(newRow)
                rowSections.append(newSection)
            }
        }
        let footerSection = createFooterSection()
        rowSections.append(footerSection)
        return rowSections
    }
    
    fileprivate func getSubtotal(_ order: Order) -> Double {
        return self.getTotal(order)
    }
    
    fileprivate func createFooterSection() -> ReceiptItemsSectionVM {
        let footerSection = ReceiptItemsSectionVM(name: "total services", isItemSection: false, total: getTotal(order))
        
        let mountRushCharge: Double = order.delivery.deliveryUpchargeAmount ?? 0
        let subtitleRushCharge = mountRushCharge == 0 ? "Normal Service" : mountRushCharge == 4.99 ? "Next Day Service" : "Same Day Service"
        
        let rushCharge = ReceiptItemSingleVM(title: "Rush Charge", subtitle: subtitleRushCharge, price: mountRushCharge,  cellIdentifier: ReceiptTotalDoubleCell.identifier)
        footerSection.footerItems.append(rushCharge)
        
        let walletAmount = self.wallet != nil ? self.wallet!.amount : 0
        let walletAmountTransformed = walletAmount == 0 ? walletAmount : walletAmount * -1
        var subtitle = ""
        if let wallet = self.wallet, !wallet.transactions.isEmpty, let last = wallet.transactions.last {
            subtitle = last.type ?? "No type"
        }
        
        let walletFundsCellIdentifier: String? = subtitle.isEmpty ? nil : ReceiptTotalDoubleCell.identifier
        
        let walletFunds = ReceiptItemSingleVM(title: "Wallet Funds", subtitle: subtitle, price: walletAmountTransformed,  cellIdentifier: walletFundsCellIdentifier)
        footerSection.footerItems.append(walletFunds)
        
        let subtotalAmount = getSubtotal(order)
        
        let subtotal = ReceiptItemSingleVM(title: "Subtotal", subtitle: "", price: subtotalAmount)
        footerSection.footerItems.append(subtotal)

        let priceTips = order.tips == 0 ? 0 : subtotalAmount * (Double(order.tips) / 100)
        let tips = ReceiptItemSingleVM(title: "\(order.tips)% Tip", subtitle: "", price: priceTips)
        footerSection.footerItems.append(tips)
        
        return footerSection
    }
    
    fileprivate func createRowOfSection(_ order: Order, orderDetail: OrderDetailsReceipt) -> GarmentCardViewModel {
        let newGarmentCardVM = GarmentCardViewModel(orderDetail: orderDetail, order: order)
        return newGarmentCardVM
    }
    
    fileprivate func createNewSection(_ order: Order, product: Product) -> ReceiptItemsSectionVM {
        let newSection = ReceiptItemsSectionVM(name: product.name, isItemSection: true, departmentID: product.id)
        return newSection
    }
    
    fileprivate func getTotal(_ order: Order) -> Double {
        var total = 0.0
        order.orderDetails?.forEach { orderDetail in
            total = total + (orderDetail.total ?? 0)
        }
        
        return total
    }
    
    fileprivate func getFinalTotal(_ order: Order) -> Double {
        let walletAmount =  self.wallet != nil ? self.wallet!.amount : 0
        let partialTotal = self.getTotal(order)
        let priceTips = order.tips == 0 ? 0 : partialTotal * (Double(order.tips) / 100)
        let partialTotalPlusTips = priceTips + partialTotal
        let total: Double = partialTotalPlusTips - walletAmount
        return total < 0 ? 0 : total
    }
    
    
    fileprivate func getTotalPlusTips(_ order: Order) -> Double {
        let subtotalAmount = self.getTotal(order)
        let priceTips = order.tips == 0 ? 0 : subtotalAmount * (Double(order.tips) / 100)
        
        return subtotalAmount + priceTips
    }

    fileprivate func getWallet(_ userId: Int) {
        _ = LemonAPI.getWallet(userId: userId).request().observeNext { [weak self] (resolver: EventResolver<NewWallet>) in
            guard let `self` = self else {return}
            self.wallet = try? resolver()
            self.receiptDetailViewModels.replace(with: self.getReceiptSectionViewModels(self.order))
            self.totalPrice = self.getTotalPlusTips(self.order)
            self.totalPriceToShow.value = self.getFinalTotal(self.order)
            
            self.footerViewModel.value = self.createFooterViewModel(self.order)
        }
    }
    
    fileprivate func getPayments(for userID: Int) {
        _ = LemonAPI.getPaymentsAdmin(userID: userID).request().observeNext { [weak self]
            (paymentCardsResolver: EventResolver<[PaymentCard]>) in
            guard let self = self else {return}
            do {
                let paymentCards = try paymentCardsResolver()
                print(paymentCards)
                self.updateActivePayments(with: paymentCards)
            } catch {}
        }
    }
    
    fileprivate func updateActivePayments(with payments: [PaymentCard]) {
        self.activePaymentCards = payments
    }
    
    func paymentOptionChanged(_ paymentSelected: OptionItemProtocol) {
        self.changePaymentOption(card: paymentSelected)
        if let paymentCard = paymentSelected as? PaymentCard {
            
            if let oldOption = self.paymentOption {
                switch oldOption {
                case Option.chose(let card):
                    if let creditCard  = card as? PaymentCard, let oldPaymentID = creditCard.id {
                        
                        let areDifferent = oldPaymentID != (paymentCard.id ?? -1)
                        if areDifferent {
                            self.changeOrder()
                        }
                    }
                default: ()
                }
            }
        }
    }
    
    func changePaymentOption(card: OptionItemProtocol) {
        if let card  = card as? PaymentCard {
            self.paymentViewModel.value!.paymentId.value = card.id!
            self.paymentViewModel.value!.cardNumber.value = card.number
            self.paymentViewModel.value!.methodImageNamed.value = card.type.image!
            self.order.applePayToken = ""
            self.order.card = card
        } else if let card = card as? ApplePayCard {
            self.paymentViewModel.value!.paymentId.value = card.id!
            self.paymentViewModel.value!.cardNumber.value = "Apple Pay"
            self.paymentViewModel.value!.methodImageNamed.value = card.image!
        }
    }
}
