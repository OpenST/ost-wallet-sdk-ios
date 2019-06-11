//
//  HomeViewController.swift
//  DemoApp
//
//  Created by aniket ayachit on 20/04/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import UIKit

class OstHomeViewController: OstBaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    //MARK: - Components
    var labelContainer: UIView?
    var infoLabel: UILabel = OstUIKit.leadLabel()
    var usersTableView: UITableView = {
        let tableView: UITableView = UITableView(frame: .zero, style: .plain)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.sectionHeaderHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    var tableHeaderView: UIView?
    var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(pullToRefresh(_:)), for: .valueChanged)
//        refreshControl.attributedTitle = NSAttributedString(string: "Fetching Users...")
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
    
    var tableDataArray: [[String: Any]] = [[String: Any]]()
    
    var tokenHolderAddressesMap: [String: Any] = [String: Any]()
    var consumedUserData: [String: Any] = [String: Any]()
    
    var updatedDataArray: [[String: Any]] = [[String: Any]]()
    var userBalances: [String: Any] = [String: Any]()
    var meta: [String: Any]? = nil
    
    weak var tabbarController: TabBarViewController?
    
    var paginationTriggerPageNumber = 1
    var paginatingViewCount = 1
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchUsers(hardRefresh: true)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func registerObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.updateUserData(_:)),
            name: NSNotification.Name(rawValue: "updateUserDataForTransaction"),
            object: nil)
    }
    
    func updateViewForUserActivated() {
        self.usersTableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabbarController?.showTabBar()
    }
    
    override func getNavBarTitle() -> String {
        return "Users"
    }
    
    override func getTargetForNavBarBackbutton() -> AnyObject? {
        return nil
    }
    
    override func getSelectorForNavBarBackbutton() -> Selector? {
        return nil
    }
    
    //MARK: - Views
    override func addSubviews() {
        super.addSubviews()
        //        createInfoLable()
        setupUsersTableView()
        setupRefreshControl()
    }
    
    func createInfoLable() {
        
        let container = UIView()
        container.backgroundColor = .white
        container.translatesAutoresizingMaskIntoConstraints = false
        self.labelContainer = container
        
        let currentEconomy = CurrentEconomy.getInstance
        self.infoLabel.text = "Welcome to \(currentEconomy.tokenSymbol ?? "") Economy. You can send tokens to other users within \(currentEconomy.tokenSymbol ?? "")."
        self.labelContainer!.addSubview(self.infoLabel)
        self.view.addSubview(container)
    }
    
    func setupUsersTableView() {
        self.view.addSubview(usersTableView)
        usersTableView.delegate = self
        usersTableView.dataSource = self
        registerTableViewCells()
    }
    
    func registerTableViewCells() {
        self.usersTableView.register(UsersTableViewCell.self, forCellReuseIdentifier: UsersTableViewCell.usersCellIdentifier)
        self.usersTableView.register(PaginationLoaderTableViewCell.self, forCellReuseIdentifier: PaginationLoaderTableViewCell.cellIdentifier)
    }
    
    func setupRefreshControl() {
        
        if #available(iOS 10.0, *) {
            self.usersTableView.refreshControl = self.refreshControl
        } else {
            self.usersTableView.addSubview(self.refreshControl)
        }
    }
    
    //MARK: - Constraints
    
    override func addLayoutConstraints() {
        super.addLayoutConstraints()
        //        applyLabelContainerConstraints()
        //        applyInfoLableConstraints()
        applyUsersTableViewConstraints()
    }
    
    func applyLabelContainerConstraints() {
        self.labelContainer?.topAlignWithParent()
        self.labelContainer?.applyBlockElementConstraints(horizontalMargin: 0)
    }
    
    func applyInfoLableConstraints() {
        self.infoLabel.topAlignWithParent(multiplier: 1, constant: 20)
        self.infoLabel.applyBlockElementConstraints(horizontalMargin: 30)
        self.infoLabel.bottomAlignWithParent(multiplier: 1, constant: -20)
    }
    
    func applyUsersTableViewConstraints() {
        self.usersTableView.topAlignWithParent()
        self.usersTableView.applyBlockElementConstraints(horizontalMargin: 0)
        self.usersTableView.bottomAlignWithParent()
    }
    
    //MARK: - Table View Delegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return self.tableDataArray.count
        case 1:
            return self.paginatingViewCount
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: BaseTableViewCell
        switch indexPath.section {
        case 0:
            let userCell: UsersTableViewCell = tableView.dequeueReusableCell(withIdentifier: UsersTableViewCell.usersCellIdentifier, for: indexPath) as! UsersTableViewCell
            if self.tableDataArray.count > indexPath.row {
                let userDetails = self.tableDataArray[indexPath.row]
                userCell.userData = userDetails
               
                if isCurrentUser(userDetails) {
                    userCell.userBalance = CurrentUserModel.getInstance.userBalanceDetails ?? [:]
                }
                else if let appUserId = ConversionHelper.toString(userDetails["app_user_id"]) {
                    userCell.userBalance = self.userBalances[appUserId] as? [String: Any] ?? [:]
                } else {
                    userCell.userBalance = [:]
                }
                
                userCell.sendButtonAction = {[weak self] (userDetails) in
                    if let strongSelf = self {
                        strongSelf.sendButtonTapped(userDetails)
                    }
                }
                
            }else {
                
            }
            
            cell = userCell as BaseTableViewCell
            
        case 1:
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
            return 75.0
        case 1:
            if isNextPageAvailable() || (self.isNewDataAvailable || self.shouldReloadData) {
                return 44.0
            }else {
                return 0.0
            }
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let userData = tableDataArray[indexPath.row]
        if let appUserId = ConversionHelper.toString(userData["app_user_id"]) {
            if appUserId.caseInsensitiveCompare(CurrentUserModel.getInstance.appUserId ?? "")  == .orderedSame {
                self.tabbarController?.jumpToWalletVC()
            }
        }
    }
    
    //MARK: - Pull to Refresh
    @objc func pullToRefresh(_ sender: Any? = nil) {
        consumedUserData = [:]
        self.fetchUsers(hardRefresh: true)
    }
    
    func reloadDataIfNeeded() {
        
        let isScrolling: Bool = (self.usersTableView.isDragging) || (self.usersTableView.isDecelerating)
        
        if !isScrolling && self.isNewDataAvailable {
            tableDataArray = updatedDataArray
            self.usersTableView.reloadData()
            self.isNewDataAvailable = false
            self.shouldLoadNextPage = true
            if self.refreshControl.isRefreshing {
                self.refreshControl.endRefreshing()
            }
        }
        else if !isApiCallInProgress && !isScrolling {
            if self.refreshControl.isRefreshing {
                self.refreshControl.endRefreshing()
            }
            self.usersTableView.reloadSections(IndexSet(integer: 1), with: .automatic)
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
                fetchUsers()
            }
        }
    }
    
    func shouldRequestPaginationData(isUpDirection: Bool = false,
                                     andTargetPoint targetPoint: CGFloat) -> Bool {
        
        let triggerPoint: CGFloat = CGFloat(self.paginationTriggerPageNumber) * self.usersTableView.frame.size.height
        if (isUpDirection) {
            return targetPoint <= triggerPoint
        }else {
            return targetPoint >= (self.usersTableView.contentSize.height - triggerPoint)
        }
    }
    
    //MARK: - API
    func fetchUsers(hardRefresh: Bool = false) {
        if isApiCallInProgress {
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
                self.shouldLoadNextPage = true
                return
            }
        }
        
        isApiCallInProgress = true
        UserAPI.getUsers(meta: nextPagePayload, onSuccess: {[weak self] (apiResponse) in
            if let strongSelf = self {
                strongSelf.onFetchUserSuccess(apiResponse)
            }
            }, onFailure: {[weak self] (apiResponse) in
                if let strongSelf = self {
                    strongSelf.isApiCallInProgress = false
                }
        })
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
    
    func onFetchUserSuccess(_ apiResponse: [String: Any]?) {
        isApiCallInProgress = false
        
        guard let response = apiResponse else {return}
        guard let data = response["data"] as? [String: Any] else {return}
        
        if let balances = data["balances"] as? [String: Any] {
            userBalances.merge(dict: balances)
        }
        meta = data["meta"] as? [String: Any]
        guard let users = data["users"] as? [[String: Any]] else {return}
        
        var newUsersData = [[String: Any]]()
        for user in users {
            if let appUserId = user["app_user_id"],
                let strAppUserId = ConversionHelper.toString(appUserId),
                consumedUserData[strAppUserId] == nil {
                
                if isCurrentUser(user) {
                    consumedUserData[strAppUserId] = user
                    newUsersData.append(user)
                }
                else if let tokenHolderAddress = user["token_holder_address"] as? String,
                    !["", "<null>"].contains(tokenHolderAddress) {
                    tokenHolderAddressesMap[tokenHolderAddress] = strAppUserId
                    consumedUserData[strAppUserId] = user
                    newUsersData.append(user)
                }
            }
        }
        updatedDataArray.append(contentsOf: newUsersData)
        self.isNewDataAvailable = true
        
        reloadDataIfNeeded()
    }
    
    //MARK: - REFRESH USER DATA
    @objc func updateUserData(_ notification: Notification) {
        if let executeTransactionNotification = notification.object as? [String: Any],
            let tokenHolderAddresses = executeTransactionNotification["tokenHolderAddresses"] as? [String] {
            
            var appUserIds: Set<String> = []
            let currentTokenHolderAddress = CurrentUserModel.getInstance.tokenHolderAddress
            let currentUserAppUserId = CurrentUserModel.getInstance.appUserId
            for tokenHolderAddress in tokenHolderAddresses {
                if let appUserId = tokenHolderAddressesMap[tokenHolderAddress],
                    let strAppUserId = ConversionHelper.toString(appUserId) {
                    appUserIds.insert(strAppUserId)
                }else if nil != currentUserAppUserId
                    && nil != currentTokenHolderAddress
                    && currentTokenHolderAddress!.caseInsensitiveCompare(tokenHolderAddress) == .orderedSame {
                    
                        appUserIds.insert(currentUserAppUserId!)
                }
            }
            
            if appUserIds.count > 0 {
                refreshUsersData(appUserIds: Array(appUserIds))
            }
        }
    }
    
    func refreshUsersData(appUserIds:[String]) {
        //Make api call.
        var payload:[String:Any] = [:];
        payload["app_user_ids"] = "[\(appUserIds.joined(separator: ","))]";
        UserAPI.getUsers(meta: payload,
                         onSuccess: {[weak self] (apiResponse) in
                            if let strongSelf = self {
                                strongSelf.onUserDataUpdated(apiResponse)
                            }
            },
                         onFailure: {(apiResponse) in
                            //Ignore.
                            
        });
    }
    
    func onUserDataUpdated(_ apiResponse: [String: Any]?) {
        guard let response = apiResponse else {return}
        guard let data = response["data"] as? [String: Any] else {return}
        
        if let pricePoint = data["price_point"] as? [String: Any] {
            CurrentUserModel.getInstance.pricePoint = pricePoint
        }
        
        if let balances = data["balances"] as? [String: Any] {
            userBalances.merge(dict: balances)
            
            if let currentUserBalance = balances[CurrentUserModel.getInstance.appUserId!] as? [String : Any] {
                CurrentUserModel.getInstance.updateBalance(balance: currentUserBalance )
            }
        }
        
        guard let users = data["users"] as? [[String: Any]] else {return}
        var newData:[String: [String: Any]] = [:];
        for var newUserData in users {
            guard let appUserId = ConversionHelper.toString(newUserData["app_user_id"]) else {continue;};
            newData[appUserId] = newUserData;
        }
        var cnt = -1;
        for var existingUser in tableDataArray {
            cnt = cnt + 1;
            guard let appUserId = ConversionHelper.toString(existingUser["app_user_id"]) else {continue;};
            if ( nil == newData[appUserId] ) {
                continue;
            }
            existingUser.merge(dict: newData[appUserId]!);
            tableDataArray[ cnt ] = existingUser;
        }
        refreshVisibleCells();
    }
    
    func refreshVisibleCells() {
        let isScrolling: Bool = (self.usersTableView.isDragging) || (self.usersTableView.isDecelerating)
        if !isScrolling {
            self.usersTableView.reloadData();
        }
    }
    
    //MARK: - Action
    func sendButtonTapped(_ userDetails: [String: Any]?) {
        
        if (CurrentUserModel.getInstance.isCurrentUserStatusActivating ?? false)
            || CurrentUserModel.getInstance.isCurrentDeviceStatusAuthorizing {
            
            showDeviceIsAuthroizingAlert()
            return
        }
        
        if !CurrentUserModel.getInstance.isCurrentDeviceStatusAuthrozied {
            showDeviceIsNotAuthorizedAlert {[weak self] (alertAction) in
                self?.tabbarController?.showAuthorizeDeviceOptions()
            }
            return
        }
        
        let sendTokendsVC = SendTokensViewController()
        sendTokendsVC.tabbarController = self.tabbarController
        sendTokendsVC.userDetails = userDetails
        tabbarController?.hideTabBar()
        sendTokendsVC.pushViewControllerOn(self, animated: true)
    }
    
    func isCurrentUser(_ userData: [String: Any]) -> Bool {
        if let appUserId = userData["app_user_id"],
            let strAppUserId = ConversionHelper.toString(appUserId) {
            
            if strAppUserId.caseInsensitiveCompare(CurrentUserModel.getInstance.appUserId ?? "") == .orderedSame {
               return true
            }
        }
        return false
    }
}
