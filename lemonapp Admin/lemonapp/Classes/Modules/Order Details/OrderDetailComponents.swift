//
//  OrderDetailComponents.swift
//  lemonapp
//
//  Created by Lucas Pelizza on 3/12/18.
//  Copyright © 2018 11lemons. All rights reserved.
//

import Foundation

protocol ComponentsRouterDelegate: class {
    func showEditServiceFlow(_ serviceToEdit: Service, serviceCategory: Service)
    func showEditAttributeCategoryFlow(_ attributeCategoryToEdit: Category)
    func showNewAttributeFlow(_ attributeCategory: Category)
    func showEditAttributeFlow(_ attributeToEdit: Attribute)
}

protocol ScrollDelegate: class {
    func changeContentSize(_ newContentSize: CGSize)
    func getContentSize() -> CGSize
    func changeYPosition(_ newYPosition: CGFloat)
    func getYPosition() -> CGFloat
    func scrollTo(_ position: CGFloat)
    func getContentOffset() -> CGPoint
    func changeContentOffset(_ newContentOffset: CGPoint)
    func addViewToScrollView(_ view: UIView, yPos: CGFloat?)
    func showAlert(_ alertView:UIAlertController)
}

protocol OrderDetailComponents {
    func resetAllViews()
    func getHeightOfOpenView() -> CGFloat
    func initServiceView(_ typesOfService: [Service]?, serviceCategory: Service, title: String) -> UIView
    func updateServiceView(_ typesOfService: [Service]?, serviceCategory: Service, title: String)
}
