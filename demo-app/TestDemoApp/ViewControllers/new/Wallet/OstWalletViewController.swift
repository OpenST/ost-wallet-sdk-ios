//
//  DAWalletViewController.swift
//  DemoApp
//
//  Created by aniket ayachit on 20/04/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import UIKit
import OstWalletSdk

class OstWalletViewController: OstBaseViewController, UITableViewDelegate, UITableViewDataSource, OstFlowInterruptedDelegate, OstFlowCompleteDelegate, OstRequestAcknowledgedDelegate, OstJsonApiDelegate {

    //MARK: - Components
    var walletTableView: UITableView = {
        let tableView: UITableView = UITableView(frame: .zero, style: .plain)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.sectionHeaderHeight = UITableView.automaticDimension
        tableView.allowsSelection = true
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        return tableView
    }()
    var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(pullToRefresh(_:)), for: .valueChanged)
//        refreshControl.attributedTitle = NSAttributedString(string: "Fetching Transactions...")
        refreshControl.tintColor = UIColor.color(22, 141, 193)
        
        return refreshControl
    }()
    var paginatingCell: PaginationLoaderTableViewCell?
    
    //MARK: - Variables
    var isNewDataAvailable: Bool = false
    var isViewUpdateInProgress: Bool = false
    var shouldReloadData: Bool = false
    var shouldLoadNextPage: Bool = true
    var isApiCallInProgress: Bool = false
    
    var isFetchingUserBalance: Bool = false
    var isFetchingUserTransactions: Bool = false
    
    var tableDataArray: [[String: Any]] = [[String: Any]]()
    
    var consumedTransactions: [String: Any] = [:]
    var transactionUsers: [String: Any] = [:]
    
    var updatedDataArray: [[String: Any]] = [[String: Any]]()
    var meta: [String: Any]? = nil
    
    var paginationTriggerPageNumber = 1
    
    weak var tabbarController: TabBarViewController?
    
    var workflowCallbacks: OstWorkflowCallbacks? = nil
    
    //MARK: - View LC
    override func viewDidLoad() {
        super.viewDidLoad()
        if nil != workflowCallbacks {
            subscribeToWorkflowId(workflowCallbacks!.workflowId)
        }
        fetchUserWalletData(hardRefresh: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UserCrashlyticsSetting.shared.verifyUserCrashlyticsPreferenceIfRequired()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func registerObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.updateUserDataForTrasaction(_:)),
            name: NSNotification.Name(rawValue: "updateUserDataForTransaction"),
            object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.tabbarController?.showTabBar()
        self.walletTableView.reloadSections([0], with: UITableView.RowAnimation.automatic)
    }

    //MARK: - Views
    override func getNavBarTitle() -> String {
        return "Wallet"
    }
    
    override func getTargetForNavBarBackbutton() -> AnyObject? {
        return nil
    }
    
    override func getSelectorForNavBarBackbutton() -> Selector? {
        return nil
    }
    
    override func addSubviews() {
        super.addSubviews()
        setupUsersTableView()
        setupRefreshControl()
    }
    
    func setupUsersTableView() {
        self.view.addSubview(walletTableView)
        walletTableView.delegate = self
        walletTableView.dataSource = self
        registerTableViewCells()
    }
    
    func registerTableViewCells() {
        self.walletTableView.register(TransactionTableViewCell.self,
                                      forCellReuseIdentifier: TransactionTableViewCell.transactionCellIdentifier)
        self.walletTableView.register(WalletValueTableViewCell.self,
                                      forCellReuseIdentifier: WalletValueTableViewCell.cellIdentifier)
        self.walletTableView.register(EmptyTransactionTableViewCell.self,
                                      forCellReuseIdentifier: EmptyTransactionTableViewCell.emptyTransactionTCellIdentifier)
        self.walletTableView.register(PaginationLoaderTableViewCell.self,
                                      forCellReuseIdentifier: PaginationLoaderTableViewCell.cellIdentifier)
    }
    
    func setupRefreshControl() {
        
        if #available(iOS 10.0, *) {
            self.walletTableView.refreshControl = self.refreshControl
        } else {
            self.walletTableView.addSubview(self.refreshControl)
        }
    }
    
    //MARK: - Constraints
    
    override func addLayoutConstraints() {
        super.addLayoutConstraints()
        applyCollectionViewConstraints()
    }
    
    func applyCollectionViewConstraints() {
        
        walletTableView.topAlignWithParent()
        walletTableView.applyBlockElementConstraints(horizontalMargin: 0)
        walletTableView.bottomAlignWithParent()
    }
    
    //MARK: - Table View Delegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return tableDataArray.count
        case 2:
            return tableDataArray.count > 0 ? 0: 1
        case 3:
            return 1
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: BaseTableViewCell
        switch indexPath.section {
        case 0:
            let valueCell = tableView.dequeueReusableCell(withIdentifier: WalletValueTableViewCell.cellIdentifier, for: indexPath) as! WalletValueTableViewCell
            valueCell.userBalanceDetails = CurrentUserModel.getInstance.userBalanceDetails
            cell = valueCell as BaseTableViewCell
            cell.endDisplay()
            
        case 1:
            let tansactionCell: TransactionTableViewCell = tableView.dequeueReusableCell(withIdentifier: TransactionTableViewCell.transactionCellIdentifier, for: indexPath) as! TransactionTableViewCell
            
            if self.tableDataArray.count > indexPath.row {
                let transaction = self.tableDataArray[indexPath.row]
                tansactionCell.transactionData = transaction
            }else {
                tansactionCell.transactionData = [:]
            }
            
            cell = tansactionCell
            
        case 2:
             let emptyTansactionCell: EmptyTransactionTableViewCell = tableView.dequeueReusableCell(withIdentifier: EmptyTransactionTableViewCell.emptyTransactionTCellIdentifier, for: indexPath) as! EmptyTransactionTableViewCell
            
             let currentUser = CurrentUserModel.getInstance
             if currentUser.isCurrentUserStatusActivating! {

                emptyTansactionCell.showWalletSettingUpView()
             }else {
                emptyTansactionCell.showNoTransactionView()
             }
             
            cell = emptyTansactionCell
            
        case 3:
            let pCell: PaginationLoaderTableViewCell
            if nil == self.paginatingCell {
                pCell = tableView.dequeueReusableCell(withIdentifier: PaginationLoaderTableViewCell.cellIdentifier, for: indexPath) as! PaginationLoaderTableViewCell
                self.paginatingCell = pCell
            }else {
                pCell = self.paginatingCell!
            }
            
            if isNextPageAvailable() || (self.isNewDataAvailable || self.shouldReloadData) {
                pCell.startAnimating()
            }else {
                pCell.stopAnimating()
            }
            
            cell = pCell as BaseTableViewCell
            
        default:
            cell = BaseTableViewCell()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 160
        case 1:
            return 75.0
        case 2:
            return tableDataArray.count > 0 ? 0: 200
        case 3:
            if isNextPageAvailable() || (self.isNewDataAvailable || self.shouldReloadData) {
                return 44.0
            }else {
                return 0.0
            }
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let container = UIView()
        container.backgroundColor = .white
        
        if 1 == section {
            let sectionTitle = UILabel()
            sectionTitle.numberOfLines = 1
            sectionTitle.textColor = UIColor.color(52, 68, 91)
            sectionTitle.translatesAutoresizingMaskIntoConstraints = false
            sectionTitle.font = UIFont(name: "Lato", size: 13)?.bold()
            sectionTitle.text = "TRANSACTION HISTORY"
            
            container.addSubview(sectionTitle)
            
            sectionTitle.topAlignWithParent(multiplier: 1, constant: 20)
            sectionTitle.leftAlignWithParent(multiplier: 1, constant: 20)
            sectionTitle.rightAlignWithParent(multiplier: 1, constant: 20)
            sectionTitle.bottomAlignWithParent()
        }else {
            container.translatesAutoresizingMaskIntoConstraints = false
            container.setFixedHeight(constant: 1)
        }
        return container
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            let transfer = tableDataArray[indexPath.row]
            
            if let viewEndPoint = CurrentEconomy.getInstance.viewEndPoint,
                let auxChainId = CurrentEconomy.getInstance.auxiliaryChainId,
                let transactionHash = transfer["transaction_hash"] as? String {
                
                let transactionURL: String = "\(viewEndPoint)transaction/tx-\(auxChainId)-\(transactionHash)"
                
                let webView = WKWebViewController()
                webView.title = "OST View"
                webView.urlString = transactionURL
                webView.presentViewControllerWithNavigationController(self)
            }
        }
    }
    
    //MARK: - Scroll View Delegate
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            self.reloadDataIfNeeded()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.reloadDataIfNeeded()
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if !self.isNewDataAvailable
            && self.shouldLoadNextPage
            && scrollView.panGestureRecognizer.translation(in: scrollView.superview!).y < 0 {
            
            if (shouldRequestPaginationData(isUpDirection: false,
                                            andTargetPoint: targetContentOffset.pointee.y)) {
                
                self.shouldLoadNextPage = false
                fetchUserTransaction()
            }
        }
    }
    
    func shouldRequestPaginationData(isUpDirection: Bool = false,
                                     andTargetPoint targetPoint: CGFloat) -> Bool {
        
        let triggerPoint: CGFloat = CGFloat(self.paginationTriggerPageNumber) * self.walletTableView.frame.size.height
        if (isUpDirection) {
            return targetPoint <= triggerPoint
        }else {
            return targetPoint >= (self.walletTableView.contentSize.height - triggerPoint)
        }
    }
    
    //MARK: - Pull to Refresh
    @objc func pullToRefresh(_ sender: Any? = nil) {
        self.consumedTransactions = [:]
        self.fetchUserWalletData(hardRefresh: true)
    }
    
    func reloadDataIfNeeded() {
        
        let isScrolling: Bool = (self.walletTableView.isDragging) || (self.walletTableView.isDecelerating)
        
        if !isScrolling && self.isNewDataAvailable
            && !isFetchingUserTransactions
            && !isFetchingUserBalance {
            
            tableDataArray = updatedDataArray
            self.walletTableView.reloadData()
            self.isNewDataAvailable = false
            self.shouldLoadNextPage = true
            if self.refreshControl.isRefreshing {
                self.refreshControl.endRefreshing()
            }
        }
        else if !isFetchingUserTransactions  && !isFetchingUserBalance && !isScrolling {
            if self.refreshControl.isRefreshing {
                self.refreshControl.endRefreshing()
            }
            self.walletTableView.reloadSections(IndexSet(integer: 3), with: .automatic)
        }
    }
    
    func fetchUserWalletData(hardRefresh: Bool = false) {
        if CurrentUserModel.getInstance.isCurrentUserStatusActivated ?? false {
            fetchUserTransaction(hardRefresh: hardRefresh)
            fetchUserBalance(hardRefresh: hardRefresh)
        }
    }
    
    func fetchUserTransaction(hardRefresh: Bool = false) {
        if isFetchingUserTransactions {
            reloadDataIfNeeded()
            return
        }
        var nextPagePayload: [String: Any]? = nil
        var params: [String: Any] = [:]
        
        if hardRefresh {
            meta = nil
            updatedDataArray = []
        } else {
            nextPagePayload = getNextPagePayload()
            if nil == nextPagePayload {
                reloadDataIfNeeded()
                return
            }
            params = nextPagePayload!
        }
        isFetchingUserTransactions = true
        
        TransactionAPI.getTransactionLedger(params: params,
                                            onSuccess: {[weak self] (apiResponse) in
                                                self?.onTransactionFetchSuccess(apiResponse: apiResponse)
        }) {[weak self] (error) in
            self?.isFetchingUserTransactions = false
            self?.reloadDataIfNeeded()
        }
        
    }
    
    func isNextPageAvailable() -> Bool {
        return getNextPagePayload() != nil
    }
    
    func getNextPagePayload() -> [String: Any]? {
        guard let nextPagePayload = meta?["next_page_payload"] as? [String: Any] else {
            return nil
        }
        if nextPagePayload.isEmpty {
            return nil
        }
        return nextPagePayload
    }
    
    func fetchUserBalance(hardRefresh: Bool = false) {
        if isFetchingUserBalance {
            reloadDataIfNeeded()
            return
        }
        isFetchingUserBalance = true
        CurrentUserModel.getInstance.fetchUserBalance {[weak self] (isSuccess, _, _) in
            self?.isFetchingUserBalance = false
            self?.isNewDataAvailable = true
            self?.reloadDataIfNeeded()
            
            weak var homeVC: OstHomeViewController? = self?.tabbarController?.getUsersVC()
            if nil != homeVC {
                homeVC?.updateViewForUserActivated()
            }
        }
    }
    
    func subscribeToWorkflowId(_ workflowId: String) {
        OstSdkInteract.getInstance.subscribe(forWorkflowId: workflowId, listner: self)
    }
    
    //MARK: - OstSdkInteract Delegate
    func flowInterrupted(workflowId: String, workflowContext: OstWorkflowContext, error: OstError) {
         workflowCallbacks = nil
    }
    
    func flowComplete(workflowId: String, workflowContext: OstWorkflowContext, contextEntity: OstContextEntity) {
        if nil != workflowCallbacks {
            OstSdkInteract.getInstance.unsubscribe(forWorkflowId: workflowCallbacks!.workflowId, listner: self)
            workflowCallbacks = nil
        }
        if workflowContext.workflowType == .activateUser {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {[weak self] in
                self?.fetchUserWalletData(hardRefresh: true)
            }
        }
        workflowCallbacks = nil
    }
    
    func requestAcknowledged(workflowId: String, workflowContext: OstWorkflowContext, contextEntity: OstContextEntity) {
         workflowCallbacks = nil
    }
    
    
    @objc func updateUserDataForTrasaction(_ notification: Notification) {
        if let executeTransactionNotification = notification.object as? [String: Any],
            let isRequestAcknowledged = executeTransactionNotification["isRequestAcknowledged"] as? Bool {
            
            if isRequestAcknowledged {
                DispatchQueue.main.asyncAfter(deadline: .now() + 6) {[weak self] in
                    self?.consumedTransactions = [:]
                    self?.fetchUserTransaction(hardRefresh: true)
                }
            }
        }
    }
    
    //MARK: - Ost JSON API
    func onOstJsonApiSuccess(data: [String : Any]?) {
        isFetchingUserTransactions = false
        
        let resultType = OstJsonApi.getResultType(apiData: data);
        if ( "balance" == resultType ) {
            isFetchingUserBalance = false
            reloadDataIfNeeded()
            
        } else if ( "transactions" == resultType ) {
            onTransactionFetchSuccess(apiResponse: data)
        }
    }
    
    func onOstJsonApiError(error: OstError?, errorData: [String : Any]?) {
        if ( nil != error ) {
            print( error! );
        }
        
        isFetchingUserTransactions = false
        reloadDataIfNeeded()
    }
    
    func onTransactionFetchSuccess(apiResponse: [String: Any]?) {
        self.isFetchingUserTransactions = false
        guard let transactonData = apiResponse else {return}
        meta = transactonData["meta"] as? [String: Any] ?? [:]
        
        if let transctionUsersArray: [String: Any] = transactonData["transaction_users"] as? [String: Any] {
            transactionUsers.merge(dict: transctionUsersArray)
        }
        
        guard let transactions: [[String: Any]] = OstJsonApi.getResultAsArray(apiData: apiResponse) as? [[String: Any]] else {return}
        
        var transferArray = [[String: Any]]()
        for transaction in transactions {
            guard let status = transaction["status"] as? String else {
                continue
            }
            
            if status.caseInsensitiveCompare("SUCCESS") != .orderedSame
                && status.caseInsensitiveCompare("MINED") != .orderedSame
                && status.caseInsensitiveCompare("SUBMITTED") != .orderedSame {
                continue
            }
            
            guard let transactionHash = transaction["transaction_hash"] as? String else {
                continue
            }
            if nil != consumedTransactions[transactionHash] {
                continue
            }
            
            consumedTransactions[transactionHash] = transaction
            
            let transfers = transaction["transfers"] as! [[String: Any]]
            for transfer in transfers {
                var trasferData = transfer
                
                let currentUserOstId = CurrentUserModel.getInstance.ostUserId ?? ""
                let fromUserId = trasferData["from_user_id"] as! String
                let toUserId = trasferData["to_user_id"] as! String
                
                if [fromUserId, toUserId].contains(currentUserOstId) {
                    trasferData["meta_property"] = transaction["meta_property"]
                    trasferData["transaction_hash"] = transaction["transaction_hash"]
                    trasferData["block_timestamp"] = transaction["block_timestamp"]
                    trasferData["rule_name"] = transaction["rule_name"]
                    
                    updatedDisplayNameInTransferData(trasferData: &trasferData)
                    transferArray.append(trasferData)
                }
            }
        }
        
        updatedDataArray.append(contentsOf: transferArray)
        
        self.isNewDataAvailable = true
        reloadDataIfNeeded()
    }
    
    func updatedDisplayNameInTransferData(trasferData: inout [String: Any]) {
        let fromUserId = trasferData["from_user_id"] as! String
        let toUserId = trasferData["to_user_id"] as! String
        
        let companyTokenHolders = CurrentEconomy.getInstance.companyTokenHolders
        
        guard let ostUserId = CurrentUserModel.getInstance.ostUserId else {
            return
        }
        
        var displayText = ""
        var imageName = ""
        
        if fromUserId == toUserId {
            
            displayText = "Sent to yourself"
            imageName = "SentTokens"
        } else if fromUserId == ostUserId {
            if let transactionData = transactionUsers[toUserId] as? [String: Any] {
                
                let name = transactionData["username"] as! String
                displayText = "Sent to \(name)"
                
            }else if let toAddress = trasferData["to"] as? String {
                if nil != companyTokenHolders
                    && companyTokenHolders!.contains(toAddress) {
                
                    displayText = "Sent to \(CurrentEconomy.getInstance.tokenName ?? "Company")"
                }
            }
            
            if displayText.isEmpty {
                displayText = "Sent tokens"
            }
            imageName = "SentTokens"
        }
            
        else if toUserId == ostUserId {
            if let transactionData = transactionUsers[fromUserId] as? [String: Any] {
                
                let name = transactionData["username"] as! String
                displayText = "Received from \(name)"
            }else if let fromAddress = trasferData["from"] as? String {
                if nil != companyTokenHolders
                    && companyTokenHolders!.contains(fromAddress) {
                    
                    displayText = "Received from \(CurrentEconomy.getInstance.tokenName ?? "Company")"
                }
            }
            
            if displayText.isEmpty {
                displayText = "Received tokens"
            }
            imageName = "ReceivedTokens"
        }
        
        if let metaProperty = trasferData["meta_property"] as? [String: Any],
            let type = metaProperty["type"] as? String {
            if type.caseInsensitiveCompare("company_to_user") == .orderedSame {
                imageName = "OstGrantReceived"
                displayText = metaProperty["name"] as? String ?? "Received tokens"
            }
        }
        
        trasferData["display_name"] = displayText
        trasferData["image_name"] = imageName
    }
}
