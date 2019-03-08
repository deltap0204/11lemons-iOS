//
//  DeliveryOptionPicker.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation
import UIKit
import Bond

final class DeliveryOptionPicker: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    fileprivate let deliveryOptionList: [DeliveryPricing]
    let selectedOption = Observable<DeliveryPricing?>(nil)
    
    required init?(coder aDecoder: NSCoder) {
        deliveryOptionList = DataProvider.sharedInstance.deliveryPricing.value.filter { $0.isAvailable }
        super.init(coder: aDecoder)
        delegate = self
        dataSource = self
        selectedOption.value = deliveryOptionList.last
        isScrollEnabled = false
        selectedOption.skip(first: 1).observeNext { [weak self] in
            if let selectedOption = $0,
                let index = self?.deliveryOptionList.index(where: { $0.type == selectedOption.type }), self?.indexPathsForSelectedItems?.first?.item != index {
                    self?.selectItem(at: IndexPath(item: index, section: 0), animated: false, scrollPosition: UICollectionViewScrollPosition())
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return deliveryOptionList.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! DeliveryOptionCell
        let deliveryOption = deliveryOptionList[indexPath.item]
        cell.deliveryOption = deliveryOption
        if deliveryOption.type == selectedOption.value?.type {
            selectItem(at: indexPath, animated: false, scrollPosition: UICollectionViewScrollPosition())
            self.collectionView(self, didSelectItemAt: indexPath)
            cell.isSelected = true
            cell.alpha = 1.0
        } else {
            cell.isSelected = false
            cell.alpha = 1.0
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedOption.next(deliveryOptionList[indexPath.item])
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let count = deliveryOptionList.count
        let viewWidth = collectionView.frame.size.width
        let totalCellWidth: CGFloat = 60 * CGFloat(count)
        let totalSpacingWidth: CGFloat = 27 * (CGFloat(count) - 1)
        
        let leftInset = (viewWidth - (totalCellWidth + totalSpacingWidth)) / CGFloat(2)
        let rightInset = leftInset
        
        return UIEdgeInsetsMake(0, leftInset, 0, rightInset)
    }
}
