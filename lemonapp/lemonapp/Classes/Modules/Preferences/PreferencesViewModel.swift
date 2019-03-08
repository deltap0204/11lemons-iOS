//
//  PreferencesViewModel.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation
import Bond
import SwiftDate
import ReactiveKit

final class PreferencesViewModel {
    
    let tipsValues = ["0%", "5%", "10%", "15%", "20%", "25%"]
    var selectedTips = Observable<Int>(0)
    
    var detergents = [Detergent.Original, Detergent.MountainSpring, Detergent.Lavender, Detergent.FreeNGentle]//should have same order as corresponding buttons on UI
    var selectedDetergent = Observable(Detergent.Original)
    
    var softeners = [Softener.None, Softener.Downy]//should have same order as corresponding buttons on
    var selectedSoftener = Observable(Softener.Downy)
    
    var dryers = [Dryer.None, Dryer.Bounce]//should have same order as corresponding buttons on
    var selectedDryer = Observable(Dryer.Bounce)
    
    var shirts = [Shirt.Folded, Shirt.Hanger]//should have same order as corresponding buttons on
    var selectedShirt = Observable(Shirt.Hanger)
    
    fileprivate var addressAvailable = Observable(false)
    fileprivate var paymentAvailable = Observable(false)
    
    fileprivate(set) lazy var alertHidden: SafeSignal<Bool> = {
        return combineLatest(self.addressAvailable, self.paymentAvailable).map { addressAdded, paymentAdded in
            return addressAdded && paymentAdded
        }
    }()
    
    fileprivate(set) lazy var alertText: SafeSignal<String> = {
        return combineLatest(self.addressAvailable, self.paymentAvailable).map { addressAdded, paymentAdded in
            if !addressAdded {
                return "Address Required"
            } else if !paymentAdded {
                return "Payment Info Required"
            } else {
                return ""
            }
        }
    }()

    var requiredInfoViewModel: CommonContainerViewModel? {
        if !addressAvailable.value {
            return CommonContainerViewModel(userWrapper: userWrapper, screenIndetifier: .AddressScreen, backButtonTitle: "Preferences")
        } else if !paymentAvailable.value {
            return CommonContainerViewModel(userWrapper: userWrapper, screenIndetifier: .PaymentCardScreen, backButtonTitle: "Preferences")
        }
        return nil
    }
    
    var requiredInfoCreationSegue: StoryboardSegueIdentifier? {
        if !addressAvailable.value {
            return .NewAddress
        } else if !paymentAvailable.value {
            return .NewPayment
        }
        return nil
    }
    
    var notes = Observable<String?>("")
    
    let userViewModel: UserViewModel

    // Scheduled pickup-related properties
    let frequency = Observable<Int>(0) //TODO: load form preferences
    fileprivate(set) lazy var frequencyDescription: SafeSignal<String> = {
        return self.frequency.map {
            if $0 == 0 {
                return "NEVER"
            } else if $0 == 1 {
                return "EVERY WEEK"
            } else {
                return "EVERY \($0) WEEKS"
            }
        }
    }()
    fileprivate(set) lazy var frequencyDescriptionColor: SafeSignal<UIColor> = {
        return self.frequency.map {
            if $0 == 0 {
                return UIColor.white
            } else {
                return UIColor.appBlueColor
            }
        }
    }()
    
    fileprivate(set) lazy var nextPickupAlpha: SafeSignal<Float> = {
        return self.frequency.map { $0 == 0 ? 0.1 : 1.0 }
    }()
    
    
    let weekday = Observable<Weekday?>(nil)
    
    fileprivate(set) lazy var shouldHideNotesHint: SafeSignal<Bool> = {
        return self.notes.map { !($0?.isEmpty ?? true) }
    }()
    
    fileprivate(set) lazy var nextPickupTitle: SafeSignal<String> = {
        return combineLatest(self.frequency, self.weekday).map { frequency, weekday in
            return self.nextPickupDateString(frequency, weekday: weekday, currentDate: Date())
        }
    }()
    
    fileprivate(set) lazy var shouldHideNextPickupDate: SafeSignal<Bool> = {
        return self.frequency.map { $0 == 0 }
    }()
    
    fileprivate let preferences: Preferences
    fileprivate let userWrapper: UserWrapper
    fileprivate let changedUser: User
    
    init(userWrapper: UserWrapper) {
        self.userWrapper = userWrapper
        self.changedUser = userWrapper.changedUser
        self.preferences = changedUser.preferences
        userViewModel = UserViewModel(userWrapper: userWrapper)
        selectedDetergent.next(preferences.detergent)
        selectedShirt.next(preferences.shirts)
        selectedDryer.next(preferences.dryer)
        selectedSoftener.next(preferences.softener)
        selectedTips.next(preferences.tips)
        notes.next(preferences.notes)
        weekday.next(Int(preferences.scheduledWeekday) ?? 0)
        frequency.next(preferences.scheduledFrequency)
        
        notes.observeNext { [weak self] in self?.preferences.notes = $0 ?? "" }
        selectedDetergent.observeNext { [weak self] in self?.preferences.detergent = $0 }
        selectedShirt.observeNext { [weak self] in self?.preferences.shirts = $0 }
        selectedDryer.observeNext { [weak self] in self?.preferences.dryer = $0 }
        selectedSoftener.observeNext { [weak self] in self?.preferences.softener = $0 }
        selectedTips.observeNext { [weak self] in self?.preferences.tips = $0 }
        
        addressAvailable.next(userWrapper.defaultAddress.value != nil)
        paymentAvailable.next(userWrapper.defaultPaymentCard.value != nil)
        alertHidden.filter { $0 == false }.observeNext { [weak self ]_ in
            self?.frequency.next(0)
        }
        
        userWrapper.defaultAddress.map{ $0 != nil }.bind(to: addressAvailable)
        userWrapper.defaultPaymentCard.map{ $0 != nil }.bind(to: paymentAvailable)
        
        frequency.observeNext { [weak self] newFrequency in
            if newFrequency == 0 {
                self?.weekday.next(nil)
            } else if self?.weekday.value == nil {
                self?.weekday.next(2) // default value
            }
            self?.preferences.scheduledFrequency = newFrequency ?? 0
        }
        
        weekday.observeNext { [weak self] day in
            if let day = day {
                self?.preferences.scheduledWeekday = "\(day)"
            } else {
                self?.preferences.scheduledWeekday = ""
            }
        }
    }

    
    func save() {
        changedUser.preferences = preferences
        // movetonextweek
        _ = LemonAPI.editProfile(user: changedUser).request().observeNext { (userResolver: EventResolver<User>) in
            do {
                let user = try userResolver()
                self.userWrapper.saveChanges()
                user.preferences.save()
            } catch let error {
                print(error)
            }
        }
    }
    
    fileprivate func nextPickupDateString(_ frequency: Int, weekday: Int?, currentDate: Date) -> String {
        let dateString = Preferences.nextPickupDateString(frequency, weekday: weekday, currentDate: currentDate)
        return "Next Pickup: \(dateString)"
    }
}
