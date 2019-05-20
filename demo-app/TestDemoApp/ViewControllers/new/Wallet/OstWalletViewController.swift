//
//  DAWalletViewController.swift
//  DemoApp
//
//  Created by aniket ayachit on 20/04/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import UIKit
import OstWalletSdk

class OstWalletViewController: OstBaseViewController, UITableViewDelegate, UITableViewDataSource, OstFlowInterruptedDelegate, OstFlowCompleteDelegate, OstRequestAcknowledgedDelegate {
    
    //MARK: - Components
    var walletTableView: UITableView = {
        let tableView: UITableView = UITableView(frame: .zero, style: .plain)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.sectionHeaderHeight = UITableView.automaticDimension
        tableView.allowsSelection = false
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        return tableView
    }()
    var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(pullToRefresh(_:)), for: .valueChanged)
        refreshControl.attributedTitle = NSAttributedString(string: "Fetching Transactions...")
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
    
    var updatedDataArray: [[String: Any]] = [[String: Any]]()
    var meta: [String: Any]? = nil
    
    var paginationTriggerPageNumber = 1
    
    var paginatingViewCount = 1
    
    weak var tabbarController: TabBarViewController?
    
    var workflowCallbacks: OstWorkflowCallbacks? = nil
    
    //MARK: - View LC
    override func viewDidLoad() {
        super.viewDidLoad()
        if nil != workflowCallbacks {
            OstSdkInteract.getInstance.subscribe(forWorkflowId: workflowCallbacks!.workflowId, listner: self)
        }
        fetchUserWalletData(hardRefresh: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.tabbarController?.showTabBar()
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
            return paginatingViewCount
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
             if currentUser.ostUser!.isStatusActivating {

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
            
            if self.isNewDataAvailable || self.shouldReloadData || !self.shouldLoadNextPage {
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
            return self.view.frame.width * 0.5
        case 1:
            return 75.0
        case 2:
            return tableDataArray.count > 0 ? 0: 200
        case 3:
            if self.isNewDataAvailable || self.shouldReloadData || !self.shouldLoadNextPage {
                return 44.0
            }else {
                self.paginatingCell?.stopAnimating()
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
            sectionTitle.textColor = UIColor.gray
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
        self.fetchUserWalletData(hardRefresh: true)
    }
    
    func reloadDataIfNeeded() {
        
        let isScrolling: Bool = (self.walletTableView.isDragging) || (self.walletTableView.isDecelerating)
        
        if !isScrolling && self.isNewDataAvailable
            && !isFetchingUserTransactions  && !isFetchingUserBalance {
            tableDataArray = updatedDataArray
            self.walletTableView.reloadData()
            self.isNewDataAvailable = false
            self.shouldLoadNextPage = true
            if self.refreshControl.isRefreshing {
                self.refreshControl.endRefreshing()
            }
        }
        else if !isFetchingUserTransactions  && !isFetchingUserBalance {
            if self.refreshControl.isRefreshing {
                self.refreshControl.endRefreshing()
            }
            self.walletTableView.reloadSections(IndexSet(integer: 1), with: .automatic)
        }
    }
    
    func fetchUserWalletData(hardRefresh: Bool = false) {
        if CurrentUserModel.getInstance.ostUser?.isStatusActivated ?? false {
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
        if hardRefresh {
            meta = nil
            updatedDataArray = []
        } else {
            nextPagePayload = getNextPagePayload()
            if nil == nextPagePayload {
                reloadDataIfNeeded()
                return
            }
        }
        isFetchingUserTransactions = true
        TransactionAPI.getTransactionLedger(onSuccess: {[weak self] (apiResponse) in
            self?.onTransactionFetchSuccess(apiResponse: apiResponse)
            
        }) {[weak self] (ApiError) in
            self?.isFetchingUserTransactions = false
            self?.reloadDataIfNeeded()
        }
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
    
    func onTransactionFetchSuccess(apiResponse: [String: Any]?) {
        self.isFetchingUserTransactions = false
        guard let transactonData = apiResponse else {return}
        meta = transactonData["meta"] as? [String: Any] ?? [:]
        
        guard let resultType = transactonData["result_type"] as? String else {return}
        guard let transactions = transactonData[resultType] as? [[String: Any]] else {return}
        
        var transferArray = [[String: Any]]()
        for transaction in transactions {
            let transfers = transaction["transfers"] as! [[String: Any]]
            for transfer in transfers {
                var trasferData = transfer
                
                let currentUserOstId = CurrentUserModel.getInstance.ostUserId ?? ""
                let fromUserId = trasferData["from_user_id"] as! String
                let toUserId = trasferData["to_user_id"] as! String

                if [fromUserId, toUserId].contains(currentUserOstId) {
                    trasferData["meta_property"] = transaction["meta_property"]
                    trasferData["block_timestamp"] = transaction["block_timestamp"]
                    trasferData["rule_name"] = transaction["rule_name"]
                    transferArray.append(trasferData)
                }
            }
        }
        
        updatedDataArray.append(contentsOf: transferArray)
        
        self.isNewDataAvailable = true
        reloadDataIfNeeded()
    }
    
    func fetchUserBalance(hardRefresh: Bool = false) {
        if isFetchingUserBalance {
            reloadDataIfNeeded()
            return
        }
        isFetchingUserBalance = true
        UserAPI.getBalance(onSuccess: {[weak self] (apiResponse) in
            self?.onBalanceFetchSuccess(apiResponse: apiResponse)
        }) {[weak self] (apiError) in
            self?.isFetchingUserBalance = false
            self?.reloadDataIfNeeded()
        }
    }
    
    func onBalanceFetchSuccess(apiResponse: [String: Any]?) {
        isFetchingUserBalance = false
        if nil == apiResponse {return}
        
        CurrentUserModel.getInstance.userBalanceDetails = apiResponse
        
        self.isNewDataAvailable = true
        reloadDataIfNeeded()
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {[weak self] in
            self?.fetchUserWalletData()
        }
        workflowCallbacks = nil
    }
    
    func requestAcknowledged(workflowId: String, workflowContext: OstWorkflowContext, contextEntity: OstContextEntity) {
         workflowCallbacks = nil
    }
    
}
