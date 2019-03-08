//
//  WeekdayPicker.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation
import Bond


typealias Weekday = Int


final class WeekdayPicker: UIView {
    
    @IBOutlet var collectionView: UICollectionView!
    
    var selectedWeekday = Observable<Weekday?>(nil)
    
    fileprivate var weekdayList = ["S", "M", "T", "W", "T", "F", "S"]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        weekdayList = formatter.weekdaySymbols
        collectionView.reloadData()
        selectedWeekday.observeNext {
            if let item = $0 {
                self.collectionView.selectItem(at: IndexPath(item: item, section: 0), animated: false, scrollPosition: UICollectionViewScrollPosition())
            } else {
                self.collectionView.indexPathsForSelectedItems?.forEach {
                    self.collectionView.deselectItem(at: $0, animated: false)
                }
            }
        }
    }
}


extension WeekdayPicker: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 7
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! WeekdayCell
        cell.weekdayName = weekdayList[indexPath.row]
        cell.weekday = indexPath.row
        cell.active = indexPath.row != 0 && indexPath.row != 6
        return cell
    }
}

extension WeekdayPicker: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedWeekday.value = indexPath.row
    }
}
