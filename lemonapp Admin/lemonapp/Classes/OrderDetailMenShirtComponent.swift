//
//  OrderDetailMenShirtComponent.swift
//  lemonapp
//
//  Created by Lucas Pelizza on 3/12/18.
//  Copyright © 2018 11lemons. All rights reserved.
//

import Foundation

class OrderDetailMenShirtComponent: OrderDetailComponents {
    var isHiddenMenShirtPreferences: Bool = true
    var preferencesView: PreferencesUserView?
    
    var isHiddenColorsPreferences: Bool = true
    var colorPreferencesView: PickupColorView?
    
    var notesView: NotesView?
    var viewModel: OrderDetailMenShirtComponentViewModel
    weak var routerDelegate: ComponentsRouterDelegate?
    weak var scrollDelegate: ScrollDelegate?
    
    var onTextFieldFocus: (() -> ())
    var onTextFieldLostFocus: (() -> ())
    
    var currentServiceView: ServiceView?
    var currentServiceSelected: Service?
    var currentBrandView: ServiceView?
    var currentBrandSelected: Attribute?
    var currentColorsSelected: [Attribute] = []
    var currentPickupColorView: PickupColorView?
    
    init(viewModel: OrderDetailMenShirtComponentViewModel, scrollDelegate: ScrollDelegate, routerDelegate: ComponentsRouterDelegate, onTextFieldFocus: @escaping (() -> ()), onTextFieldLostFocus: @escaping (() -> ())) {
        self.viewModel = viewModel
        self.scrollDelegate = scrollDelegate
        self.routerDelegate = routerDelegate
        self.onTextFieldFocus = onTextFieldFocus
        self.onTextFieldLostFocus = onTextFieldLostFocus
    }
    
    func resetAllViews() {
        isHiddenMenShirtPreferences = true
        if preferencesView != nil {
            preferencesView!.removeFromSuperview()
            preferencesView = nil
        }
        
        isHiddenColorsPreferences = true
        if colorPreferencesView != nil {
            colorPreferencesView!.removeFromSuperview()
            colorPreferencesView = nil
        }
        
        if notesView != nil {
            notesView!.removeFromSuperview()
            notesView = nil
        }
        
        if currentServiceView != nil {
            currentServiceView!.removeFromSuperview()
            currentServiceView = nil
        }
        
        if currentBrandView != nil {
            currentBrandView!.removeFromSuperview()
            currentBrandView = nil
        }
        
        if currentPickupColorView != nil {
            currentPickupColorView!.removeFromSuperview()
            currentPickupColorView = nil
        }
        
        currentServiceSelected = nil
        currentBrandSelected = nil
        currentColorsSelected = []
        
    }
    
