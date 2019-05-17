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
        tableView.allowsSelection = false
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    var tableHeaderView: UIView?
    var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(pullToRefresh(_:)), for: .valueChanged)
        refreshControl.attributedTitle = NSAttributedString(string: "Fetching Users...")
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
        createInfoLable()
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
        applyLabelContainerConstraints()
        applyInfoLableConstraints()
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
        self.usersTableView.placeBelow(toItem: self.infoLabel)
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
                if let appUserId = ConversionHelper.toString(userDetails["app_user_id"]) {
                    userCell.userBalance = self.userBalances[appUserId] as? [String: Any] ?? [:]
                }else {
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
             return 75.0
        case 1:
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

    //MARK: - Pull to Refresh
    @objc func pullToRefresh(_ sender: Any? = nil) {
        self.fetchUsers(hardRefresh: true)
    }
    
    func reloadDataIfNeeded() {
        
        let isScrolling: Bool = (self.usersTableView.isDragging) || (self.usersTableView.isDecelerating)
        
        if !isScrolling && self.isNewDataAvailable {
            tableDataArray = updatedDataArray
            
            self.usersTableView.reloadData()
            self.isNewDataAvailable = false
            self.shouldLoadNextPage = true
        }
        
        else if !isApiCallInProgress {
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
        updatedDataArray.append(contentsOf: users)
        self.isNewDataAvailable = true

        reloadDataIfNeeded()
    }
    
    //MARK: - Action
    func sendButtonTapped(_ userDetails: [String: Any]?) {
        if CurrentUserModel.getInstance.isCurrentDeviceStatusAuthorizing {
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
        sendTokendsVC.userDetails = userDetails
        tabbarController?.hideTabBar()
        sendTokendsVC.pushViewControllerOn(self, animated: true)
    }
}
