//
//  OptionsViewController.swift
//  TestDemoApp
//
//  Created by aniket ayachit on 30/04/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import UIKit
import OstWalletSdk
import LocalAuthentication

class OptionsViewController: OstBaseViewController, UITableViewDelegate, UITableViewDataSource, OstFlowCompleteDelegate, OstFlowInterruptedDelegate, OstRequestAcknowledgedDelegate {
    
    //MAKR: - Components
    var tableView: UITableView?
    var tableHeaderView: UsersTableViewCell = {
        let view = UsersTableViewCell()
        
        view.sendButton?.isHidden = true
        view.sendButton?.setTitle("", for: .normal)
        //        view.translatesAutoresizingMaskIntoConstraints = false
        view.seperatorLine?.isHidden = true
        view.backgroundColor = UIColor.color(239, 249, 250)
        view.layer.cornerRadius = 6
        view.clipsToBounds = true
        
        return view
    }()
    
    //MARK: - Variables
    var generalOptions = [OptionVM]()
    var deviceOptions = [OptionVM]()
    
    weak var tabbarController: TabBarViewController?
    
    //MAKR: - View LC
    
    override func getNavBarTitle() -> String {
        return "Wallet Settings"
    }
    
    override func getTargetForNavBarBackbutton() -> AnyObject? {
        return nil
    }
    
    override func getSelectorForNavBarBackbutton() -> Selector? {
        return nil
    }
    
    //MAKR: - View LC
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupTableViewModels()
        self.tabbarController?.showTabBar()
        