    func getHeightOfOpenView() -> CGFloat {
        var height = CGFloat(0)
        height += preferencesView != nil ? preferencesView!.frame.height : 0
        height += colorPreferencesView != nil ? colorPreferencesView!.frame.height : 0
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
                
                strongSelf.viewModel.setTypeOfServiceToOrderDetail(position, isSelected: isSelected)
                
                
                let attrViewsAux = attrViews
                attrViews = []
                
                if attributesYPosition == nil {
                    attributesYPosition = scrollDelegate.getYPosition()
                } else {
                    scrollDelegate.changeYPosition(attributesYPosition!)
                }
                
                let currentPosition = scrollDelegate.getContentOffset()
                let brandAttCat = strongSelf.viewModel.getAttributeCategoryBy(Identifier.Category.Brand)
                if let brandAttributeCategory = brandAttCat {
                    let brandView = strongSelf.initBrandView(attributesYPosition!, category:brandAttributeCategory)
                    if let bView = brandView {
                        strongSelf.currentBrandView = bView
                        scrollDelegate.addViewToScrollView(bView, yPos: nil)
                        attrViews.append(bView)
                        
                        if attrViewsAux.count == 0 {
                            scrollDelegate.scrollTo(serviceView.frame.origin.y + 30)
                        } else {
                            var contentOffset = scrollDelegate.getContentOffset()
                            contentOffset.y = currentPosition.y
                            scrollDelegate.changeContentOffset(contentOffset)
                        }
                        
                        attrViewsAux.forEach {
                            $0.isHidden = true
                            $0.removeFromSuperview()
                        }
                    }
                }
            }
        }
        return serviceView
    }
    
    func updateServiceView(_ typesOfService: [Service]?, serviceCategory: Service, title: String) {
        viewModel.getAttributes {
            if self.currentServiceView != nil {
                if self.currentServiceSelected != nil {
                    if let typesOfService = typesOfService {
                        typesOfService.forEach {
                            $0.isSelected = $0.id == self.currentServiceSelected?.id
                        }
                        
                    }
                    
                    let selectedPos = typesOfService?.index(of: self.currentServiceSelected!) ?? -1
                    if selectedPos != -1 {
                        self.viewModel.setTypeOfServiceToOrderDetail(selectedPos, isSelected: true)
                    }
                    
                    if self.currentBrandView != nil {
                        let brandAttCat = self.viewModel.getAttributeCategoryBy(Identifier.Category.Brand)
                        if let brandAttributeCategory = brandAttCat {
                            self.updateBrandView(category: brandAttributeCategory)
                        }
                    }
                }
                self.updateServiceView(typesOfService, title: title)
            }
            else {
                let serviceView = self.createServiceView(typesOfService, title: title)
                self.currentServiceView = serviceView
            }
        }
    }
    
    //MARK:
    fileprivate func createServiceView(_ typesOfService: [Service]?, title: String) -> ServiceView {
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
    
    //MARK:- Brand View
    fileprivate func initBrandView(_ yPosition: CGFloat, category: Category) -> ServiceView? {
        guard let attributes = category.attributes else { return nil }
        
        let serviceView = createCategoryView(category)
        if serviceView == nil {
            return nil
        }
        
        serviceView!.onSelectClosure = { [weak self] position, isSelected in
            guard let strongSelf = self, let scrollDelegate = strongSelf.scrollDelegate else { return }
            
            let attributeToAdd: [Attribute] = serviceView!.items.array.filter{ $0.isSelected && $0.attribute != nil }.flatMap {
                $0.attribute?.isSelected = true
                return $0.attribute!
            }
            
            strongSelf.viewModel.setupAttributesToOrderDetail(category, attributes: attributeToAdd)
            if attributeToAdd.count > 0 {
                strongSelf.currentBrandSelected = attributeToAdd.first
                if strongSelf.isHiddenColorsPreferences {
                    let colorAttCat = strongSelf.viewModel.getAttributeCategoryBy(Identifier.Category.Color)
                    if let colorAttributeCategory = colorAttCat {
                        strongSelf.showColorView(scrollDelegate.getYPosition(), category: colorAttributeCategory)
                    }
                }
                
                scrollDelegate.scrollTo(yPosition)
            }
        }
        
        attributes.filter{ !$0.deleted }.forEach { attr in
            serviceView!.items.append(ServiceItem(title: attr.attributeName, image: BrandHelper.getImageBy(attr.id, brandName: attr.attributeName) , selectedImage: BrandHelper.getImageSelectedBy(attr.id, brandName: attr.attributeName), isSelected: attr.isSelected, attribute: attr, isRectangle: true))
        }
        
        return serviceView
    }
    
    fileprivate func updateBrandView(category: Category){
        guard let attributes = category.attributes else { return }
        
        var attrItems: [ServiceItem] = []
        attributes.filter{ !$0.deleted }.forEach { attr in
            attrItems.append(ServiceItem(title: attr.attributeName, image: BrandHelper.getImageBy(attr.id, brandName: attr.attributeName) , selectedImage: BrandHelper.getImageSelectedBy(attr.id, brandName: attr.attributeName), isSelected: attr.id == currentBrandSelected?.id, attribute: attr, isRectangle: true))
        }
        
        let attributeToAdd: [Attribute] = attrItems.filter{ $0.isSelected && $0.attribute != nil }.flatMap {
            $0.attribute?.isSelected = true
            return $0.attribute!
        }
        
        currentBrandView?.items.replace(with: attrItems)
        
        self.viewModel.setupAttributesToOrderDetail(category, attributes: attributeToAdd)
        
        if currentColorsSelected.count > 0 {
            if !(self.isHiddenColorsPreferences) {
                let colorAttCat = self.viewModel.getAttributeCategoryBy(Identifier.Category.Color)
                if let colorAttributeCategory = colorAttCat {
                    self.updateColorView(category: colorAttributeCategory)
                }
            }
        }
        
    }
    
    //MARK: - Color View
    fileprivate func showColorView(_ yPosition: CGFloat, category: Category) {
        isHiddenColorsPreferences = false
        let colorV = initPickupColorView(category)
        currentPickupColorView = colorV
        if let colorView = colorV {
            colorView.onSelectClosure = { [weak self] attributes in
                guard let strongSelf = self, let scrollDelegate = strongSelf.scrollDelegate else { return }
                
                let attributeToAdd: [Attribute] = attributes.filter{ $0.isSelected}
                strongSelf.viewModel.setupAttributesToOrderDetail(category, attributes: attributeToAdd)
                if attributeToAdd.count > 0 {
                    strongSelf.currentColorsSelected = attributeToAdd
                    if strongSelf.isHiddenMenShirtPreferences {
                        strongSelf.showMenShirtPreferences()
                    }
                    
                    scrollDelegate.scrollTo(yPosition)
                }
            }
            
            scrollDelegate?.addViewToScrollView(colorView, yPos: nil)
        }
    }

    fileprivate func updateColorView(category: Category) {
        guard let attributes = category.attributes else { return  }
        
        attributes.forEach {
            $0.isSelected = currentColorsSelected.contains($0)
        }
        
        currentPickupColorView?.updateView(attributes: attributes)
        
        let attributeToAdd: [Attribute] = attributes.filter{ $0.isSelected}
        self.viewModel.setupAttributesToOrderDetail(category, attributes: attributeToAdd)
        
    }
    
    fileprivate func initPickupColorView(_ category: Category) -> PickupColorView? {
        guard let attributes = category.attributes else { return nil }
        
        colorPreferencesView = PickupColorView(attributes: attributes)
        colorPreferencesView!.onHoldAndEdit = {[weak self] attribute in
            self?.routerDelegate?.showEditAttributeFlow(attribute)
        }
        
        colorPreferencesView!.onSelectClosure = { [weak self] attributes in
            guard let strongSelf = self else { return }
            
            let attributeToAdd: [Attribute] = attributes.filter{ $0.isSelected}
            strongSelf.viewModel.setupAttributesToOrderDetail(category, attributes: attributeToAdd)
        }
        
        return colorPreferencesView!
    }
    
    //MARK: Create generic category view
    fileprivate func createCategoryView(_ category: Category) -> ServiceView? {
        guard category.attributes != nil else { return nil }
        
        let allowMultiValues = category.allowMultipleValues ?? false
        
        let serviceView = ServiceView(items: [], lineCount: 1, isRoundButtons: true, isLabelVisible: false, canChangeVisibility: true, isMultiSelect: allowMultiValues)
        serviceView.lblTitle.text = category.name.uppercased()
        
        serviceView.onEdit = {[weak self] in
            self?.routerDelegate?.showEditAttributeCategoryFlow(category)
        }
        
        serviceView.onAddElement = {[weak self] in
            guard let strongSelf = self else { return }
            strongSelf.routerDelegate?.showNewAttributeFlow(category)
        }
        
        serviceView.onHoldAndEditAttribute = { [weak self] attribute in
            self?.routerDelegate?.showEditAttributeFlow(attribute)
        }
        
        serviceView.onSelectClosure = { [weak self] position, isSelected in
            guard let strongSelf = self else { return }
            
            let attributeToAdd: [Attribute] = serviceView.items.array.filter{ $0.isSelected && $0.attribute != nil }.flatMap {
                $0.attribute?.isSelected = true
                return $0.attribute!
            }
            
            strongSelf.viewModel.setupAttributesToOrderDetail(category, attributes: attributeToAdd)
        }
        return serviceView
    }
    
    //MARK: - Notes view
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
    
    //MARK: Men's shirts preferences
    fileprivate func showMenShirtPreferences() {
        guard let scrollDelegate = scrollDelegate else { return }
        
        isHiddenMenShirtPreferences = false
        if preferencesView == nil {
            preferencesView = initMenShirtPreferencesView()
            scrollDelegate.addViewToScrollView(preferencesView!, yPos: nil)
        }
        if notesView == nil {
            notesView = initNotesView(scrollDelegate.getYPosition())
            scrollDelegate.addViewToScrollView(notesView!, yPos: nil)
        }
    }
    
    fileprivate func initMenShirtPreferencesView() -> PreferencesUserView {
        let preferencesCellVM = viewModel.getPreferencesVM()
        preferencesView = PreferencesUserView(viewModel: preferencesCellVM)
        
        return preferencesView!
    }
}
