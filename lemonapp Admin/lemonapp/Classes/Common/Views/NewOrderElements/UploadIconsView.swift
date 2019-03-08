//
//  UploadIconsView.swift
//  lemonapp
//
//  Created by Lucas Pelizza on 11/21/17.
//  Copyright © 2017 11lemons. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage
import Photos

final class UploadIconsView: UIView {
    
    @IBOutlet fileprivate weak var btnSelectNormalImage: UIButton!
    @IBOutlet fileprivate weak var btnSelectSelectedImage: UIButton!
    @IBOutlet fileprivate weak var lblTitle: UILabel!
    
    @IBOutlet fileprivate weak var activitySelected: UIActivityIndicatorView!
    @IBOutlet fileprivate weak var activityNormal: UIActivityIndicatorView!
    fileprivate var viewController: UIViewController?
    
    var onSelectClosure: ((_ image: UIImage, _ isNormalImage: Bool) -> ())?
    var titleView: String = ""
    var imageNormalURL: String?
    var imageSelectedURL: String?
    var isSelectionNormalImage: Bool = false
    var buttonTitle: String = ""
    
    convenience init (viewController: UIViewController, imageNormalURL: String?, imageSelectedURL: String?, title: String = "Icons", buttonTitle: String = "Department") {
        self.init(frame: CGRect.zero, viewController: viewController, imageNormalURL: imageNormalURL, imageSelectedURL: imageSelectedURL, title: title, buttonTitle: buttonTitle)
    }
    
    init(frame: CGRect, viewController: UIViewController, imageNormalURL: String?, imageSelectedURL: String?, title: String, buttonTitle: String) {
        super.init(frame: frame)
        self.viewController = viewController
        self.titleView = title.uppercased()
        self.imageNormalURL = imageNormalURL
        self.imageSelectedURL = imageSelectedURL
        self.buttonTitle = buttonTitle
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    fileprivate func initialize() {
        if let view = Bundle.main.loadNibNamed("UploadIconsView", owner: self, options: nil)![0] as? UIView {
            self.frame = CGRect(origin: self.frame.origin, size: view.frame.size)
            view.isUserInteractionEnabled = true
            self.addSubview(view)
        }
        self.btnSelectNormalImage.layer.borderColor = UIColor.appBlueColor.cgColor
        self.btnSelectSelectedImage.layer.borderColor = UIColor.appBlueColor.cgColor
        self.btnSelectNormalImage.setTitle(self.buttonTitle)
        self.btnSelectSelectedImage.setTitle(self.buttonTitle)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.lblTitle.text = self.titleView
        loadImage(self.imageNormalURL, activity: self.activityNormal, btn: self.btnSelectNormalImage)
        loadImage(self.imageSelectedURL, activity: self.activitySelected, btn: self.btnSelectSelectedImage)
    }
    
    @IBAction func onSelectImage(_ sender: UIButton) {

        isSelectionNormalImage = sender == self.btnSelectNormalImage
        showImageOptions()
    }
    
    fileprivate func showImageOptions() {
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
    
    fileprivate func loadImage(_ imageURL: String?, activity: UIActivityIndicatorView, btn: UIButton) {
        if let imageUrlString = imageURL {
            if !imageUrlString.isEmpty {
                btn.setTitle("")
                activity.isHidden = false
                btn.__sd_setImage(with: URL(string:Config.LemonEndpoints.PicsEndpoint.rawValue + "lemonpics/" + imageUrlString), for: UIControlState(), placeholderImage: UIImage(), completed: { (image, error, sdCache, url) in
                    activity.isHidden = true
                  btn.setImage(image?.withRenderingMode(.alwaysOriginal), for: UIControlState())
                })
            }
        }
    }
}

extension UploadIconsView: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        self.viewController?.dismiss(animated: true, completion: nil)
        if let URL = info[UIImagePickerControllerReferenceURL] as? URL {
            let result = PHAsset.fetchAssets(withALAssetURLs: [URL], options: nil)
            if let asset = result.firstObject as? PHAsset {
                let manager = PHImageManager.default()
                manager.requestImageData(for: asset, options: nil) { imageData, dataUTI, orientation, info in
                    let fileURL = info!["PHImageFileURLKey"] as? Foundation.URL
                    let filename = fileURL?.lastPathComponent;
                    
                    let imagePNG = UIImage(data: imageData!)!
                    if self.isSelectionNormalImage {
                        self.onSelectClosure!(imagePNG, true)
                        self.btnSelectNormalImage.setImage(imagePNG.withRenderingMode(.alwaysOriginal), for: UIControlState())
                    } else {
                        self.onSelectClosure!(imagePNG, false)
                        self.btnSelectSelectedImage.setImage(imagePNG.withRenderingMode(.alwaysOriginal), for: UIControlState())
                    }
                }
            }
        }
    }
}
