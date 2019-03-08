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
}

final class ReceiptViewModel {
    var order: Order
    var totalPrice: Double = 0
    let totalPriceToShow = Observable<Double>(0)
    var totalBundleImage = Observable<UIImage?>(nil)
    
    var paymentViewModel = Observable<PaymentSectionViewModel?>(nil)
    var paymentOption = Observable<Option?>(nil)
    let newPaymentViewModel: CommonContainerViewModel?
    
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
            paymentOption.value = Option.chose(item: card)
        } else if let card = DataProvider.sharedInstance.userWrapper?.defaultPaymentCard.value as? PaymentCard {
            paymentOption.value = Option.chose(item: card)
            self.order.card = card
        } else if let applePayCard = DataProvider.sharedInstance.userWrapper?.applePayCard {
            paymentOption.value = Option.chose(item: applePayCard)
            self.order.card = nil
        }
        newPaymentViewModel?.result.observeNext { result in
            if let card = result as? PaymentCard {
                self.paymentOption.value = Option.chose(item: card)
                self.order.card = card
            }
        }.dispose(in:self.disposeBag)

        self.setupOrder(order)
        self.binding()
        paymentOption.observeNext { option in
            if let option = option {
                switch option {
                case Option.chose(let card):
                    if let card  = card as? PaymentCard {
                        order.card = card
                        self.changeOrder()
                    }
                default: ()
                }
            }
        }.dispose(in:self.disposeBag)
    }
    
    func binding() {
        self.paymentOption.observeNext { [weak self] option in
            guard let `self` = self else {return}
            if let option = option, self.paymentViewModel.value != nil {
                switch option {
                case Option.chose(let card):
                    if let card  = card as? PaymentCard {
                        self.paymentViewModel.value!.paymentId.value = card.id!
                        self.paymentViewModel.value!.cardNumber.value = card.type.rawValue
                        self.paymentViewModel.value!.methodImageNamed.value = card.type.image!
                    } else if let card = card as? ApplePayCard {
                        self.paymentViewModel.value!.paymentId.value = card.id!
                            self.paymentViewModel.value!.cardNumber.value = "Apple Pay"
                            self.paymentViewModel.value!.methodImageNamed.value = card.image!
                    }
                default: ()
                }
            }
        }.dispose(in:self.disposeBag)
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
    }
    
    func onDone() {
        self.delegate?.goBack()
    }

    fileprivate func changeOrder() {
        _ = LemonAPI.setOrderStatus(editedOrder: self.order, status: self.order.status).request().observeNext { [weak self] (result: EventResolver<Order>) in
            guard let strongSelf = self else { return }
            do {
                let newOrder = try result()
                strongSelf.setupOrder(newOrder)
            } catch { }
        }
    }
    
    fileprivate func createFooterViewModel(_ order: Order) -> ReceiptFooterVM {
        let total = getFinalTotal(order)
        return ReceiptFooterVM(total: total)
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
        
        var walletAmount = self.wallet != nil ? self.wallet!.amount : 0
        walletAmount = walletAmount == 0 ? walletAmount : walletAmount * -1
        var subtitle = ""
        if let wallet = self.wallet, !wallet.transactions.isEmpty, let last = wallet.transactions.last {
            subtitle = last.type ?? "No type"
        }
        
        let walletFundsCellIdentifier: String? = subtitle.isEmpty ? nil : ReceiptTotalDoubleCell.identifier
        
        let walletFunds = ReceiptItemSingleVM(title: "Wallet Funds", subtitle: subtitle, price: walletAmount,  cellIdentifier: walletFundsCellIdentifier)
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
}
