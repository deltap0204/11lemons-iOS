//
//  CloudClosetCell.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import UIKit
import Bond
import ReactiveKit

final class CloudClosetCellViewModel: ViewModel {
    
    var imageRequest: SafeSignal<UIImage?> {
        
        return SafeSignal/*(replayLength: 1)*/ { [weak self] sink in
            if let imageName = self?.garment.imageName {
                if let cachedImage = ImageCache.getImage(imageName) {
                    sink.completed(with: cachedImage)
                } else {
                    _ = LemonAPI.getCloudClosetImage(imgURL: imageName).request().observeNext { (resolver: ImageResolver) in
                        if let image = resolver {
                                ImageCache.saveImage(image, url: imageName).observeNext { _ in
                                    sink.completed(with: resolver)
                                }
                        } else {
                            sink.completed(with: resolver)
                        }
                    }
                }
            }
            //return nil
            return BlockDisposable {}
        }
    }
    
    var viewed: Bool {
        didSet {
            garment.viewed.next(viewed)
        }
    }
    
    let brandName: String?
    
    var type: GarmentType? {
        return garment.type
    }
    
    fileprivate let garment: Garment
    
    
    init (garment: Garment) {
        self.garment = garment
        self.viewed = garment.viewed.value
        self.brandName = garment.brand?.name?.uppercased()
    }
}

final class CloudClosetCell: UICollectionViewCell {
    
    @IBOutlet fileprivate weak var imageView: UIImageView!
    @IBOutlet fileprivate weak var acivityIndicator: UIActivityIndicatorView!
    @IBOutlet fileprivate weak var brandNameLabel: UILabel!
    @IBOutlet weak var brandNameLabelWidth: NSLayoutConstraint!
    @IBOutlet fileprivate weak var newItemIndicatorView: UIView!
    
    let image = Observable<UIImage?>(nil)
    
    fileprivate var isAddedToSuperView: Bool = false
    
    let disposeBag = DisposeBag()
    var scale: CGFloat = 1.0 {
        didSet {
            if superview != nil {
                let transform =  CGAffineTransform(scaleX: scale, y: scale)
                imageView.transform = transform
                newItemIndicatorView.transform = transform
                newItemIndicatorView.frame.origin = CGPoint(x: imageView.frame.origin.x + imageView.frame.width - newItemIndicatorView.frame.width, y: imageView.frame.origin.y)
                if scale > 1.2 {
                    viewModel?.viewed = true
                }
            }
        }
    }
    
    fileprivate var offset: CGFloat = 0 {
        didSet {
            brandNameLabel.center.x = frame.width / 2 + brandNameLabel.frame.width * offset * 1.5
            self.scale = 1 + (0.5 - abs(offset))
        }
    }
    
    var viewModel: CloudClosetCellViewModel? = nil {
        didSet {
            bindViewModel()
        }
    }
    
    func observeOffset(_ offsetObservable: Observable<CGFloat>) {
        let cellWidth = self.frame.width
        offsetObservable.observeNext { [weak self] offset in
            if let strongSelf = self {
                var offset = ((strongSelf.center.x - offset) / cellWidth * 1.25) / 3
                offset = offset > 0.5 ? 0.5 : offset < -0.5 ? -0.5 : offset
                strongSelf.offset = offset
            }
        }.dispose(in: disposeBag)
    }
    
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        self.offset += 0
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if !isAddedToSuperView {
            animate()
            isAddedToSuperView = true
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag.dispose()
        image.next(nil)
        brandNameLabel.text = nil
        newItemIndicatorView.isHidden = true
        self.scale = 1
    }
    
    fileprivate func bindViewModel() {
        image.bind(to: imageView.bnd_image)
        viewModel?.imageRequest.bind(to: self.imageView.bnd_image).dispose(in: disposeBag)
        
        image.map { $0 == nil }.bind(to: acivityIndicator.bnd_animating).dispose(in: disposeBag)
        brandNameLabel.text = viewModel?.brandName
        newItemIndicatorView.isHidden = viewModel?.viewed ?? true
    }
    
    fileprivate func animate() {
        let prevScale = scale
        self.scale = 1
        UIView.animate(withDuration: 0.3, animations: {
            self.scale = prevScale
        }) 
    }
}
