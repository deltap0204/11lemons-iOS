import Foundation
import UIKit
import Bond

class AddOrderDetailsViewController: UIViewController {
    @IBOutlet fileprivate weak var btnUndo: UIButton!
    @IBOutlet fileprivate weak var constraintYPositionFeedbackView: NSLayoutConstraint!
    @IBOutlet fileprivate weak var viewFeedback: UIView!
    @IBOutlet fileprivate weak var btnTotal: HighlightedButton!
    @IBOutlet fileprivate weak var imgScreen: UIImageView!
    @IBOutlet fileprivate weak var activityLoading: UIActivityIndicatorView!
    @IBOutlet fileprivate weak var stackViewHeader: UIStackView!
    @IBOutlet fileprivate weak var tfBarcode: UITextField!
    @IBOutlet fileprivate weak var stackViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate weak var barcodeHeightConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate weak var cardView: UIView!
    @IBOutlet fileprivate weak var scrollView: UIScrollView!
    @IBOutlet fileprivate weak var btnAddToOrder: HighlightedButton!
    @IBOutlet fileprivate weak var btnDone: HighlightedButton!
    @IBOutlet fileprivate weak var barItemAdd: UIBarButtonItem!
    @IBOutlet var barItemClear: UIBarButtonItem!
    
    @IBOutlet fileprivate weak var toolBar: UIToolbar!
    @IBOutlet fileprivate weak var addItemViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var barItemReceipt: UIBarButtonItem!
    @IBOutlet weak var constraintTopHeader: NSLayoutConstraint!
    
    @IBOutlet var doneBtnHeight: NSLayoutConstraint!
    @IBOutlet var addToOrderBtnHeight: NSLayoutConstraint!
    
    //Animation's properties
    var barcodeHeight = CGFloat(30)
    var stackViewHeightNormal = CGFloat(102)
    var stackViewHeightCollapsed = CGFloat(64)
    
    var order: Order?
    
    var router: NewOrderRouter?
    fileprivate var yPosition: CGFloat = 0
    
    fileprivate var services: [Service]?
    var leftVC: UIViewController?
    
    var paddingView: UIView? = nil
    var washFoldDetailComponents: OrderDetailComponents? = nil
    var menShirtDetailComponents: OrderDetailComponents? = nil
    var dryCleaningDetailComponents: OrderDetailComponents? = nil
    var viewModel: AddOrderDetailsViewModel!
    
    var departmentSelected: Service? = nil
    var departmentView: ServiceView? = nil
    var prefViews: [UIView] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = AddOrderDetailsViewModel(order: order, delegate:self)
        viewModel.orderDetailToAdd.observeNext { [weak self] orderDetail in
            guard let strongSelf = self else { return }
            for view in strongSelf.cardView.subviews {
                view.removeFromSuperview()
            }
            
            if orderDetail == nil {
                strongSelf.setupCardEmpty()
            } else {
                strongSelf.setupGarmentCard(orderDetail!)
            }
        }
        
        makeConstraintUnderSafeAreaIfIsIphoneX(constraint: doneBtnHeight, baseValue: 60)
        makeButtonBottomContentInsetIfIsIphoneX(button: btnDone)
        
        makeConstraintUnderSafeAreaIfIsIphoneX(constraint: addToOrderBtnHeight, baseValue: 60)
        makeButtonBottomContentInsetIfIsIphoneX(button: btnAddToOrder)
        
        //binding
        viewModel.totalPrice.map{ String(format: "Total: $%.2f", $0)}.bind(to: btnTotal.bnd_title)
        viewModel.paymentStatusImage.observeNext {[weak self] img in
            self?.btnTotal.setImage(img, for: UIControlState() )
        }
        viewModel.paymentStatusColor.bind(to: btnTotal.bnd_backgroundColor)
        
