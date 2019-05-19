//
//  OptionsViewController.swift
//  TestDemoApp
//
//  Created by aniket ayachit on 30/04/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import UIKit
import OstWalletSdk

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupTableViewModels()
        self.tabbarController?.showTabBar()
        
        getDeviceStatus()
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
        tableHeaderView.balanceLabel?.text =  CurrentUserModel.getInstance.tokenHolderAddress ?? ""
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
    
    //MAKR: - Table View Delegate
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
        sectionTitle.textColor = UIColor.gray
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
        
        let isEnable = cell.option.isEnable
        if isEnable {
            processSelectedOption(cell.option)
        }
    }
    
    func setupTableViewModels() {
        createGeneralOptionsArray()
        createDeviceOptionsArray()
        tableView?.reloadData()
    }
    
    func createGeneralOptionsArray() {
        let currentUser = CurrentUserModel.getInstance;
        let userDevice = currentUser.currentDevice!;
        
        let optionDetail = OptionVM(type: .details, name: "View Wallet Details", isEnable: true)
        
        var optionSession = OptionVM(type: .createSession, name: "Add Session", isEnable: true)
        if !userDevice.isStatusAuthorized {
            optionSession.isEnable = false
        }
        
        let optionResetPin = OptionVM(type: .resetPin, name: "Reset PIN", isEnable: true)
        
        var optionMnemonics = OptionVM(type: .viewMnemonics, name: "View Mnemonics", isEnable: true)
        if !userDevice.isStatusAuthorized {
            optionMnemonics.isEnable = false
        }
        
        let userOptions = [optionDetail, optionSession, optionResetPin, optionMnemonics]
        generalOptions = userOptions
    }
    
    func createDeviceOptionsArray() {
        let currentUser = CurrentUserModel.getInstance;
        let userDevice = currentUser.currentDevice!;
        
        var authorizeViaQR = OptionVM(type: .authorizeViaQR, name: "Authorize Device via QR", isEnable: true)
        if !userDevice.isStatusAuthorized {
            authorizeViaQR.isEnable = false
        }
        
        var authorizeViaMnemonics = OptionVM(type: .authorizeViaMnemonics, name: "Authorize Device via Mnemonics", isEnable: true)
        if !userDevice.isStatusRegistered {
            authorizeViaMnemonics.isEnable = false
        }
        
        var showDeviceQR = OptionVM(type: .showDeviceQR, name: "Show Device QR", isEnable: true)
        if !userDevice.isStatusRegistered {
            showDeviceQR.isEnable = false
        }
        
        let manageDevices = OptionVM(type: .manageDevices, name: "Manage Devices", isEnable: true)
        
        var transactionViaQR = OptionVM(type: .transactionViaQR, name: "Transaction via QR", isEnable: true)
        if !userDevice.isStatusAuthorized {
            transactionViaQR.isEnable = false
        }
        
        var initialRecovery = OptionVM(type: .initiateDeviceRecovery, name: "Initiate Recovery", isEnable: true)
        if !userDevice.isStatusRegistered {
            initialRecovery.isEnable = false
        }
        
        var abortRecovery = OptionVM(type: .abortRecovery, name: "Abort Recovery", isEnable: true)
        if userDevice.isStatusRevoked {
            abortRecovery.isEnable = false
        }
        
        var logoutAllSession = OptionVM(type: .logoutAllSessions, name: "Logout All Sessions", isEnable: true)
        if !userDevice.isStatusAuthorized {
            logoutAllSession.isEnable = false
        }
     
        let dOptions = [authorizeViaQR, authorizeViaMnemonics, showDeviceQR, manageDevices,
                             transactionViaQR, initialRecovery, abortRecovery, logoutAllSession]
        
        deviceOptions = dOptions
    }
    
    
    func processSelectedOption(_ option: OptionVM) {
        
        if CurrentUserModel.getInstance.isCurrentDeviceStatusAuthorizing {
            showDeviceIsAuthroizingAlert()
            return
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
            destinationSVVC = AuthorizeDeviceViaMnemonicsViewController()
        }
            
        else if option.type == .showDeviceQR {
            destinationVC = ShowQRCodeViewController()
        }
        
        else if option.type == .authorizeViaQR {
            destinationVC = AuthorizeDeviceQRScanner()
        }
            
        else if option.type == .transactionViaQR {
            destinationVC = TransactionQRScanner()
        }
        
        else if option.type == .createSession {
            destinationSVVC = CreateSessionViewController()
        }
        
        else if  option.type  == .manageDevices {
            destinationVC = ManageDeviceViewController()
        }
        
        else if option.type == .initiateDeviceRecovery {
            destinationVC = InitiateDeviceRecoveryViewController()
        }
        
        else if option.type == .resetPin {
            _ = OstSdkInteract.getInstance.resetPin(userId: CurrentUserModel.getInstance.ostUserId!,
                                                    passphrasePrefixDelegate: CurrentUserModel.getInstance,
                                                    presenter: self)
            self.tabbarController?.hideTabBar()
            return
        }
        
        else if option.type == .abortRecovery {
            _ = OstSdkInteract.getInstance.abortDeviceRecovery(userId: CurrentUserModel.getInstance.ostUserId!,
                                                               passphrasePrefixDelegate: CurrentUserModel.getInstance,
                                                               presenter: self)
            self.tabbarController?.hideTabBar()
            return
        }
        
        else if option.type == .logoutAllSessions {
            let callbackDelegate = OstSdkInteract.getInstance.logoutAllSessions(userId: CurrentUserModel.getInstance.ostUserId!,
                                                                                passphrasePrefixDelegate: CurrentUserModel.getInstance,
                                                                                presenter: self)
            OstSdkInteract.getInstance.subscribe(forWorkflowId: callbackDelegate.workflowId,
                                                 listner: self)
            return
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
        guard let currentDevice = CurrentUserModel.getInstance.currentDevice else {return}
        if currentDevice.isStatusRegistered {
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
        if workflowContext.workflowType == .setupDevice {
            setupTableViewModels()
        }
    }
    
    func flowInterrupted(workflowId: String, workflowContext: OstWorkflowContext, error: OstError) {
        if workflowContext.workflowType == .logoutAllSessions,
            error.errorMessage.contains("logged out") {
            
                CurrentUserModel.getInstance.logout()
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.showIntroController()
        }
    }
    
    func requestAcknowledged(workflowId: String, workflowContext: OstWorkflowContext, contextEntity: OstContextEntity) {
        if workflowContext.workflowType == .logoutAllSessions {
            CurrentUserModel.getInstance.logout()
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.showIntroController()
        }
    }
    
    func getDeviceStatus() {
        let workflowDelegate = OstSdkInteract.getInstance.getWorkflowCallback(forUserId: CurrentUserModel.getInstance.ostUserId!)
        OstSdkInteract.getInstance.subscribe(forWorkflowId: workflowDelegate.workflowId,
                                             listner: self)
        OstWalletSdk.setupDevice(userId: CurrentUserModel.getInstance.ostUserId!,
                                 tokenId: CurrentEconomy.getInstance.tokenId!,
                                 delegate: workflowDelegate)
    }
}
