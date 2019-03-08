//
//  OrderDetailWashFoldComponent.swift
//  lemonapp
//
//  Created by Lucas Pelizza on 3/12/18.
//  Copyright © 2018 11lemons. All rights reserved.
//

import Foundation

class OrderDetailWashFoldComponent: OrderDetailComponents {
    
    
    var isHiddenWashPreferences: Bool = true
    var preferencesView: PreferencesUserView?
    var notesView: NotesView?
    var weightView: WeightView?
    
    weak var routerDelegate: ComponentsRouterDelegate?
    var viewModel: OrderDetailWashFoldComponentViewModel
    weak var scrollDelegate: ScrollDelegate?
    
    var onTextFieldFocus: (() -> ())
    var onTextFieldLostFocus: (() -> ())
    
    var currentServiceView: ServiceView?
    var currentServiceSelected: Service?
    
    init(viewModel: OrderDetailWashFoldComponentViewModel, scrollDelegate: ScrollDelegate, routerDelegate: ComponentsRouterDelegate, onTextFieldFocus: @escaping (() -> ()), onTextFieldLostFocus: @escaping (() -> ())) {
        self.viewModel = viewModel
        self.scrollDelegate = scrollDelegate
        self.routerDelegate = routerDelegate
        self.onTextFieldFocus = onTextFieldFocus
        self.onTextFieldLostFocus = onTextFieldLostFocus
    }
    
    func resetAllViews() {
        isHiddenWashPreferences = true
        if preferencesView != nil {
            preferencesView!.removeFromSuperview()
            preferencesView = nil
        }
        
        if notesView != nil {
            notesView!.removeFromSuperview()
            notesView = nil
        }
        
        if currentServiceView != nil {
            currentServiceView!.removeFromSuperview()
            currentServiceView = nil
        }
        
        if weightView != nil {
            weightView!.removeFromSuperview()
            weightView = nil
        }
        
        currentServiceSelected = nil
    }

    func getHeightOfOpenView() -> CGFloat {
        var height = CGFloat(0)
        height += preferencesView != nil ? preferencesView!.frame.height : 0
        height += notesView != nil ? notesView!.frame.height : 0
        return height
    }
    
    func initServiceView(_ typesOfService: [Service]?, serviceCategory: Service, title: String) -> UIView {
        guard let scrollDelegate = scrollDelegate else { return UIView() }
        let serviceView = createServiceView(typesOfService, title: title)
        currentServiceView = serviceView
        
        var attrViews: [UIView] = []
        let contentSizeDefault = scrollDelegate.getContentSize()
        
        var yPos: CGFloat = 0.0
        var attributesYPosition:CGFloat? = nil
        
        serviceView.onHoldAndEdit = {[weak self] service in
            self?.routerDelegate?.showEditServiceFlow(service, serviceCategory: serviceCategory)
        }
        
        serviceView.onHiddenAll = { [weak self] in
            yPos = 0.0
            
            guard let strongSelf = self, let scrollDelegate = strongSelf.scrollDelegate else { return }
            
            strongSelf.viewModel.resetServicesToOrderDetail()
            strongSelf.viewModel.resetAttributesToOrderDetail()
            
            attrViews.forEach { (serviceItem) in
                serviceItem.removeFromSuperview()
                yPos += serviceItem.frame.height
            }
            yPos += strongSelf.getHeightOfOpenView()
            strongSelf.resetAllViews()
            attrViews = []
            serviceView.resetSelection()
            
            let yPosition = scrollDelegate.getYPosition()
            scrollDelegate.changeYPosition(yPosition - yPos)
            scrollDelegate.changeContentSize(contentSizeDefault)
        }
        
        serviceView.onSelectClosure = { [weak self] position, isSelected in
            guard let strongSelf = self, let scrollDelegate = strongSelf.scrollDelegate else { return }
            strongSelf.currentServiceSelected = typesOfService?[position]
            
            if (serviceView.items.array.filter { $0.isSelected }.count) <= 0 {
                attrViews.forEach { $0.isHidden = true }
                scrollDelegate.changeContentSize(contentSizeDefault)
                strongSelf.viewModel.resetServicesToOrderDetail()
            } else {
                strongSelf.viewModel.setTypeOfServiceWashFoldToOrderDetail(position, isSelected: isSelected)
                
                let attrViewsAux = attrViews
                attrViews = []
                
                if attributesYPosition == nil {
                    attributesYPosition = scrollDelegate.getYPosition()
                } else {
                    scrollDelegate.changeYPosition(attributesYPosition!)
                }
                
                strongSelf.isHiddenWashPreferences = true
                let currentPosition = scrollDelegate.getContentOffset()
                strongSelf.viewModel.resetAttributesToOrderDetail()
                
                strongSelf.weightView = strongSelf.initWeightView(attributesYPosition!)
                scrollDelegate.addViewToScrollView(strongSelf.weightView!, yPos: nil)
                attrViews.append(strongSelf.weightView!)

                if attrViewsAux.count == 0 {
                    scrollDelegate.scrollTo(serviceView.frame.origin.y + 30)
                } else {
                    var contentOffset = scrollDelegate.getContentOffset()
                    contentOffset.y = currentPosition.y
                    scrollDelegate.changeContentOffset(contentOffset)
                    scrollDelegate.scrollTo(serviceView.frame.origin.y + 50)
                }
                attrViewsAux.forEach {
                    $0.isHidden = true
                    $0.removeFromSuperview()
                }
            }
        }
        
        return serviceView
    }
    