        viewModel.hiddenDoneBtn.bind(to: btnDone.bnd_hidden)
        viewModel.hiddenDoneBtn.observeNext { [weak self] isHidden in
            guard let strongSelf = self else { return }
            if !isHidden {
                if strongSelf.toolBar.items?.count == 5 {
                    strongSelf.toolBar.items?.remove(at: 0)
                }
            } else {
                if strongSelf.toolBar.items?.count == 4 {
                    strongSelf.toolBar.items?.insert(strongSelf.barItemClear, at: 0)
                }
            }
        }
        
        btnUndo.bnd_tap.observeNext { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.viewModel.undoLastOrderDetail()
        }

        viewModel.isBusy.bind(to: activityLoading.bnd_animating)
        initBarcodeTextField(self.tfBarcode)

        self.scrollView.isUserInteractionEnabled = true
        self.scrollView.isExclusiveTouch = true
        self.scrollView.canCancelContentTouches = true
        self.scrollView.delaysContentTouches = true

        let bellButton = UIButton(type: .custom)
        bellButton.setBackgroundImage(UIImage(named:"ic_receipt"), for: UIControlState())
        bellButton.addTarget(self, action: #selector(AddOrderDetailsViewController.didReceiptButtonClicked(_:)), for: .touchUpInside)
        bellButton.frame = CGRect(x: 0, y: 0, width: 18, height: 20)
        let notificationBarButton = UIBarButtonItem(customView: bellButton)
        self.navigationItem.rightBarButtonItem = notificationBarButton
        
        viewModel.numberOfOrderDetails.observeNext { [weak self] number in
            guard let strongSelf = self else { return }
            
            let rightBarButtons = strongSelf.navigationItem.rightBarButtonItems
            let lastBarButton = rightBarButtons?.last
            lastBarButton?.addBadge(number: number, withOffset: CGPoint(x: -8, y: -6))
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.getOrder()
        dissbleSwipeMenu()
        //clearAll()
        
        getDepartments()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        enableSwipeMenu()
        viewModel.updateOrders()
    }
    
    //MARK: - create UI sections
    func getDepartments() {
        addViewToScrollView(initPaddingView())
        _ = LemonAPI.getDepartmentsAll().request().observeNext { [weak self] (result: EventResolver<[Service]>) in
            do {
                guard let strongSelf = self else { return }
                let services = try result()
                strongSelf.services = services.filter{ $0.active }
                
                strongSelf.checkCurrentSelection(strongSelf.services!)
                
            } catch { }
        }
    }
    
    func checkCurrentSelection(_ services: [Service]) {
        guard let services = self.services else { return }
        //guard let departmentSelected = self.departmentSelected else { return }
        
        if let orderDetail = viewModel.orderDetailToAdd.value {
            let departmentPos = services.index(where: { $0.id == orderDetail.service?.id})
            guard let position = departmentPos else { return }
            
            services[position].isSelected = true
            updateDepartmentsView(services)
            updateSelectedDepartment(position: position, isSelected: true)
        }
        else {
            clearAll()
            
            if let view = self.initDepartments(services) {
                self.addViewToScrollView(view)
            }
        }
        
    }
    
    func updateDepartmentsView(_ services: [Service]) {
        
        guard let departmentView = self.departmentView else { return }
        
        var serviceItems: [ServiceItem] = []
        services.forEach {
            serviceItems.append(ServiceItem(title: $0.name, image: ProductHelper.getImageReceiptNameNormalBy($0.id), selectedImage: ProductHelper.getImageReceiptNameSelectedBy($0.id), isSelected: $0.isSelected, service: $0))
            updateServicesPrefs($0.typesOfService, serviceCategory: $0, title: $0.name)
        }
        departmentView.updateView(items: serviceItems, lineCount: 1, isRoundButtons: true, isLabelVisible: true, canChangeVisibility: false, isMultiSelect: false)
        
    }

    fileprivate func initPaddingView() -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: scrollView.frame.width, height: CGFloat(8)))
        view.backgroundColor = UIColor.clear
        return view
    }

    fileprivate func initDepartments(_ services: [Service]) -> ServiceView? {
        prefViews = []
        
        var serviceItems: [ServiceItem] = []
        services.forEach {
            serviceItems.append(ServiceItem(title: $0.name, image: ProductHelper.getImageReceiptNameNormalBy($0.id), selectedImage: ProductHelper.getImageReceiptNameSelectedBy($0.id), isSelected: $0.isSelected, service: $0))
            let view = initServicesPrefs($0.typesOfService, serviceCategory: $0, title: $0.name)
            prefViews.append(view)
        }
        
        if self.departmentView != nil {
           self.departmentView?.removeFromSuperview()
            self.departmentView = nil
        }
        
        self.departmentView = ServiceView(items: serviceItems, lineCount: 1, isRoundButtons: true, isLabelVisible: true, canChangeVisibility: false, isMultiSelect: false)
        guard let departmentView = self.departmentView else {return nil}
        departmentView.lblTitle.text = "DEPARTMENTS"
        
        var prefView: UIView?
        var yPos: CGFloat?
        
        departmentView.onHoldAndEdit = {[weak self] service in
            self?.router?.showEditServiceCategoryFlow(self!, departmentToEdit: service)
        }
        
        departmentView.onSelectClosure = { [weak self] position, isSelected in
            guard let strongSelf = self else { return }
            
            if let prefV = prefView {
                if let prefSV = prefV as? ServiceView {
                    prefSV.onHiddenAll?()
                }
            }
            prefView?.removeFromSuperview()
            guard let departmentView = strongSelf.departmentView else {return}
            
            if (departmentView.items.array.filter { $0.isSelected }.count) <= 0 {
                strongSelf.viewModel.removeOrderDetail()
                strongSelf.showCodebar()
            } else {
                strongSelf.hiddenCodebar()
                
                let auxDepSelected = strongSelf.services?[position]
                if let departmentSelected = strongSelf.departmentSelected, let auxDepSelected = auxDepSelected {
                    if auxDepSelected.id != departmentSelected.id {
                        strongSelf.viewModel.removeOrderDetail()
                        strongSelf.resetDepartmentViews()
                        //self.setCurrentYPositionBelowDepartmentsView()
                    }
                }
                strongSelf.departmentSelected = auxDepSelected
                guard let departmentSelected = strongSelf.departmentSelected else { return }
                
                if departmentSelected.id == 1 {
                    strongSelf.viewModel.addDepartmentWashFoldToOrderDetail(departmentSelected)
                } else {
                    strongSelf.viewModel.addDepartmentToOrderDetail(departmentSelected)
                }
                
                prefView = strongSelf.prefViews[position]
                
                if yPos == nil {
                    yPos = strongSelf.yPosition
                    strongSelf.addViewToScrollView(prefView!)
                } else {
                    strongSelf.addViewToScrollView(prefView!, yPos: yPos)
                }
            }
        }
        
        return departmentView
    }
    func updateSelectedDepartment(position: Int, isSelected: Bool) {
        
        /*
        if let prefV = prefView {
            if let prefSV = prefV as? ServiceView {
                prefSV.onHiddenAll?()
            }
        }
        prefView?.removeFromSuperview()
 */
        guard let departmentView = self.departmentView else {return}
        
        if (departmentView.items.array.filter { $0.isSelected }.count) <= 0 {
            self.viewModel.removeOrderDetail()
            self.showCodebar()
        } else {
            self.hiddenCodebar()
            self.departmentSelected = services?[position]
            guard let departmentSelected = self.departmentSelected else { return }
            
            if departmentSelected.id == 1 {
                self.viewModel.updateDepartmentWashFoldToOrderDetail(departmentSelected)
            } else {
                self.viewModel.updateDepartmentToOrderDetail(departmentSelected)
            }
            
            //prefView = prefViews[position]
        }
    }
    
    fileprivate func initServicesPrefs(_ typesOfService: [Service]?, serviceCategory: Service, title: String) -> UIView {
        guard let viewModel = self.viewModel else { return UIView() }

        
        switch serviceCategory.id {
        case 1:
            let orderDetailWashFoldVM = OrderDetailWashFoldComponentViewModel(order: viewModel.order!, delegate: viewModel)
            washFoldDetailComponents = OrderDetailWashFoldComponent(viewModel: orderDetailWashFoldVM, scrollDelegate: self, routerDelegate: self, onTextFieldFocus: { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.constraintTopHeader.constant = (strongSelf.stackViewHeightConstraint.constant / 2) * -1
                }, onTextFieldLostFocus: { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.constraintTopHeader.constant = 8
            })
            return washFoldDetailComponents!.initServiceView(typesOfService, serviceCategory: serviceCategory, title: title)
        case 2:
            let orderDetailDryCleaningVM = OrderDetailDryCleaningComponentViewModel(order: viewModel.order!, delegate: viewModel)
            dryCleaningDetailComponents = OrderDetailDryCleaningComponent(viewModel: orderDetailDryCleaningVM, scrollDelegate: self, routerDelegate: self, onTextFieldFocus: { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.constraintTopHeader.constant = (strongSelf.stackViewHeightConstraint.constant / 2) * -1
                }, onTextFieldLostFocus: { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.constraintTopHeader.constant = 8
                })
            return dryCleaningDetailComponents!.initServiceView(typesOfService, serviceCategory: serviceCategory, title: title)
        case 3:
            let orderDetailMenShirtVM = OrderDetailMenShirtComponentViewModel(order: viewModel.order!, delegate: viewModel)
            menShirtDetailComponents = OrderDetailMenShirtComponent(viewModel: orderDetailMenShirtVM, scrollDelegate: self, routerDelegate: self, onTextFieldFocus: { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.constraintTopHeader.constant = (strongSelf.stackViewHeightConstraint.constant / 2) * -1
                }, onTextFieldLostFocus: { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.constraintTopHeader.constant = 8
                })
            return menShirtDetailComponents!.initServiceView(typesOfService, serviceCategory: serviceCategory, title: title)
        default:
            return UIView()
        }
    }
    
    fileprivate func updateServicesPrefs(_ typesOfService: [Service]?, serviceCategory: Service, title: String){
        
        switch serviceCategory.id {
        case 1:
            washFoldDetailComponents!.updateServiceView(typesOfService, serviceCategory: serviceCategory, title: title)
        case 2:
             dryCleaningDetailComponents!.updateServiceView(typesOfService, serviceCategory: serviceCategory, title: title)
        case 3:
            menShirtDetailComponents!.updateServiceView(typesOfService, serviceCategory: serviceCategory, title: title)
        default:
            //print("")
            return
        }
    }
    
    //MARK: - Components Views Functions
    
    fileprivate func resetAllViews() {
        if paddingView != nil {
            paddingView!.removeFromSuperview()
            paddingView = nil
        }
        
        if let washFoldDetailComponents = washFoldDetailComponents {
            washFoldDetailComponents.resetAllViews()
        }
        
        if let menShirtDetailComponents = menShirtDetailComponents {
            menShirtDetailComponents.resetAllViews()
        }
        
        if let dryCleaningDetailComponents = dryCleaningDetailComponents {
            dryCleaningDetailComponents.resetAllViews()
        }
        
        departmentSelected = nil
        
        if departmentView != nil {
            departmentView!.removeFromSuperview()
            departmentView = nil
        }
        
        
        prefViews.forEach{
            $0.removeFromSuperview()
        }
        prefViews = []
        
        yPosition = 0
    }
    
    fileprivate func resetDepartmentViews() {
        
        if let washFoldDetailComponents = washFoldDetailComponents {
            washFoldDetailComponents.resetAllViews()
        }
        
        if let menShirtDetailComponents = menShirtDetailComponents {
            menShirtDetailComponents.resetAllViews()
        }
        
        if let dryCleaningDetailComponents = dryCleaningDetailComponents {
            dryCleaningDetailComponents.resetAllViews()
        }
        
        /*
        departmentSelected = nil
        
        if departmentView != nil {
            departmentView!.removeFromSuperview()
            departmentView = nil
        }*/
        
    }

    //MARK: Barcode methods
    fileprivate func initBarcodeTextField(_ tfBarcode: UITextField) {
        //Barcode image with padding
        tfBarcode.leftViewMode = UITextFieldViewMode.always
        let barcodeImgPadding: CGFloat = 8
        let barcodeImg = UIImageView(image: UIImage(named: "ic_barcode"))
        let barcodeView = UIView(frame: CGRect(x: 0, y: 0, width: barcodeImg.frame.width + barcodeImgPadding, height: barcodeImg.frame.height))
        barcodeImg.frame = CGRect(x: 0 + barcodeImgPadding, y: 0, width: barcodeImg.frame.width, height: barcodeImg.frame.height)
        barcodeView.addSubview(barcodeImg)
        tfBarcode.leftView = barcodeView
        
        //Keyboard's toolbar
        let keyboardToolbar = UIToolbar()
        keyboardToolbar.sizeToFit()
        let cancelBarButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(AddOrderDetailsViewController.didBarcodeCancelPressed(_:)))
        let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(AddOrderDetailsViewController.didBarcodeDonePressed(_:)))
        doneBarButton.tintColor = UIColor.black
        keyboardToolbar.items = [cancelBarButton, flexBarButton, doneBarButton]
        tfBarcode.inputAccessoryView = keyboardToolbar
        
        tfBarcode.delegate = self
    }
    
    
    @objc func didBarcodeDonePressed(_ sender: AnyObject?) {
        self.tfBarcode.resignFirstResponder()
        if let barcode = tfBarcode.text {
            _ = LemonAPI.getGarmentByBarcode(barcode: barcode).request().observeNext { (_: EventResolver<String>) in }
        }
        //TODO: Implement
    }
    
    @objc func didBarcodeCancelPressed(_ sender: AnyObject?) {
        self.tfBarcode.resignFirstResponder()
    }
    
    @IBAction func didClearToolbarButtonPressed(_ sender: AnyObject) {
        resetUI()
    }
    
    fileprivate func resetUI() {
        clearAllAndRemoveOrderDetail()
        services?.forEach { department in
            department.isSelected = false
            department.typesOfService?.forEach { service in
                service.isSelected = false
            }
        }
        addViewToScrollView(initDepartments(services!)!)
    }
    
    //MARK: General methods
    fileprivate func clearAllAndRemoveOrderDetail() {
        resetAllViews()
        
        viewModel.removeOrderDetail()
        showCodebar()
        clearScrollView()
    }
    fileprivate func clearAll() {
        resetAllViews()
        
        showCodebar()
        clearScrollView()
    }
    
    fileprivate func clearScrollView() {
        scrollView.subviews.forEach { $0.removeFromSuperview() }
        yPosition = 0
    }
    
    @IBAction func didAddToolbarButtonPressed(_ sender: AnyObject) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { _ in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(cancel)
        let newAttributeCategory = UIAlertAction(title: "New Attribute Category", style: UIAlertActionStyle.default) { [weak self] _ in
            alert.dismiss(animated: true, completion: nil)
            self?.didNewAttributeCategoryItemPressed()
        }
        alert.addAction(newAttributeCategory)
        present(alert, animated: true, completion: nil)
    }
    
    fileprivate func didNewAttributeCategoryItemPressed() {
        router?.showNewAttributeCategoryFlow(self)
    }
    
    @IBAction func didAddToOrderButtonPressed(_ sender: AnyObject) {
        viewModel.onAddToOrder()
    }
    
    @IBAction func didDoneButtonPressed(_ sender: AnyObject) {
        router?.showOrderReceiptFlow(self, order: self.viewModel.order!)
    }
    
    @objc func didReceiptButtonClicked(_ sender: AnyObject?) {
        router?.showOrderReceiptFlow(self, order: self.viewModel.order!)
    }
    
    //MARK: Garment Card UI
    fileprivate func setupCardEmpty() {
        self.viewModel.cardEmpty.translatesAutoresizingMaskIntoConstraints = false
        self.cardView.addSubview(self.viewModel.cardEmpty)
        applyConstraints(self.viewModel.cardEmpty, view2: self.cardView)
    }
    
    fileprivate func setupGarmentCard(_ orderDetail: OrderDetail) {
        self.viewModel.garmentCardVM = GarmentCardViewModel(orderDetail: orderDetail, order: self.viewModel.order!)
        self.viewModel.cardDetail = GarmentCardView(viewModel: self.viewModel.garmentCardVM!, withRadius: true)
        self.viewModel.cardDetail!.translatesAutoresizingMaskIntoConstraints = false
        self.cardView.addSubview(self.viewModel.cardDetail!)
        applyConstraints(self.viewModel.cardDetail!, view2: self.cardView)
        self.stackViewHeightConstraint.constant = self.addItemViewHeightConstraint.constant
    }
    
    fileprivate func applyConstraints(_ view1: UIView, view2:UIView) {
        self.addItemViewHeightConstraint.constant = view1.frame.height        
        let constraintWidth = NSLayoutConstraint(item: view1, attribute: .width, relatedBy: .equal, toItem: view2, attribute: .width, multiplier: 1.0, constant: 0)
        let constraintHeight = NSLayoutConstraint(item: view1, attribute: .height, relatedBy: .equal, toItem: view2, attribute: .height, multiplier: 1.0, constant: 0)
        let xConstraint = NSLayoutConstraint(item: view1, attribute: .centerX, relatedBy: .equal, toItem: view2, attribute: .centerX, multiplier: 1.0, constant: 0)
        let yConstraint = NSLayoutConstraint(item: view1, attribute: .centerY, relatedBy: .equal, toItem: view2, attribute: .centerY, multiplier: 1.0, constant: 0)
        NSLayoutConstraint.activate([constraintWidth, constraintHeight, xConstraint, yConstraint])
    }
    
    //MARK: - Swipe Menu
    fileprivate func dissbleSwipeMenu() {
        if let currentVS = self.evo_drawerController?.leftDrawerViewController {
            leftVC = currentVS
            self.evo_drawerController?.leftDrawerViewController = nil
        }
    }
    
    fileprivate func enableSwipeMenu() {
        self.evo_drawerController?.leftDrawerViewController = leftVC
    }
    
    //MARK: Animations
    fileprivate func hiddenCodebar() {
        guard tfBarcode.isHidden == false else { return }
        
        self.stackViewHeightConstraint.constant = self.stackViewHeightCollapsed
        self.barcodeHeightConstraint.constant = 0
        UIView.animate(withDuration: 0.4,
                                   animations: {
                self.tfBarcode.alpha = 0.3
                self.stackViewHeader.spacing = 0
                self.view.layoutIfNeeded()
            }, completion: { [weak self]finished in
                guard let strongSelf = self else { return }
                if finished {
                    strongSelf.tfBarcode.isHidden = true
                }
        })
    }
    
    fileprivate func showCodebar() {
        guard tfBarcode.isHidden == true else { return }
        
        tfBarcode.alpha = 0
        tfBarcode.isHidden = false
        self.stackViewHeightConstraint.constant = self.stackViewHeightNormal
        self.barcodeHeightConstraint.constant = self.barcodeHeight
        UIView.animate(withDuration: 0.4,
                                   animations: {
                self.tfBarcode.alpha = 1
                self.stackViewHeader.spacing = 8
                self.view.layoutIfNeeded()
            })
    }
}

