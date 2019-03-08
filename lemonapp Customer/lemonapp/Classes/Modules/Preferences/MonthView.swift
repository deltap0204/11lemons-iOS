//
//  MonthView.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation
import SwiftDate
import Bond
import ReactiveKit


final class MonthView: UIView {
    
    @IBOutlet var collectionView: UICollectionView!
    
    var weekday = Observable<Weekday>(1)
    var frequency = Observable<Int>(0)
    
    fileprivate let currentDate = Date()
    fileprivate var days = [0]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        days = generateDays()
        collectionView.reloadData()
        
        combineLatest(weekday, frequency).observeNext { [weak self] _, _ in
            self?.collectionView.reloadData()
        }

    }
    
    fileprivate func generateDays() -> Array<Int> {
        var days: Array<Int> = []

        let firstDayOfCurrentMonth = currentDate - (currentDate.day - 1).days
        let weekdayOfFirstDayOfCurrenyMonth = firstDayOfCurrentMonth.weekdayNumber()
        
        let lastDayOfPrevMonth = firstDayOfCurrentMonth - 1.days
        for i in 0 ..< weekdayOfFirstDayOfCurrenyMonth {
            days.append(lastDayOfPrevMonth.day - (weekdayOfFirstDayOfCurrenyMonth - i - 1))
        }
        
        let calendar = Calendar.current
        let numberOfDaysInCurrentMonth = (calendar as NSCalendar).range(of: NSCalendar.Unit.day, in: NSCalendar.Unit.month, for: currentDate).length
        for i in 1 ... numberOfDaysInCurrentMonth {
            days.append(i)
        }
        
        var i = 1
        while days.count < 42 {
            days.append(i)
            i += 1
        }
        print(lastDayOfPrevMonth.day)
        
        return days
    }
    
}

extension MonthView: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 42 // 6 rows 7 days in each
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("index: \(indexPath.item)")
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! DayCell
        cell.day = days[indexPath.row]
        // saturdays and sundays
        if indexPath.row == 0 || (indexPath.row) % 7 == 6 || indexPath.row % 7 == 0 {
            cell.active = false
        } else {
            cell.active = true
            if frequency.value == 0 {
                cell.isSelected = false
            } else {
                // matching weekday
                if indexPath.item % 7 == weekday.value {
                    let row = Int(floor(Double(indexPath.item) / 7.0))
                    // matching frequency
                    if row % frequency.value == 0 {
                        cell.isSelected = true
                    } else {
                        cell.isSelected = false
                    }
                } else {
                    cell.isSelected = false
                }
            }
        }
        return cell
    }
}
