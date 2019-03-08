//
//  CreationBaseVC.swift
//  lemonapp
//
//  Created by Lucas Pelizza on 12/11/17.
//  Copyright © 2017 11lemons. All rights reserved.
//

import UIKit
import MBProgressHUD

class CreationBaseVC: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    var isEditMode = false
    var router: NewOrderRouter?
    
    var yPosition: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        (self.navigationController as? YellowNavigationController)?.barStyle.value = .blue
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        (self.navigationController as? YellowNavigationController)?.barStyle.value = .yellow
    }
    
    
    //MARK: Scroll's methods
    func addViewToScrollView(_ view: UIView) {
        let rect = CGRect(x: 0, y: yPosition, width: self.view.bounds.width, height: view.bounds.height)
        view.frame = rect
        view.isUserInteractionEnabled = true
        scrollView.addSubview(view)
        yPosition += view.bounds.height
        scrollView.contentSize = CGSize(width: self.view.bounds.width, height: yPosition)
    }
    
    //MARK: Actions
    @IBAction func didCancelButtonPressed(_ sender: AnyObject) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func successAndBack() {
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.mode = .customView
        let image = UIImage(named: "ShapeCheck")
        hud.customView = UIImageView(image: image)
        hud.isSquare = true
        hud.label.text = NSLocalizedString("Done", tableName: nil, comment: "HUD done title")
        
        hud.hide(animated: true, afterDelay: 1.0)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(1.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) { [weak self] () -> Void in
            guard let strongSelf = self else { return }
            strongSelf.navigationController?.popViewController(animated: true)
        }
    }
}
