//
//  ReceiptTableView.swift
//  lemonapp
//
//  Created by Lucas Pelizza on 9/29/17.
//  Copyright © 2017 11lemons. All rights reserved.
//

import UIKit
import Bond
import MGSwipeTableCell
import ReactiveKit

class ReceiptTableView: UITableView {

    var data = ObservableArray<ReceiptItemsSectionVM>([])
    var footerVM = Observable<ReceiptFooterVM?>(nil)
    weak var swipeTableCellDelegate: MGSwipeTableCellDelegate? = nil
    fileprivate let disposeBag = DisposeBag()
    
    convenience init(data: ObservableArray<ReceiptItemsSectionVM>, footerVM: Observable<ReceiptFooterVM?>, swipeTableCellDelegate: MGSwipeTableCellDelegate) {
        self.init(frame: CGRect.zero, style: UITableViewStyle.plain, data: data, footerVM: footerVM, swipeTableCellDelegate: swipeTableCellDelegate)
    }
    
    init(frame: CGRect, style: UITableViewStyle, data: ObservableArray<ReceiptItemsSectionVM>, footerVM: Observable<ReceiptFooterVM?>, swipeTableCellDelegate: MGSwipeTableCellDelegate) {
        super.init(frame: frame, style: style)
        self.data = data
        self.footerVM = footerVM
        self.swipeTableCellDelegate = swipeTableCellDelegate
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    fileprivate func initialize() {
        self.dataSource = self
        self.delegate = self
        self.frame = CGRect(origin: self.frame.origin, size: CGSize(width: UIScreen.main.bounds.width * 0.9, height: getTotalHeight()))
        self.register(UINib(nibName:ReceiptItemCell.identifier, bundle:nil) , forCellReuseIdentifier: ReceiptItemCell.identifier)
        self.register(UINib(nibName:ReceiptTotalDoubleCell.identifier, bundle:nil) , forCellReuseIdentifier: ReceiptTotalDoubleCell.identifier)
        self.register(UINib(nibName:ReceiptTotalCell.identifier, bundle:nil) , forCellReuseIdentifier: ReceiptTotalCell.identifier)
        self.backgroundColor = UIColor.clear
        data.observeNext(with: { [weak self] data in
            self?.reloadData()
        }).dispose(in: disposeBag)
        footerVM.observeNext(with: { [weak self] footer in
            self?.reloadData()
        }).dispose(in: disposeBag)
    }

    fileprivate func getTotalHeight() -> CGFloat {
        var totalHeight = CGFloat(0.0)
        data.array.forEach {
            totalHeight = totalHeight + $0.getSectionTotalHeight()
        }

       totalHeight = totalHeight + ReceiptItemFooter.Height
        return totalHeight
    }

    fileprivate func getHeader(_ section: Int) -> UIView {
        let view = ReceiptItemSectionView(frame: CGRect(x: CGFloat(0.0) , y: CGFloat(0.0) , width: CGFloat(self.frame.width), height: ReceiptItemSectionView.Height))
            
        view.setup(data.array[section])
        return view
    }
    
    fileprivate func getFooter() -> UIView {
        let view = ReceiptItemFooter(frame: CGRect(x: CGFloat(0.0) , y: CGFloat(0.0) , width: CGFloat(self.frame.width), height: ReceiptItemFooter.Height))
        if let footerVM = self.footerVM.value {
            view.setup(footerVM)
        }
        return view
    }
}

extension ReceiptTableView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        return self.getHeader(section)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return ReceiptItemSectionView.Height
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let section = data.array[section]
        return section.isItemSection ? nil : getFooter()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let section = data.array[section]
        return section.isItemSection ? 0 : ReceiptItemFooter.Height
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = data.array[indexPath.section]
        return section.isItemSection ? section.items[indexPath.row].getHeight() : section.footerItems[indexPath.row].getHeight()
    }
}

extension ReceiptTableView: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return data.array.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        let section = data.array[section]
        return section.isItemSection ? section.items.count : section.footerItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let section = data.array[indexPath.section]
        if section.isItemSection {
            let cellVM = section.items[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: ReceiptItemCell.identifier, for: indexPath) as! ReceiptItemCell
            cell.setup(cellVM)
            cell.delegate = swipeTableCellDelegate
            return cell
        } else {
            let cellVM = section.footerItems[indexPath.row]
            if let cellIdentifier = cellVM.cellIdentifier {
                if cellIdentifier == ReceiptTotalDoubleCell.identifier {
                    let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! ReceiptTotalDoubleCell
                    cell.setup(cellVM)
                    return cell
                }
            }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: ReceiptTotalCell.identifier, for: indexPath) as! ReceiptTotalCell
            cell.setup(cellVM)
            return cell
        }
    }
}
