//
//  OrderDetailDryCleaningComponent.swift
//  lemonapp
//
//  Created by Lucas Pelizza on 3/14/18.
//  Copyright © 2018 11lemons. All rights reserved.
//

import Foundation

class OrderDetailDryCleaningComponent: OrderDetailComponents {
    var isHiddenDryCleaningPreferences: Bool = true
    var preferencesView: PreferencesUserView?
    
    var isHiddenColorsPreferences: Bool = true
    var colorPreferencesView: PickupColorView?
    
    var isHiddenMaterialView: Bool = true
    var materialView: ServiceView?
    
    var isHiddenPatterView: Bool = true
    var patterView: ServiceView?
    
    var notesView: NotesView?
    
    var viewModel: OrderDetailDryCleaningComponentViewModel
    weak var routerDelegate: ComponentsRouterDelegate?
    weak var scrollDelegate: ScrollDelegate?
    
    var onTextFieldFocus: (() -> ())
    var onTextFieldLostFocus: (() -> ())
    
    var currentServiceView: ServiceViewDoubleLine?
    var currentServiceSelected: Service?
    var currentBrandView: ServiceView?
    var currentBrandSelected: Attribute?
    var currentColorsSelected: [Attribute] = []
    var currentPickupColorView: PickupColorView?
    var currentMaterialsSelected: [Attribute] = []
    var currentPatternsSelected: [Attribute] = []
    
    init(viewModel: OrderDetailDryCleaningComponentViewModel, scrollDelegate: ScrollDelegate, routerDelegate: ComponentsRouterDelegate, onTextFieldFocus: @escaping (() -> ()), onTextFieldLostFocus: @escaping (() -> ())) {
        self.viewModel = viewModel
        self.scrollDelegate = scrollDelegate
        self.routerDelegate = routerDelegate
        self.onTextFieldFocus = onTextFieldFocus
        self.onTextFieldLostFocus = onTextFieldLostFocus
    }
    
    func resetAllViews() {
        isHiddenColorsPreferences = true
        if colorPreferencesView != nil {
            colorPreferencesView!.removeFromSuperview()
            colorPreferencesView = nil
        }
        
        isHiddenMaterialView = true
        if materialView != nil {
            materialView!.removeFromSuperview()
            materialView = nil
        }
        
        isHiddenPatterView = true
        if patterView != nil {
            patterView!.removeFromSuperview()
            patterView = nil
        }
        
        isHiddenDryCleaningPreferences = true
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
        currentMaterialsSelected = []
        currentPatternsSelected = []
    }
    
