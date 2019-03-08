//
//  SwipedTabBar.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import UIKit
import Bond
import ReactiveKit

final class SwipedTabBarCellViewModel: ViewModel {
    
    let name: String?
    let selected = Observable(false)
    let newItems = Observable(false)
    
    init(name: String?) {
        self.name = name
    }
}

final class SwipedTabBar: UICollectionView {
    
    static let ReuseIdentifier = "SwipedTabBarCell"
    
    let separator = UIView()
    let items = MutableObservableArray<SwipedTabBarCellViewModel>()

    var selectedIndex: Int? = nil {
        didSet {
            if let selectedIndex = selectedIndex, selectedIndex < items.count && selectedIndex >= 0  && selectedIndex != oldValue {
                self.selectedTab = self.cellForItem(at: IndexPath(item: selectedIndex, section: 0)) as? SwipedTabBarCell
            }
        }
    }
    
    fileprivate let disposeBag = DisposeBag()
    
    fileprivate weak var selectedTab: SwipedTabBarCell? {
        didSet {
            disposeBag.dispose()
            selectedTab?._onLayoutSubview.observeNext { [weak self] in
                self?.separator.frame.size.width = (self?.selectedTab?.frame.width ?? 0) - 25
                UIView.animate(withDuration: 0.1, animations: {
                    self?.separator.center.x = self?.selectedTab?.center.x ?? 0
                }) 
                }.dispose(in: disposeBag)
            selectedTab?.isSelected = true
            oldValue?.isSelected = false
            scrollToSelected()
        }
    }
    
    fileprivate func scrollToSelected() {
        guard let selectedTab = selectedTab else { return }
        var rect = selectedTab.frame
        if contentOffset.x + self.center.x < selectedTab.center.x {
            rect.size.width = rect.width / 2 + self.center.x
            rect.size.width = rect.width > self.contentSize.width ? self.contentSize.width : rect.width
        } else {
            rect.origin.x -= center.x - rect.width / 2
            rect.origin.x = rect.origin.x < 0 ? 0 : rect.origin.x
        }
        scrollRectToVisible(rect, animated: true)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        instantiate()
    }
    
    fileprivate func setupMenuItemSeparator() {
        
        separator.frame = CGRect(x: 0, y: self.bounds.height - 2, width: 0, height: 4)
        separator.backgroundColor = UIColor.lemonBlackColor()
        separator.autoresizingMask = [.flexibleTopMargin, .flexibleRightMargin, .flexibleLeftMargin]
        self.addSubview(separator)
    }
    
    fileprivate func instantiate() {
        setupMenuItemSeparator()
        
        items.bind(to: self) { [weak self] items, indexPath, collectionView in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SwipedTabBar.ReuseIdentifier, for: indexPath)
            if let swipedTabBarCell = cell as? SwipedTabBarCell {
                //TODO migration-check
                
                //Before migration code
                //swipedTabBarCell.viewModel = items[indexPath.section][indexPath.row]
                
                //Possible fix
                swipedTabBarCell.viewModel = items.item(at: indexPath.item)
                if indexPath.row == self?.selectedIndex {
                    self?.selectedTab = swipedTabBarCell
                }
                return swipedTabBarCell
            }
            return cell
        }
        self.delegate = self
    }
    
}

extension SwipedTabBar: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedIndex = indexPath.row
    }
}

extension SwipedTabBar: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let name = items.array[indexPath.row].name?.uppercased() as NSString?
        return CGSize(width: (name?.size(withAttributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 13.0)]).width ?? 0) + 20, height: collectionView.bounds.height)
    }
}

final class SwipedTabBarCell: UICollectionViewCell {
    
    @IBOutlet fileprivate weak var nameLabel: UILabel!
    @IBOutlet fileprivate weak var centerYConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate weak var newItemsIndicatorView: UIView!
    
    let disposeBag = DisposeBag()
    //let onLayoutSubview = SafeSignal<Void>()
    fileprivate let _onLayoutSubview = PublishSubject<Void, NoError>()
    
    override var isSelected: Bool {
        didSet {
            viewModel?.selected.next(isSelected)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag.dispose()
    }
    
    var viewModel: SwipedTabBarCellViewModel? {
        didSet {
            bindViewModel()
        }
    }
    
    fileprivate func bindViewModel() {
        nameLabel.text = viewModel?.name?.uppercased()
        viewModel?.selected.observeNext { [weak self] selected in
            UIView.animate(withDuration: 0.1, animations: {
                self?.nameLabel.alpha = selected ? 1 : 0.3
                self?.newItemsIndicatorView.alpha = selected ? 1 : 0.3
                let scale: CGFloat = selected ? 1.2 : 1
                self?.newItemsIndicatorView.transform = CGAffineTransform(scaleX: scale, y: scale)
                self?.nameLabel.font = UIFont.systemFont(ofSize: selected ? 16 : 13)
                self?.centerYConstraint.constant = selected ? 0 : 8
            }) 
            
        }.dispose(in: disposeBag)
        viewModel?.newItems.map { !$0 }.bind(to: self.newItemsIndicatorView.bnd_hidden).dispose(in: disposeBag)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //onLayoutSubview.next()
        _onLayoutSubview.next()
    }
}