extension AddOrderDetailsViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.didBarcodeDonePressed(nil)
        return false
    }
}

extension AddOrderDetailsViewController: AddOrderViewModelDelegate {
    
    func clearScreen(_ withSuccess: Bool) {
        btnDone.setTitle("Order Complete")
        resetUI()
        showFeedback()
    }
    
    fileprivate func showFeedback() {
        constraintYPositionFeedbackView.constant = 0
        UIView.animate(withDuration: 0.6,
               animations: {
                    self.viewFeedback.alpha = 1.0
                 self.view.layoutIfNeeded()
        })
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(3.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) { () -> Void in
            self.hideFeedback()
        }
    }
    
    fileprivate func hideFeedback() {
        viewModel.confirmOrderDetailAdded()
        constraintYPositionFeedbackView.constant = -50
        UIView.animate(withDuration: 0.6,
                                   animations: {
                                    self.viewFeedback.alpha = 0
                                    self.view.layoutIfNeeded()
        })
    }
    
    func showModal(_ alert: UIAlertController) {
        showAlert(alert)
    }
}

extension AddOrderDetailsViewController: ScrollDelegate {
    func changeContentSize(_ newContentSize: CGSize) {
        scrollView.contentSize = newContentSize
    }
    
    func getContentSize() -> CGSize {
        return scrollView.contentSize
    }
    
