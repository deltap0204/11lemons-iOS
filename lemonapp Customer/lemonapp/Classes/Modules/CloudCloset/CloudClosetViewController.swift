//
//  CloudClosetViewController.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import UIKit
import Bond
import ReactiveKit

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


final class CloudClosetViewModel: ViewModel {
    
    let cloudClosetCellViewModels = MutableObservableArray<CloudClosetCellViewModel>()
    let itemCountText = Observable("0 ITEMS")
    let swipedTabBarCellViewModels = MutableObservableArray<SwipedTabBarCellViewModel>()
    let selectedType = Observable<GarmentType?>(nil)
    let selectedGarmentIndex = Observable<Int?>(0)
    
    fileprivate let router: CloudClosetRouter
    fileprivate var garmentTypes = [GarmentType]()
    fileprivate var garments = [Garment]()
    
    fileprivate let disposeBag = DisposeBag()
    
    var currentGarmentType: GarmentType? = nil
    
    init (router: CloudClosetRouter) {
        self.router = router
        
        selectedType.map { [weak self] type -> Int? in
            guard type != self?.currentGarmentType else { return nil }
            self?.currentGarmentType = type
            if let itemsCount = self?.garments.count, itemsCount > 0 {
                if itemsCount > 2 {
                    for index in 2..<itemsCount {
                        if self?.garments[index].type == type {
                            return index
                        }
                    }
                } else {
                    for index in 0..<itemsCount {
                        if self?.garments[index].type == type {
                            return index
                        }
                    }
                }
                
            }
            return 0
        }.bind(to: selectedGarmentIndex)
        
        selectedType.combineLatest(with: DataProvider.sharedInstance.cloudCloset).observeNext { [weak self] garmentType, _ in
            guard garmentType != nil else { return }
            let garments = DataProvider.sharedInstance.cloudCloset.array.filter { $0.type == garmentType }
            let count = garments.count
            self?.itemCountText.next("\(count) ITEM" + (count != 1 ? "S" : ""))
        }
        
        DataProvider.sharedInstance.cloudCloset.observeNext { [weak self] _ in
            if let strongSelf = self {
                strongSelf.disposeBag.dispose()
                var garments = DataProvider.sharedInstance.cloudCloset.array
                strongSelf.garmentTypes = Array(Set(garments.flatMap { $0.type })).sorted { $0.id > $1.id }
                
                let swipedTabBarCellViewModelArray:[SwipedTabBarCellViewModel] = strongSelf.garmentTypes.map { garmentType in
                    let viewModel = SwipedTabBarCellViewModel(name: garmentType.type)
                    viewModel.selected.skip(first: 1).observeNext { [weak garmentType] in
                        if $0 && self?.selectedType.value != garmentType {
                            self?.selectedType.next(garmentType)
                        }
                    }.dispose(in: strongSelf.disposeBag)
                    let garFiltered = garments.filter{ ($0.type == garmentType )}/*.reduce(Observable(false), { (res, garment) in
                        res.combineLatest(with: garment.viewed).map { $0 || !$1 }
                    })*/
                    
                    garFiltered.reduce(into: Observable(false), { 
                        $0.combineLatest(with: $1.viewed).map { $0 || !$1 }
                    }).bind(to: viewModel.newItems).dispose(in: strongSelf.disposeBag)
                    
//                    garments.filter { (($0 as Garment).type as! GarmentType) == (garmentType as! GarmentType) }.reduce(Observable(false)) {
//                        $0.combineLatest(with: $1.viewed).map { $0 || !$1 }
//                    }.bind(to: viewModel.newItems).dispose(in: strongSelf.disposeBag)
                    return viewModel
                }
                strongSelf.swipedTabBarCellViewModels.replace(with: swipedTabBarCellViewModelArray)
                
                let uniqGarments = garments
                if garments.count > 2 {
                    garments.append(uniqGarments.first!)
                    garments.append(uniqGarments[1])
                    garments.insert(uniqGarments.last!, at:0)
                    garments.insert(uniqGarments[uniqGarments.count - 2], at:0 )
                }
                strongSelf.garments = garments
                strongSelf.cloudClosetCellViewModels.replace(with: garments.map { CloudClosetCellViewModel(garment: $0) })
            }
        }
    }
    
