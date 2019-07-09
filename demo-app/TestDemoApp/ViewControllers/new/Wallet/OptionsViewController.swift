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

class OptionsViewController: OstBaseViewController, UITableViewDelegate, UITableViewDataSource, OstFlowCompleteDelegate, OstFlowInterruptedDelegate, OstRequestAcknowledgedDelegate, OstJsonApiDelegate {

    //MAKR: - Components
    var tableView: UITableView?
    
    var tableHeaderView: UsersTableViewCell? = nil
    func getTableHeaderView() -> UsersTableViewCell {
        
        if nil != tableHeaderView {
            return tableHeaderView!
        }
        
        let view = UsersTableViewCell()
        
        view.sendButton?.isHidden = true
        view.sendButton?.setTitle("", for: .normal)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.seperatorLine?.isHidden = true
        view.backgroundColor = UIColor.color(231, 243, 248)
        view.layer.cornerRadius = 6
        view.clipsToBounds = true
        
        let userData = ["username": CurrentUserModel.getInstance.userName ?? ""]
        view.userData = userData
        view.balanceLabel?.text =  CurrentUserModel.getInstance.ostUserId ?? ""
        view.sendButton?.isHidden = true
        
        tableHeaderView = view
        return view
    }
    
    func tableFooterView() -> UIView {
        let customView = UIView(frame: .zero)
        customView.backgroundColor = UIColor.clear
       
        let titleLabel = UILabel()
        titleLabel.numberOfLines = 0;
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.backgroundColor = UIColor.clear
        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColor.color(159, 159, 159)
        titleLabel.font = OstTheme.fontProvider.get(size: 14)
        titleLabel.text  = "This app version of OST Wallet is a test running on testnet, and transactions do not involve real money."
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        customView.addSubview(titleLabel)

        titleLabel.topAlignWithParent(multiplier: 1, constant: 20)
        titleLabel.leftAlignWithParent(multiplier: 1, constant: 20)
        titleLabel.rightAlignWithParent(multiplier: 1, constant: -20)
        titleLabel.bottomAlignWithParent(multiplier: 1, constant: -20)
        
        return customView
    }
    
    //MARK: - Variables
    var generalOptions = [OptionVM]()
    var deviceOptions = [OptionVM]()
    
    weak var tabbarController: TabBarViewController?
    var progressIndicator: OstProgressIndicator? = nil
    
    //MARK: - Options
    var abortRecoveryOption: OptionVM? = nil
    
    //MAKR: - View LC
    
    override func getNavBarTitle() -> String {
        return "Settings"
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
    }
    