    func changeYPosition(_ newYPosition: CGFloat) {
        yPosition = newYPosition
    }
    
    func getYPosition() -> CGFloat {
        return yPosition
    }
    
    func scrollTo(_ position: CGFloat) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions.curveLinear, animations: {
                self.scrollView.contentOffset.y = position
                }, completion: nil)
        }
    }
    
    func getContentOffset() -> CGPoint {
        return scrollView.contentOffset
    }
    
    func changeContentOffset(_ newContentOffset: CGPoint) {
        scrollView.contentOffset = newContentOffset
    }
    
    func addViewToScrollView(_ view: UIView, yPos: CGFloat? = nil) {
        let y = yPos ?? self.yPosition
        let rect = CGRect(x: 0, y: y, width: self.view.bounds.width, height: view.bounds.height)
        view.frame = rect
        view.isUserInteractionEnabled = true
        scrollView.addSubview(view)
        if yPos == nil {
            yPosition += view.bounds.height
            scrollView.contentSize = CGSize(width: self.view.bounds.width, height: yPosition)
        }
    }
    
    func setCurrentYPositionBelowDepartmentsView() {
        if let departmentView = self.departmentView {
            yPosition = departmentView.bounds.height
        }
        else {
            yPosition = 0
        }
        scrollView.contentSize = CGSize(width: self.view.bounds.width, height: yPosition)
    }
    
    func showAlert(_ alertView:UIAlertController) {
        present(alertView, animated: true, completion: nil)
    }
}

extension AddOrderDetailsViewController: ComponentsRouterDelegate {
    func showEditServiceFlow(_ serviceToEdit: Service, serviceCategory: Service) {
        router?.showEditServiceFlow(self, serviceToEdit: serviceToEdit, serviceCategory: serviceCategory)
    }
    
    func showEditAttributeCategoryFlow(_ attributeCategoryToEdit: Category) {
        router?.showEditAttributeCategoryFlow(self, attributeCategoryToEdit: attributeCategoryToEdit)
    }
    
    func showNewAttributeFlow(_ attributeCategory: Category) {
        router?.showNewAttributeFlow(self, attributeCategory: attributeCategory)
    }
    
    func showEditAttributeFlow(_ attributeToEdit: Attribute) {
        router?.showEditAttributeFlow(self, attributeToEdit: attributeToEdit)
    }
}
