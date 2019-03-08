import Foundation
import UIKit

class PreferencesUserView: UIView {
    
    @IBOutlet fileprivate weak var stackView: UIStackView!
    @IBOutlet fileprivate weak var lblTitle: UILabel!
    fileprivate var currentView: UIView?
    var viewModel: PreferencesRowViewModel?
    
    convenience init(viewModel: PreferencesRowViewModel) {
        self.init(frame: CGRect.zero, viewModel: viewModel)
    }
    
    init(frame: CGRect, viewModel: PreferencesRowViewModel) {
        self.viewModel = viewModel
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.viewModel = nil
        super.init(coder: aDecoder)
        initialize()
    }
    
    fileprivate func initialize() {
        if let view = Bundle.main.loadNibNamed("PreferencesUserView", owner: self, options: nil)![0] as? UIView {
            self.frame = CGRect(origin: self.frame.origin, size: CGSize(width: view.frame.width, height: viewModel?.getRowsHeight() ?? CGFloat(0)))
            view.frame = self.frame
            view.isUserInteractionEnabled = true
            self.currentView = view
            self.addSubview(self.currentView!)
        }

        viewModel?.rowViewModels.forEach { [weak self] row in
            guard let strongSelf = self else { return }
            let view = PreferenceUserRowView(viewModel: row)
            view.heightAnchor.constraint(equalToConstant: view.frame.height).isActive = true
            view.widthAnchor.constraint(equalToConstant: view.frame.width).isActive = true
            strongSelf.stackView.addArrangedSubview(view)
        }
    }
}