        setupTableHeaderView()
    }
    
    @objc override func tappedBackButton() {
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: - Create Views
    
    override func addSubviews() {
        setupNavigationBar()
        setupTableHeaderView()
        createTabelView()
    }
    
    func setupTableHeaderView() {
        let userData = ["username": CurrentUserModel.getInstance.userName ?? ""]
        tableHeaderView.userData = userData
        tableHeaderView.balanceLabel?.text =  CurrentUserModel.getInstance.ostUserId ?? ""
    }
    
    func createTabelView() {
        let loTableView = UITableView(frame: .zero, style: .plain)
        loTableView.delegate = self
        loTableView.dataSource = self
        loTableView.separatorStyle = .none
        loTableView.rowHeight = UITableView.automaticDimension
        loTableView.estimatedRowHeight = 100
        loTableView.translatesAutoresizingMaskIntoConstraints = false
        loTableView.tableHeaderView = tableHeaderView
        loTableView.tableHeaderView?.frame.size = CGSize(width: loTableView.frame.width, height: CGFloat(77))
        
        tableView = loTableView
        self.view.addSubview(loTableView)
        
        registerCell()
    }
    
    func registerCell() {
        tableView?.register(OptionTableViewCell.self, forCellReuseIdentifier: OptionTableViewCell.cellIdentifier)
    }
    
    //MAKR: - Apply Constraints
    override func addLayoutConstraints() {
        applyTableViewConstraints()
    }
    
    func applyTableViewConstraints() {
        tableView?.topAlignWithParent()
        tableView?.leftAlignWithParent()
        tableView?.rightAlignWithParent()
        tableView?.bottomAlignWithParent()
    }
    
    //MARK: - Table View Delegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return generalOptions.count
        case 1:
            return deviceOptions.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: OptionTableViewCell = tableView.dequeueReusableCell(withIdentifier: OptionTableViewCell.cellIdentifier, for: indexPath) as! OptionTableViewCell
        
        let option: OptionVM
        switch indexPath.section {
        case 0:
            option = generalOptions[indexPath.row]
        case 1:
            option = deviceOptions[indexPath.row]
        default:
            fatalError()
        }
        cell.option = option
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionTitle = UILabel()
        sectionTitle.numberOfLines = 1
        sectionTitle.textColor = UIColor.color(22, 141, 193)
        sectionTitle.translatesAutoresizingMaskIntoConstraints = false
        sectionTitle.font = UIFont(name: "Lato", size: 13)?.bold()
        switch section {
        case 0:
            sectionTitle.text = "GENERAL"
        case 1:
            sectionTitle.text = "DEVICE"
        default:
            sectionTitle.text = ""
        }
        
        let container = UIView()
        container.backgroundColor = .white
        container.addSubview(sectionTitle)
        
        sectionTitle.topAlignWithParent(multiplier: 1, constant: 20)
        sectionTitle.leftAlignWithParent(multiplier: 1, constant: 20)
        sectionTitle.rightAlignWithParent(multiplier: 1, constant: 20)
        sectionTitle.bottomAlignWithParent()
        
        return container
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell: OptionTableViewCell = tableView.cellForRow(at: indexPath) as! OptionTableViewCell
        
        processSelectedOption(cell.option)
        
    }
    
    func setupTableViewModels() {
        createGeneralOptionsArray()
        createDeviceOptionsArray()
        tableView?.reloadData()
    }
    
    func createGeneralOptionsArray() {
        let currentUser = CurrentUserModel.getInstance;
        guard let userDevice = currentUser.currentDevice else {
            BaseAPI.logoutUnauthorizedUser()
            return
        }
        
        let optionDetail = OptionVM(type: .details, name: "View Wallet Details", isEnable: true)
        
        var optionSession = OptionVM(type: .createSession, name: "Add Session", isEnable: true)
        if !userDevice.isStatusAuthorized {
            optionSession.isEnable = false
        }
        
        let optionResetPin = OptionVM(type: .resetPin, name: "Reset PIN", isEnable: true)
        
        var optionMnemonics = OptionVM(type: .viewMnemonics, name: "View Mnemonics", isEnable: true)
        if !(currentUser.ostUser?.isStatusActivated ?? false){
            optionMnemonics.isEnable = false
        }
        
        let userOptions = [optionDetail, optionSession, optionResetPin, optionMnemonics]
        generalOptions = userOptions
    }
    
    func createDeviceOptionsArray() {
        let currentUser = CurrentUserModel.getInstance
        let userDevice = currentUser.currentDevice
        
        var authorizeViaQR = OptionVM(type: .authorizeViaQR, name: "Authorize Additional Device via QR", isEnable: true)
        if  nil == userDevice || !userDevice!.isStatusAuthorized {
            authorizeViaQR.isEnable = false
        }
        
        var authorizeViaMnemonics = OptionVM(type: .authorizeViaMnemonics, name: "Authorize This Device via Mnemonics", isEnable: true)
        if  nil == userDevice || !userDevice!.isStatusRegistered {
            authorizeViaMnemonics.isEnable = false
        }
        
        let biometricStatus = OstWalletSdk.isBiometricEnabled(userId: currentUser.ostUserId!) ? "Disable" : "Enable"
        var optionBiomertic = OptionVM(type: .biomerticStatus, name: "\(biometricStatus) Biomertic Authentication", isEnable: true)
        let canDeviceEvaluatePolicy: Bool = LAContext().canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        if !canDeviceEvaluatePolicy {
            optionBiomertic.isEnable = false
        }
        
        var showDeviceQR = OptionVM(type: .showDeviceQR, name: "Show Device QR", isEnable: true)
        if  nil == userDevice || !userDevice!.isStatusRegistered {
            showDeviceQR.isEnable = false
        }
        
        let manageDevices = OptionVM(type: .manageDevices, name: "Manage Devices", isEnable: true)
        
        var transactionViaQR = OptionVM(type: .transactionViaQR, name: "Transaction via QR", isEnable: true)
        if nil == userDevice || !userDevice!.isStatusAuthorized {
            transactionViaQR.isEnable = false
        }
        
        var initialRecovery = OptionVM(type: .initiateDeviceRecovery, name: "Initiate Recovery", isEnable: true)
        if currentUser.isCurrentDeviceStatusAuthrozied || currentUser.isCurrentDeviceStatusAuthrozied {
            initialRecovery.isEnable = false
        }
        
        var abortRecovery = OptionVM(type: .abortRecovery, name: "Abort Recovery", isEnable: true)
        if nil == userDevice || userDevice!.isStatusRevoked {
            abortRecovery.isEnable = false
        }
        
        let logoutAllSession = OptionVM(type: .logoutAllSessions, name: "Logout", isEnable: true)
        
        
        let dOptions = [authorizeViaQR, authorizeViaMnemonics, optionBiomertic, showDeviceQR, manageDevices,
                        transactionViaQR, initialRecovery, abortRecovery, logoutAllSession]
        
        deviceOptions = dOptions
    }
    
    
    func processSelectedOption(_ option: OptionVM) {
        
        if option.type == .logoutAllSessions {
            showLogoutOptions()
            return
        }
        
        if CurrentUserModel.getInstance.isCurrentDeviceStatusAuthorizing {
            showDeviceIsAuthroizingAlert()
            return
        }
        
        if CurrentUserModel.getInstance.isCurrentDeviceStatusRegistered {
            
        }
        
        var destinationSVVC: BaseSettingOptionsSVViewController? = nil
        var destinationVC: BaseSettingOptionsViewController? = nil
        
        if option.type == .details {
            destinationVC = UserDetailsViewController()
        }
            
        else if option.type == .viewMnemonics {
            destinationSVVC = DeviceMnemonicsViewController()
        }
            
        else if option.type == .authorizeViaMnemonics {
            if option.isEnable {
                destinationSVVC = AuthorizeDeviceViaMnemonicsViewController()
            }else {
                showInfoAlert(title: "Device is already authorized. You can use this function to authorize your new device.")
            }
        }
            
        else if option.type == .showDeviceQR {
            if option.isEnable {
                destinationVC = ShowQRCodeViewController()
            }else {
                showInfoAlert(title: "Device is already authorized. You can use this function to authorize your new device.")
            }
        }
            
        else if option.type == .authorizeViaQR {
            if option.isEnable {
                destinationVC = AuthorizeDeviceQRScanner()
            }else {
                showInfoAlert(title: "Device is not authorized. Authorize your device to use this function.")
            }
        }
            
        else if option.type == .transactionViaQR {
            if option.isEnable {
                destinationVC = TransactionQRScanner()
                (destinationVC as! TransactionQRScanner).tabBarVC = self.tabbarController
            }else {
                showInfoAlert(title: "Device is not authorized. Authorize your device to use this function.")
            }
        }
            
        else if option.type == .createSession {
            if option.isEnable {
                destinationSVVC = CreateSessionViewController()
            }else {
                showInfoAlert(title: "Device is not authorized. Authorize your device to use this function.")
            }
        }
            
        else if  option.type  == .manageDevices {
            destinationVC = ManageDeviceViewController()
        }
            
        else if option.type == .initiateDeviceRecovery {
            if option.isEnable {
                destinationVC = InitiateDeviceRecoveryViewController()
            }else {
                showInfoAlert(title: "Device is already authorized. You can use this function to authorize your new device.")
            }
        }
            
        else if option.type == .resetPin {
            _ = OstSdkInteract.getInstance.resetPin(userId: CurrentUserModel.getInstance.ostUserId!,
                                                    passphrasePrefixDelegate: CurrentUserModel.getInstance,
                                                    presenter: self)
            self.tabbarController?.hideTabBar()
            
        }
            
        else if option.type == .abortRecovery {
            _ = OstSdkInteract.getInstance.abortDeviceRecovery(userId: CurrentUserModel.getInstance.ostUserId!,
                                                               passphrasePrefixDelegate: CurrentUserModel.getInstance,
                                                               presenter: self)
            self.tabbarController?.hideTabBar()
            
        }
            
        else if option.type == .biomerticStatus {
            if option.isEnable {
                let workflowDelegate = OstSdkInteract.getInstance.getWorkflowCallback(forUserId: CurrentUserModel.getInstance.ostUserId!)
                OstSdkInteract.getInstance.subscribe(forWorkflowId: workflowDelegate.workflowId,
                                                     listner: self)
                
                let isEnabled = OstWalletSdk.isBiometricEnabled(userId: CurrentUserModel.getInstance.ostUserId!)
                OstWalletSdk.updateBiometricPreference(userId: CurrentUserModel.getInstance.ostUserId!,
                                                       enable: !isEnabled,
                                                       delegate: workflowDelegate)
                
            }else {
                showInfoAlert(title: "Biometric is not enrolled/activated for this device. Please enroll/activate biometric to use feature.",
                              actionButtonTitle: "Open Settings") { (_) in
                          
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                }
            }
        }
        
        if nil == destinationVC && nil == destinationSVVC {
            return
        }
        
        self.tabbarController?.hideTabBar()
        
        let viewController: OstBaseViewController = destinationSVVC == nil ? destinationVC! : destinationSVVC!
        
        if nil == self.navigationController {
            let navC = UINavigationController(rootViewController: viewController )
            self.present(navC, animated: true, completion: nil)
        }else {
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    func openAuthorizeDeviceViewIfRequired() {
        if CurrentUserModel.getInstance.isCurrentDeviceStatusRegistered {
            if let currentUser = CurrentUserModel.getInstance.ostUser {
                if currentUser.isStatusActivated {
                    let authorizeDeviceVC = AuthorizeDeviceViewController()
                    authorizeDeviceVC.pushViewControllerOn(self)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.tabbarController?.hideTabBar()
                    }
                }
            }
        }
    }
    
    //MARK: - OstSdkInteract Delegate
    
    func flowComplete(workflowId: String, workflowContext: OstWorkflowContext, contextEntity: OstContextEntity) {
        if workflowContext.workflowType == .setupDevice
            || workflowContext.workflowType == .updateBiometricPreference {
            setupTableViewModels()
        }
    }
    
    func flowInterrupted(workflowId: String, workflowContext: OstWorkflowContext, error: OstError) {
        if workflowContext.workflowType == .logoutAllSessions {
            
        }
    }
    
    func requestAcknowledged(workflowId: String, workflowContext: OstWorkflowContext, contextEntity: OstContextEntity) {
        if workflowContext.workflowType == .logoutAllSessions {
            
        }
    }
    
    func showLogoutOptions() {
        
        let alert: UIAlertController
        if CurrentUserModel.getInstance.isCurrentDeviceStatusAuthorizing {
            
            alert = UIAlertController(title: "Logout from Application",
                                      message: "As device is in authorizing state, you cannot logout from wallet.", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Logout", style: .default, handler: { (alertAction) in
                CurrentUserModel.getInstance.logout()
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.showIntroController()
            }))
            
        }else {
            
            alert = UIAlertController(title: "Sure you want to logout?", message: nil, preferredStyle: .actionSheet)
            
            alert.addAction(UIAlertAction(title: "Logout", style: .default, handler: { (alertAction) in
                CurrentUserModel.getInstance.logout()
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.showIntroController()
            }))
            
            alert.addAction(UIAlertAction(title: "Revoke all Sessions", style: .destructive, handler: {[weak self] (alertAction) in
                self?.tabbarController?.hideTabBar()
                let callbackDelegate = OstSdkInteract.getInstance.logoutAllSessions(userId: CurrentUserModel.getInstance.ostUserId!,
                                                                                    passphrasePrefixDelegate: CurrentUserModel.getInstance,
                                                                                    presenter: self!)
                OstSdkInteract.getInstance.subscribe(forWorkflowId: callbackDelegate.workflowId,
                                                     listner: self!)
            }))
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alert.show()
    }
    
    func showInfoAlert(title: String,
                       message: String? = nil,
                       actionButtonTitle: String? = nil,
                       actionButtonTapped: ((UIAlertAction) -> Void)? = nil) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if nil != actionButtonTitle && !actionButtonTitle!.isEmpty {
            alert.addAction(UIAlertAction(title: actionButtonTitle, style: .default, handler: actionButtonTapped))
        }
        
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        alert.show()
    }
}