    @objc override func tappedBackButton() {
        self.dismiss(animated: true, completion: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func registerObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.updateViewForUserActivated(_:)),
            name: NSNotification.Name(rawValue: "userActivated"),
            object: nil)
    }
    
    @objc func updateViewForUserActivated(_ notification: Notification) {
        setupTableViewModels()
    }
    
    //MARK: - Create Views
    
    override func addSubviews() {
        setupNavigationBar()
        createTabelView()
        self.view.addSubview(getTableHeaderView())
    }
    

    func createTabelView() {
        let loTableView = UITableView(frame: .zero, style: .plain)
        loTableView.delegate = self
        loTableView.dataSource = self
        loTableView.separatorStyle = .none
        loTableView.rowHeight = UITableView.automaticDimension
        loTableView.estimatedRowHeight = 100
        loTableView.translatesAutoresizingMaskIntoConstraints = false
        loTableView.tableFooterView = tableFooterView()
        loTableView.tableFooterView?.frame.size = CGSize(width: loTableView.frame.width, height: CGFloat(100))
        
        tableView = loTableView
        self.view.addSubview(loTableView)
        
        registerCell()
    }
    
    func registerCell() {
        tableView?.register(OptionTableViewCell.self, forCellReuseIdentifier: OptionTableViewCell.cellIdentifier)
    }
    
    //MAKR: - Apply Constraints
    override func addLayoutConstraints() {
        applyTableHeadreViewConstraints()
        applyTableViewConstraints()
    }
    
    func applyTableHeadreViewConstraints() {
        tableHeaderView?.topAlignWithParent()
        tableHeaderView?.leftAlignWithParent()
        tableHeaderView?.rightAlignWithParent()
        tableHeaderView?.setFixedHeight(multiplier: 1, constant: 77)
    }
    
    func applyTableViewConstraints() {
        tableView?.placeBelow(toItem: tableHeaderView!, constant: 0)
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
        guard let _ = currentUser.currentDevice else {
            BaseAPI.logoutUnauthorizedUser()
            return
        }
        
        let optionDetail = OptionVM(type: .details, name: "View Wallet Details", isEnable: true)
        
        let optionSession = OptionVM(type: .createSession, name: "Add Session", isEnable: true)
        if !currentUser.isCurrentDeviceStatusAuthrozied {
            optionSession.isEnable = false
        }
        
        let optionResetPin = OptionVM(type: .resetPin, name: "Reset PIN", isEnable: true)
        if (currentUser.isCurrentUserStatusActivating ?? true) {
            optionResetPin.isEnable = false
        }
        
        let optionMnemonics = OptionVM(type: .viewMnemonics, name: "View Mnemonics", isEnable: true)
        if !(currentUser.ostUser?.isStatusActivated ?? false)
            || (currentUser.isCurrentUserStatusActivating ?? true) {
            
            optionMnemonics.isEnable = false
        }
        
        let optionOptInForCrash: OptionVM
        if UserSetting.shared.isOptInForCrashReport() {
            optionOptInForCrash = OptionVM(type: .crashReportPreference, name: "Opt-out For Crash Report", isEnable: true)
        }else {
            optionOptInForCrash = OptionVM(type: .crashReportPreference, name: "Opt-in For Crash Report", isEnable: true)
        }
        
        let optionSupport = OptionVM(type: .contactSupport, name: "Contact Support", isEnable: true)
        
        let userOptions = [optionDetail, optionSession, optionResetPin, optionMnemonics, optionOptInForCrash, optionSupport]
        generalOptions = userOptions
    }
    
    func createDeviceOptionsArray() {
        let currentUser = CurrentUserModel.getInstance
        let userDevice = currentUser.currentDevice
        
        let authorizeViaQR = OptionVM(type: .authorizeViaQR, name: "Authorize Additional Device via QR", isEnable: true)
        if  nil == userDevice || !currentUser.isCurrentDeviceStatusAuthrozied {
            authorizeViaQR.isEnable = false
        }
        
        let authorizeViaMnemonics = OptionVM(type: .authorizeViaMnemonics, name: "Authorize This Device via Mnemonics", isEnable: true)
        if  nil == userDevice
            || !userDevice!.isStatusRegistered
            || (currentUser.isCurrentUserStatusActivating ?? true) {
            
            authorizeViaMnemonics.isEnable = false
        }
        
        let biometricStatus = OstWalletSdk.isBiometricEnabled(userId: currentUser.ostUserId!) ? "Disable" : "Enable"
        let optionBiomertic = OptionVM(type: .biomerticStatus, name: "\(biometricStatus) Biomertic Authentication", isEnable: true)
        let canDeviceEvaluatePolicy: Bool = LAContext().canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        if !canDeviceEvaluatePolicy
            || (currentUser.isCurrentUserStatusActivating ?? true) {
            
            optionBiomertic.isEnable = false
        }
        
        let showDeviceQR = OptionVM(type: .showDeviceQR, name: "Show Device QR", isEnable: true)
        if  nil == userDevice
            || !userDevice!.isStatusRegistered
            || (currentUser.isCurrentUserStatusActivating ?? true) {
            
            showDeviceQR.isEnable = false
        }
        
        let manageDevices = OptionVM(type: .manageDevices, name: "Manage Devices", isEnable: true)
        
        let transactionViaQR = OptionVM(type: .transactionViaQR, name: "Transaction via QR", isEnable: true)
        if nil == userDevice
            || !userDevice!.isStatusAuthorized
            || (currentUser.isCurrentUserStatusActivating ?? true) {
            
            transactionViaQR.isEnable = false
        }
        
        let initialRecovery = OptionVM(type: .initiateDeviceRecovery, name: "Initiate Recovery", isEnable: false)
        if (currentUser.currentDevice?.isStatusRegistered ?? false)
            && ((currentUser.isCurrentUserStatusActivated ?? false) ) {
            initialRecovery.isEnable = true
        }
        
        self.abortRecoveryOption?.isEnable = false
        if nil == abortRecoveryOption {
            abortRecoveryOption = OptionVM(type: .abortRecovery, name: "Abort Recovery", isEnable: false)
        }
        
        if nil != userDevice
            || !userDevice!.isStatusRevoked
            || !(currentUser.isCurrentUserStatusActivating ?? true) {
            
            fetchPendingRecovery()
        }
        
        let revokeAllSession = OptionVM(type: .revokeAllSessions, name: "Revoke all Sessions", isEnable: true)
        if !currentUser.isCurrentDeviceStatusAuthrozied {
            
            revokeAllSession.isEnable = false
        }
        
        let logoutApp = OptionVM(type: .logout, name: "Logout", isEnable: true)

        
        let dOptions = [authorizeViaQR, authorizeViaMnemonics, optionBiomertic, showDeviceQR, manageDevices,
                        transactionViaQR, initialRecovery, abortRecoveryOption!, revokeAllSession, logoutApp]
        
        deviceOptions = dOptions
    }
    
    
    func processSelectedOption(_ option: OptionVM) {
        
        if option.type == .logout {
            showAlertForLogoutApplication()
            return
        }
        
        if option.type == .contactSupport {
            openSupportWebView()
            return
        }
        
        if CurrentUserModel.getInstance.isCurrentDeviceStatusAuthorizing {
            showDeviceIsAuthroizingAlert()
            return
        }
        
        if option.type == .crashReportPreference {
            let stateText = UserSetting.shared.isOptInForCrashReport() ? "Opt-out" : "Opt-in"
            let alertTitleText = stateText + " For Crash Report"
            
            showInfoAlert(title: alertTitleText,
                          message: "To activate this setting, Please completely quit the app",
                          actionButtonTitle: stateText,
                          actionButtonTapped: {(_) in
                            
                            UserSetting.shared.updateCrashReportPreference()
            })
            return
        }
        
        
        var destinationSVVC: BaseSettingOptionsSVViewController? = nil
        var destinationVC: BaseSettingOptionsViewController? = nil
        
        if option.type == .details {
            destinationVC = UserDetailsViewController()
        }
            
        else if option.type == .viewMnemonics {
            if option.isEnable {
                destinationSVVC = DeviceMnemonicsViewController()
            }else {
                showInfoAlert(title: "Device is not authorized. Authorize your device to use this function.")
            }
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
                let currentUser = CurrentUserModel.getInstance
                let userDevice = currentUser.currentDevice
                
                if !userDevice!.isStatusRegistered {
                    showInfoAlert(title: "Device is not in registered state. You can use this function to authorize this device.")
                }else if (currentUser.isCurrentUserStatusActivating ?? true) {
                    showDeviceIsAuthroizingAlert()
                }
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
            if option.isEnable {
                destinationVC = ManageDeviceViewController()
            }else {
                showInfoAlert(title: "Once")
            }
        }
            
        else if option.type == .initiateDeviceRecovery {
            if option.isEnable {
                destinationVC = InitiateDeviceRecoveryViewController()
            }else {
                showInfoAlert(title: "Device is already authorized. You can use this function to authorize your new device.")
            }
        }
            
        else if option.type == .resetPin {
            if option.isEnable {
                _ = OstSdkInteract.getInstance.resetPin(userId: CurrentUserModel.getInstance.ostUserId!,
                                                        passphrasePrefixDelegate: CurrentUserModel.getInstance,
                                                        presenter: self)
                self.tabbarController?.hideTabBar()
            }else {
                showInfoAlert(title: "Device is not authorized. Authorize your device to use this function.")
            }
        }
            
        else if option.type == .abortRecovery {
            if option.isEnable {
                _ = OstSdkInteract.getInstance.abortDeviceRecovery(userId: CurrentUserModel.getInstance.ostUserId!,
                                                                   passphrasePrefixDelegate: CurrentUserModel.getInstance,
                                                                   presenter: self)
                self.tabbarController?.hideTabBar()
            }else {
                showInfoAlert(title: "Recovery not initiated, Abort recovery applies only if recovery has been previously initiated.")
            }
            
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
                showInfoAlert(title: "No biometrics available on this device. Please enable via your device settings") 
            }
        }
        
        else if option.type == .revokeAllSessions {
            if option.isEnable {
                showAlertForRevokeAllSessions()
            }else {
                showInfoAlert(title: "Device is not authorized. Authorize your device to use this function.")
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
        
        if workflowContext.workflowType == .logoutAllSessions {
             progressIndicator?.showSuccessAlert(forWorkflowType: workflowContext.workflowType)
        }
    }
    
    func flowInterrupted(workflowId: String, workflowContext: OstWorkflowContext, error: OstError) {
        if workflowContext.workflowType == .logoutAllSessions {
            progressIndicator?.showFailureAlert(forWorkflowType: workflowContext.workflowType)
        }
    }
    
    func requestAcknowledged(workflowId: String, workflowContext: OstWorkflowContext, contextEntity: OstContextEntity) {
        if workflowContext.workflowType == .logoutAllSessions {
            progressIndicator?.showAcknowledgementAlert(forWorkflowType: workflowContext.workflowType)
        }
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
    
    func showAlertForLogoutApplication() {
        let alert = UIAlertController(title: "Are you sure you want to logout from OST Wallet",
                                  message: "", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Logout", style: .default, handler: { (alertAction) in
            CurrentUserModel.getInstance.logout()
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.showIntroController()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alert.show()
    }
    
    func showAlertForRevokeAllSessions() {
        
        let alert = UIAlertController(title: "Are you sure you want to revoke all sessions? You will need re-authenticate to spend tokens.", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Revoke Sessions", style: .default, handler: {[weak self] (_) in
            self?.logoutSessions()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.show()
    }
    
    func logoutSessions() {
        progressIndicator = OstProgressIndicator(textCode: .revokingAllSessions)
        progressIndicator?.show()
        
        if let ostUserId = CurrentUserModel.getInstance.ostUserId {
            let workflowDelegate = OstSdkInteract.getInstance.getWorkflowCallback(forUserId: ostUserId)
            OstSdkInteract.getInstance.subscribe(forWorkflowId: workflowDelegate.workflowId,
                                                 listner: self)
        
            OstWalletSdk.logoutAllSessions(userId: ostUserId,
                                           delegate: workflowDelegate)
        }
    }
    
    func openSupportWebView() {
        let webView = WKWebViewController()
        webView.title = "OST Support"
        webView.urlString = "https://help.ost.com/support/home"
        webView.showVC()
    }
    
    func fetchPendingRecovery() {
        if let ostUserId: String =  CurrentUserModel.getInstance.ostUserId {
            OstJsonApi.getPendingRecovery(forUserId:ostUserId, delegate: self)
        }
    }
    
    //MARK: - Ost Json Api Delegate
    func onOstJsonApiSuccess(data: [String : Any]?) {
        if let resultType = OstJsonApi.getResultType(apiData: data),
            "devices".caseInsensitiveCompare(resultType) == .orderedSame {
            
            self.abortRecoveryOption?.isEnable = true
            self.tableView?.reloadSections([1], with: .automatic)
        }
    }
    
    func onOstJsonApiError(error: OstError?, errorData: [String : Any]?) {
    
    }
}
