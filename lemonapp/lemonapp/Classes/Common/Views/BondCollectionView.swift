//
//  BondCollectionView.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import UIKit
import Bond

class BondCollectionView: UICollectionView {
    
    fileprivate static let ContenSizePath = "contentSize"
    
    fileprivate struct AssociatedKeys {
        static var Key = "bnd_ContentSizeKey"
    }
    
    func scrollToItemAtIndexPath(_ indexPath: IndexPath, animated: Bool) {
        let widht = (collectionViewLayout as? CenterCellCollectionViewFlowLayout)?.itemSize.width ?? 0
        let margin = (collectionViewLayout as? CenterCellCollectionViewFlowLayout)?.minimumLineSpacing ?? 0
        let offset = (widht + margin) * CGFloat(indexPath.row)
        //fixed overlaping of brand labels
        if !animated {
            contentOffset = CGPoint(x: offset - 1, y: 0)
        }
        setContentOffset(CGPoint(x: offset, y: 0), animated: true)
    }
    
    var bnd_contentSize: Observable<CGSize?> {
        if let bnd_contentSize: AnyObject = objc_getAssociatedObject(self, &AssociatedKeys.Key) as AnyObject {
            return bnd_contentSize as! Observable<CGSize?>
        } else {
            let bnd_contentSize = Observable<CGSize?>(self.contentSize)
            objc_setAssociatedObject(self, &AssociatedKeys.Key, bnd_contentSize, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            
            self.addObserver(self, forKeyPath: BondCollectionView.ContenSizePath, options: .new, context: nil)
            
            return bnd_contentSize
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == BondCollectionView.ContenSizePath {
            //let new = change?["new"]?.CGSizeValue
            let new = (change?[.newKey] as AnyObject).cgSizeValue
            if bnd_contentSize.value != new {
                bnd_contentSize.next(self.contentSize)
            }
        }
    }
    
    deinit {
        self.removeObserver(self, forKeyPath: BondCollectionView.ContenSizePath)
    }
}

