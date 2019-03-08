//
//  CenterCellCollectionViewFlowLayout.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class CenterCellCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    weak var delegate: CenterCellCollecitonViewDeleagetFlowlayout?
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        
        if let cv = self.collectionView {
            
            let cvBounds = cv.bounds
            let halfWidth = cvBounds.size.width * 0.5;
            let proposedContentOffsetCenterX = proposedContentOffset.x + halfWidth;
            
            if let attributesForVisibleCells = layoutAttributesForElements(in: cvBounds) {
                
                var candidateAttributes : UICollectionViewLayoutAttributes?
                for attributes in attributesForVisibleCells {
                    
                    // == Skip comparison with non-cell items (headers and footers) == //
                    if attributes.representedElementCategory != UICollectionElementCategory.cell {
                        continue
                    }
                    
                    if let candAttrs = candidateAttributes {
                        
                        let a = attributes.center.x - proposedContentOffsetCenterX
                        let b = candAttrs.center.x - proposedContentOffsetCenterX
                        
                        if fabsf(Float(a)) < fabsf(Float(b)) {
                            candidateAttributes = attributes;
                        }
                        
                    }
                    else { // == First time in the loop == //
                        
                        candidateAttributes = attributes;
                        continue;
                    }
                }
                
                //for looping
                
                let itemsCount = cv.numberOfItems(inSection: 0)
                
                if itemsCount > 2 {                    
                    
                    if candidateAttributes?.indexPath.row < 2 {
                        let prevCandidate = candidateAttributes
                        candidateAttributes = layoutAttributesForItem(at: IndexPath(item: itemsCount - 2 - (2 - candidateAttributes!.indexPath.row), section: 0))
                        cv.contentOffset = CGPoint(x: cv.contentOffset.x - prevCandidate!.frame.origin.x + candidateAttributes!.frame.origin.x, y: 0)
                        cv.layoutSubviews()
                        
                    } else if candidateAttributes?.indexPath.row > itemsCount - 3 {
                        let prevCandidate = candidateAttributes
                        candidateAttributes = layoutAttributesForItem(at: IndexPath(item: 1 + candidateAttributes!.indexPath.row - (itemsCount - 3) , section: 0))
                        cv.contentOffset = CGPoint(x: candidateAttributes!.frame.origin.x - (prevCandidate!.frame.origin.x - cv.contentOffset.x), y: 0);
                        cv.layoutSubviews()
                    }
                }
                delegate?.collectionView(cv, willScrollToIndexPath: candidateAttributes!.indexPath)
                return CGPoint(x: round(candidateAttributes!.center.x - halfWidth), y: proposedContentOffset.y)                
            }
            
        }
        
        // Fallback
        return super.targetContentOffset(forProposedContentOffset: proposedContentOffset)
    }
}

protocol CenterCellCollecitonViewDeleagetFlowlayout: NSObjectProtocol {
    func collectionView(_ collectionView: UICollectionView, willScrollToIndexPath indexPath: IndexPath);
}