    func getIndexForNewGrament() -> Int {
        let garmentsCount = garments.count
        if garmentsCount > 2 {
            for index in 2..<garmentsCount {
                if !garments[index].viewed.value {
                    return index
                }
            }
            return 2
        } else {
            for index in 0..<garmentsCount {
                if !garments[index].viewed.value {
                    return index
                }
            }
        }
        return 0
    }
    
    func getIndexForTypeContainsNew() -> Int {
        let brandsCount = swipedTabBarCellViewModels.count
        for index in 0..<brandsCount {
            if swipedTabBarCellViewModels[index].newItems.value {
                return index
            }
        }
        return 0
    }
    
    func getIndexForGarmentType(_ type: GarmentType) -> Int? {
        return garmentTypes.index(of: type)
    }
    
    func goToOrders() {
        router.showOrders()
    }
}

final class CloudClosetViewController: UIViewController {
    
    @IBOutlet fileprivate weak var cloudClosetColletctionView: BondCollectionView!
    @IBOutlet fileprivate weak var itemCountLabel: UILabel!
    @IBOutlet fileprivate weak var doneButton: UIButton!
    @IBOutlet fileprivate weak var tabBar: SwipedTabBar!
    
    let offset = Observable<CGFloat>(0)
    
    var viewModel: CloudClosetViewModel? {
        didSet {
            bindViewModel()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
        
        offset.next(self.view.frame.width / 2)
        
        doneButton.bnd_tap.observeNext { [weak self] in
            self?.viewModel?.goToOrders()
        }
        
        cloudClosetColletctionView.bnd_contentSize.observeNext { [weak self] in
            self?.tabBar.selectedIndex = self?.viewModel?.getIndexForTypeContainsNew() ?? 0
            if let index = self?.viewModel?.getIndexForNewGrament(), $0?.width > 0 {
                self?.cloudClosetColletctionView.scrollToItemAtIndexPath(IndexPath(item: index, section: 0), animated: false)
            }
        }
        
        (cloudClosetColletctionView.collectionViewLayout as? CenterCellCollectionViewFlowLayout)?.delegate = self
    }
    
    fileprivate func bindViewModel() {
        guard isViewLoaded && viewModel != nil else { return }
        
        viewModel?.cloudClosetCellViewModels.bind(to: cloudClosetColletctionView) { [weak self] dataSource, indexPath, collectionView in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CloudClosetCell", for: indexPath)
            //TODO migration-check
            //TODO tableview-migration
            //Before migration code
            
        
            if let cloudClosetCell = cell as? CloudClosetCell {
                
                cloudClosetCell.viewModel = dataSource/*[indexPath.section]*/[indexPath.row]
                if let offset = self?.offset {
                    cloudClosetCell.observeOffset(offset)
                    cloudClosetCell.brandNameLabelWidth.constant = (self?.view.frame.width ?? 0) * 1.1
                }
                return cloudClosetCell

            }
            return cell
        }
        
        viewModel?.itemCountText.bind(to: itemCountLabel.bnd_text)
        viewModel?.swipedTabBarCellViewModels.bind(to: tabBar.items)
        viewModel?.selectedGarmentIndex.skip(first: 1).observeNext { [weak self] in
            if let index = $0 {
                self?.cloudClosetColletctionView.scrollToItemAtIndexPath(IndexPath(item: index, section: 0), animated: true)
            }
        }
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
}

extension CloudClosetViewController: UICollectionViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.offset.next(self.view.frame.width / 2 + scrollView.contentOffset.x)
    }
}

extension CloudClosetViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 180, height: collectionView.bounds.height)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let inset = (self.view.bounds.width - 180) / 2
        return UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
    }
}

extension CloudClosetViewController: CenterCellCollecitonViewDeleagetFlowlayout {
    
    func collectionView(_ collectionView: UICollectionView, willScrollToIndexPath indexPath: IndexPath) {
        if let nextGarmentType = (collectionView.cellForItem(at: indexPath) as? CloudClosetCell)?.viewModel?.type,
            let index = viewModel?.getIndexForGarmentType(nextGarmentType) {
                viewModel?.currentGarmentType = nextGarmentType
                tabBar.selectedIndex = index
        }
    }
    
}