    func getHeightOfOpenView() -> CGFloat {
        var height = CGFloat(0)
        height += colorPreferencesView != nil ? colorPreferencesView!.frame.height : 0
        height += materialView != nil ? materialView!.frame.height : 0
        height += patterView != nil ? patterView!.frame.height : 0
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
                            scrollDelegate.scrollTo(serviceView.frame.origin.y + 10)
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
    fileprivate func createServiceView(_ typesOfService: [Service]?, title: String) -> ServiceViewDoubleLine {
        var serviceItems: [ServiceItem] = []
        if let typesOfService = typesOfService {
            let typesOfServiceActive = typesOfService.filter{ $0.active }
            typesOfServiceActive.forEach {
                serviceItems.append(ServiceItem(title: $0.name, image: GarmentsHelper.getImageBy($0.id), selectedImage: GarmentsHelper.getImageSelectedBy($0.id), isSelected: $0.isSelected, attribute: nil, service: $0, isRectangle: true))
            }
        }
        
        let serviceView = ServiceViewDoubleLine(items: serviceItems, lineCount: 2, isRoundButtons: true, isLabelVisible: false, canChangeVisibility: false, isMultiSelect: false, isSmallButton: true)
        serviceView.lblTitle.text = title.uppercased()
        return serviceView
    }
    
    fileprivate func updateServiceView(_ typesOfService: [Service]?, title: String){
        var serviceItems: [ServiceItem] = []
        if let typesOfService = typesOfService {
            let typesOfServiceActive = typesOfService.filter{ $0.active }
            typesOfServiceActive.forEach {
                serviceItems.append(ServiceItem(title: $0.name, image: GarmentsHelper.getImageBy($0.id), selectedImage: GarmentsHelper.getImageSelectedBy($0.id), isSelected: $0.isSelected, attribute: nil, service: $0, isRectangle: true))
            }
        }
        
        currentServiceView!.updateView(items: serviceItems, lineCount: 2, isRoundButtons: true, isLabelVisible: false, canChangeVisibility: false, isMultiSelect: false, isSmallButton: true)
        currentServiceView!.lblTitle.text = title.uppercased()
    }
    
    //MARK:- Brand View
    fileprivate func initBrandView(_ yPosition: CGFloat, category: Category) -> ServiceView? {
        guard let attributes = category.attributes else { return nil }
        
        let serviceView = createCategoryView(category, isSmallButton: false)
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
                
                scrollDelegate.scrollTo(yPosition + 5)
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

    //MARK: Create generic category view
    fileprivate func createCategoryView(_ category: Category, isSmallButton: Bool) -> ServiceView? {
        guard category.attributes != nil else { return nil }
        
        let allowMultiValues = category.allowMultipleValues ?? false
        
        let serviceView = ServiceView(items: [], lineCount: 1, isRoundButtons: true, isLabelVisible: false, canChangeVisibility: true, isMultiSelect: allowMultiValues, isSmallButton: isSmallButton)
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
                    if strongSelf.isHiddenMaterialView {
                        let materialsAttCat = strongSelf.viewModel.getAttributeCategoryBy(Identifier.Category.Material)
                        if let materialsAttributeCategory = materialsAttCat {
                            strongSelf.showMaterialView(scrollDelegate.getYPosition(), category: materialsAttributeCategory)
                        }
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
        
        if currentMaterialsSelected.count > 0 {
            if !(self.isHiddenMaterialView) {
                let materialsAttCat = self.viewModel.getAttributeCategoryBy(Identifier.Category.Material)
                if let materialsAttributeCategory = materialsAttCat {
                    self.updateMaterialView(category: materialsAttributeCategory)
                }
            }
            
            
        }
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
    
    //MARK: Material View
    fileprivate func showMaterialView(_ yPosition: CGFloat, category: Category) {
        guard let attributes = category.attributes else { return }
        
        materialView = createCategoryView(category, isSmallButton: true)
        
        guard let materialView = materialView else { return }
        
        isHiddenMaterialView = false
        
        materialView.onSelectClosure = { [weak self] position, isSelected in
            guard let strongSelf = self, let scrollDelegate = strongSelf.scrollDelegate else { return }
            
            let attributeToAdd: [Attribute] = materialView.items.array.filter{ $0.isSelected && $0.attribute != nil }.flatMap {
                $0.attribute?.isSelected = true
                return $0.attribute!
            }
            
            strongSelf.viewModel.setupAttributesToOrderDetail(category, attributes: attributeToAdd)
            if attributeToAdd.count > 0 {
                strongSelf.currentMaterialsSelected = attributeToAdd
                if strongSelf.isHiddenPatterView {
                    let patterAttCat = strongSelf.viewModel.getAttributeCategoryBy(Identifier.Category.Pattern)
                    if let pattersAttributeCategory = patterAttCat {
                        strongSelf.showPatterView(scrollDelegate.getYPosition(), category: pattersAttributeCategory)
                    }
                }
                
                scrollDelegate.scrollTo(yPosition)
            }
        }
        
        attributes.filter{ !$0.deleted }.forEach { attr in
            materialView.items.append(ServiceItem(title: attr.attributeName, image: MaterialHelper.getImageBy(attr.id, materialName: attr.attributeName) , selectedImage: MaterialHelper.getImageSelectedBy(attr.id, materialName: attr.attributeName), isSelected: attr.isSelected, attribute: attr, isRectangle: false))
        }
        
        scrollDelegate?.addViewToScrollView(materialView, yPos: nil)
    }
    
    fileprivate func updateMaterialView(category: Category) {
        guard let attributes = category.attributes else { return }
        
        var attrItems: [ServiceItem] = []
        attributes.forEach {
            $0.isSelected = currentMaterialsSelected.contains($0)
        }
        
        attributes.filter{ !$0.deleted }.forEach { attr in
            attrItems.append(ServiceItem(title: attr.attributeName, image: MaterialHelper.getImageBy(attr.id, materialName: attr.attributeName) , selectedImage: MaterialHelper.getImageSelectedBy(attr.id, materialName: attr.attributeName), isSelected: attr.isSelected, attribute: attr, isRectangle: false))
        }

        
        let attributeToAdd: [Attribute] = attrItems.filter{ $0.isSelected && $0.attribute != nil }.flatMap {
            $0.attribute?.isSelected = true
            return $0.attribute!
        }
        
        materialView?.items.replace(with: attrItems)
        
        self.viewModel.setupAttributesToOrderDetail(category, attributes: attributeToAdd)
        
        if currentPatternsSelected.count > 0 {
            if !(self.isHiddenPatterView) {
                let patterAttCat = self.viewModel.getAttributeCategoryBy(Identifier.Category.Pattern)
                if let pattersAttributeCategory = patterAttCat {
                    self.updatePatternView(category: pattersAttributeCategory)
                }
            }
        }
    }
    
    //MARK: Patter View
    fileprivate func showPatterView(_ yPosition: CGFloat, category: Category) {
        guard let attributes = category.attributes else { return }
        
        patterView = createCategoryView(category, isSmallButton: true)
        
        guard let patterView = patterView else { return }
        
        isHiddenPatterView = false
        
        patterView.onSelectClosure = { [weak self] position, isSelected in
            guard let strongSelf = self, let scrollDelegate = strongSelf.scrollDelegate else { return }
            
            let attributeToAdd: [Attribute] = patterView.items.array.filter{ $0.isSelected && $0.attribute != nil }.flatMap {
                $0.attribute?.isSelected = true
                return $0.attribute!
            }
            
            strongSelf.viewModel.setupAttributesToOrderDetail(category, attributes: attributeToAdd)
            if attributeToAdd.count > 0 {
                strongSelf.currentPatternsSelected = attributeToAdd
                if strongSelf.isHiddenDryCleaningPreferences {
                    strongSelf.showDryCleaningPreferences()
                }
                
                scrollDelegate.scrollTo(yPosition)
            }
        }
        
        attributes.filter{ !$0.deleted }.forEach { attr in
            patterView.items.append(ServiceItem(title: attr.attributeName, image: PatterHelper.getImageBy(attr.id, patternName: attr.attributeName) , selectedImage: PatterHelper.getImageSelectedBy(attr.id, patternName: attr.attributeName), isSelected: attr.isSelected, attribute: attr, isRectangle: false))
        }
        
        scrollDelegate?.addViewToScrollView(patterView, yPos: nil)
    }
    
    fileprivate func updatePatternView(category: Category) {
        guard let attributes = category.attributes else { return }
        
        var attrItems: [ServiceItem] = []
        attributes.forEach {
            $0.isSelected = currentPatternsSelected.contains($0)
        }
        
        attributes.filter{ !$0.deleted }.forEach { attr in
            attrItems.append(ServiceItem(title: attr.attributeName, image: PatterHelper.getImageBy(attr.id, patternName: attr.attributeName) , selectedImage: PatterHelper.getImageSelectedBy(attr.id, patternName: attr.attributeName), isSelected: attr.isSelected, attribute: attr, isRectangle: false))
        }
        
        
        let attributeToAdd: [Attribute] = attrItems.filter{ $0.isSelected && $0.attribute != nil }.flatMap {
            $0.attribute?.isSelected = true
            return $0.attribute!
        }
        
        patterView?.items.replace(with: attrItems)
        
        self.viewModel.setupAttributesToOrderDetail(category, attributes: attributeToAdd)

    }
    
    //MARK: - Notes view
    fileprivate func initNotesView(_ yPosition: CGFloat) -> UIView {
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
    fileprivate func showDryCleaningPreferences() {
        guard let scrollDelegate = scrollDelegate else { return }
        
        isHiddenDryCleaningPreferences = false
        let preferencesView = initPreferencesView()
        scrollDelegate.addViewToScrollView(preferencesView, yPos: nil)
        
        let notesView = initNotesView(scrollDelegate.getYPosition())
        scrollDelegate.addViewToScrollView(notesView, yPos: nil)
    }
    
    fileprivate func initPreferencesView() -> UIView {
        let preferencesCellVM = viewModel.getPreferencesVM()
        preferencesView = PreferencesUserView(viewModel: preferencesCellVM)
        
        return preferencesView!
    }
}
