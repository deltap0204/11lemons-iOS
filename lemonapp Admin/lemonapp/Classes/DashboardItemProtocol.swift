//
//  DashboardItemProtocol.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

enum DashboardItemType {
    case order, walletTransition
}

protocol DashboardItem {
    var repeated: Bool { get }
    var compareDate: Date? { get }
    var dashboardItemType: DashboardItemType { get }
    var id: Int { get }
}

extension Equatable where Self : DashboardItem {}

func == (left: DashboardItem, right: DashboardItem) -> Bool {
    return left.id == right.id && left.dashboardItemType == right.dashboardItemType
}
