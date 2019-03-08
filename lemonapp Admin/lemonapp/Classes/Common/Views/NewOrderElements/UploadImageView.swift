//
//  UploadImageView.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation
import UIKit

class UploadImageView: UIView {
    
    @IBOutlet fileprivate weak var btnSelectImage: UIButton!
    @IBOutlet fileprivate weak var lblTitle: UILabel!
    fileprivate var viewController: UIViewController?
    var onSelectClosure: ((_ image: UIImage) -> ())?
    var titleView: String = ""
    var imageURL: String?
    
    convenience init (viewController: UIViewController, imageURL: String?, title: String = "Image") {
        self.init(frame: CGRect.zero, viewController: viewController, imageURL: imageURL, title: title)
    }
    
    init(frame: CGRect, viewController: UIViewController, imageURL: String?, title: String) {
        super.init(frame: frame)
        self.viewController = viewController
        self.titleView = title
        self.imageURL = imageURL
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    fileprivate func initialize() {
        if let view = Bundle.main.loadNibNamed("UploadImageView", owner: self, options: nil)![0] as? UIView {
            self.frame = CGRect(origin: self.frame.origin, size: view.frame.size)
            view.isUserInteractionEnabled = true
            self.addSubview(view)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.lblTitle.text = self.titleView
        if let imageUrlString = self.imageURL {
            loadImage(imageUrlString)
        }
    }
    
    @IBAction func didImageButtonPressed(_ sender: AnyObject) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Photo Library", style: .default) { [weak self] _ in
            self?.showImagePicker(.photoLibrary)
            })
        alertController.addAction(UIAlertAction(title: "Take Photo", style: .default) { [weak self] _ in
            self?.showImagePicker(.camera)
            })
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.viewController?.present(alertController, animated: true, completion: nil)

    }
    
    fileprivate func showImagePicker(_ sourceType: UIImagePickerControllerSourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = sourceType
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        self.viewController?.showDetailViewController(imagePicker, sender: self)
    }
    
    fileprivate func loadImage(_ imageURL: String) {
        _ = LemonAPI.getAttributeImage(imgURL: imageURL).request().observeNext { [weak self] (resolver: ImageResolver) in
            self?.btnSelectImage.setImage(resolver, for: .normal)
        }
    }
}

extension UploadImageView: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        self.viewController?.dismiss(animated: true, completion: nil)
        if let photo = info[UIImagePickerControllerEditedImage] as? UIImage, let onSelectClosure = onSelectClosure {
            onSelectClosure(photo)
            btnSelectImage.setImage(photo, for: UIControlState())
        }
    }
}