    func updateServiceView(_ typesOfService: [Service]?, serviceCategory: Service, title: String) {
            if currentServiceView != nil {
                if currentServiceSelected != nil {
                    if let typesOfService = typesOfService {
                        typesOfService.forEach {
                            $0.isSelected = $0.id == currentServiceSelected?.id
                        }
                    }
                    let selectedPos = typesOfService?.index(of: currentServiceSelected!) ?? -1
                    if selectedPos != -1 {
                        self.viewModel.setTypeOfServiceWashFoldToOrderDetail(selectedPos, isSelected: true)
                    }
                }
                updateServiceView(typesOfService, title: title)
            }
            else {
                let serviceView = createServiceView(typesOfService, title: title)
                currentServiceView = serviceView
            }
    }
    
    fileprivate func createServiceView(_ typesOfService: [Service]?, title: String) -> ServiceView{
        var serviceItems: [ServiceItem] = []
        if let typesOfService = typesOfService {
            let typesOfServiceActive = typesOfService.filter{ $0.active }
            typesOfServiceActive.forEach {
                serviceItems.append(ServiceItem(title: $0.name, image: ProductHelper.getServiceImageBy($0.id, serviceName: $0.name), selectedImage: ProductHelper.getServiceImageSelectedBy($0.id, serviceName: $0.name), isSelected: $0.isSelected, attribute: nil, service: $0))
            }
        }
        
        let serviceView = ServiceView(items: serviceItems, lineCount: 1, isRoundButtons: true, isLabelVisible: false, canChangeVisibility: false, isMultiSelect: false, isSmallButton: true)
        serviceView.lblTitle.text = title.uppercased()
        return serviceView
    }
    
    fileprivate func updateServiceView(_ typesOfService: [Service]?, title: String){
        var serviceItems: [ServiceItem] = []
        if let typesOfService = typesOfService {
            let typesOfServiceActive = typesOfService.filter{ $0.active }
            typesOfServiceActive.forEach {
                serviceItems.append(ServiceItem(title: $0.name, image: ProductHelper.getServiceImageBy($0.id, serviceName: $0.name), selectedImage: ProductHelper.getServiceImageSelectedBy($0.id, serviceName: $0.name), isSelected: $0.isSelected, attribute: nil, service: $0))
            }
        }
        
        currentServiceView!.updateView(items: serviceItems, lineCount: 1, isRoundButtons: true, isLabelVisible: false, canChangeVisibility: false, isMultiSelect: false, isSmallButton: true)
        currentServiceView!.lblTitle.text = title.uppercased()
    }
    
    fileprivate func initWeightView(_ yPosition: CGFloat) -> WeightView {
        let view = WeightView()
        weightView = view
        view.onFinishEdit = { [weak self] lbs in
            guard let strongSelf = self, let scrollDelegate = strongSelf.scrollDelegate else { return }
            if let libras = lbs {
                strongSelf.viewModel.changeLbs(libras)
                if strongSelf.isHiddenWashPreferences {
                    strongSelf.showWashFoldPreferences()
                }
                scrollDelegate.scrollTo(yPosition)
            }
        }
        if let currentLbs = self.viewModel.getCurrentLbs(), currentLbs > 0 {
            view.setWeightText(weight: currentLbs)
        }
        else {
            view.setFocus()
        }
        return view
    }
    
    fileprivate func showWashFoldPreferences() {
        guard let scrollDelegate = scrollDelegate else { return }
        isHiddenWashPreferences = false
        if preferencesView == nil {
            preferencesView = initPreferencesView()
            scrollDelegate.addViewToScrollView(preferencesView!, yPos: nil)
        }
        if notesView == nil {
            notesView = initNotesView(scrollDelegate.getYPosition())
            scrollDelegate.addViewToScrollView(notesView!, yPos: nil)
        }
    }
    
    fileprivate func initPreferencesView() -> PreferencesUserView {
        let preferencesCellVM = viewModel.getPreferencesVM()
        preferencesView = PreferencesUserView(viewModel: preferencesCellVM)
        
        return preferencesView!
    }
    
    fileprivate func initNotesView(_ yPosition: CGFloat) -> NotesView {
        notesView = NotesView()
        
        notesView!.onFinishEdit = { [weak self] text in
            guard let strongSelf = self, let scrollDelegate = strongSelf.scrollDelegate else { return }
            
            strongSelf.onTextFieldLostFocus()
            let keyboardHeight = CGFloat(230)
            let contentSize = scrollDelegate.getContentSize()
            let newheight = contentSize.height - keyboardHeight
            scrollDelegate.changeContentSize(CGSize(width: contentSize.width, height: newheight))
            if let text = text {
                strongSelf.viewModel.addNote(text)
            }
        }
        
        notesView!.onFocus = { [weak self] in
            guard let strongSelf = self, let scrollDelegate = strongSelf.scrollDelegate else { return }
            
            strongSelf.onTextFieldFocus()
            let keyboardHeight = CGFloat(250)
            let contentSize = scrollDelegate.getContentSize()
            let newheight = scrollDelegate.getYPosition() + strongSelf.notesView!.frame.height + keyboardHeight
            scrollDelegate.changeContentSize(CGSize(width: contentSize.width, height: newheight))
            scrollDelegate.scrollTo(yPosition)
        }
        
        return notesView!
    }
}
