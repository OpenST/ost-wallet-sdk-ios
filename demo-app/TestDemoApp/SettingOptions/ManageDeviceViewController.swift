/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import UIKit
import OstWalletSdk

class ManageDeviceViewController: BaseSettingOptionsViewController, UITableViewDelegate, UITableViewDataSource {
    
    enum DeviceStatus: String {
        case authorized
        case revoked
        case revoking
        case recovering
        case registered
    }
    
    override func getNavBarTitle() -> String {
        return "Manage Devices"
    }
    
    override func getLeadLabelText() -> String {
        return "Here are your authorized devices"
    }
    
    //MAKR: - Components
    var deviceTableView: UITableView = {
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
    
    var paginationTriggerPageNumber = 1
    var paginatingViewCount = 1
    
    var tableDataArray: [[String: Any]] = [[String: Any]]()
    var meta: [String: Any]? = nil
    
    //MARK: - View LC
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: - Add Subview
    override func addSubviews() {
        super.addSubviews()
        
        setupTableView()
        
        
        addSubview(deviceTableView)
        
        self.getDeviceList(hardRefresh: true)
    }
    
    func setupTableView() {
        deviceTableView.delegate = self
        deviceTableView.dataSource = self
        
        registerCells()
    }
    
    func registerCells() {
        self.deviceTableView.register(DeviceTableViewCell.self, forCellReuseIdentifier: DeviceTableViewCell.deviceCellIdentifier)
        self.deviceTableView.register(PaginationLoaderTableViewCell.self, forCellReuseIdentifier: PaginationLoaderTableViewCell.cellIdentifier)
    }
    
    //MARK: - Add Constraints
    override func addLayoutConstraints() {
        super.addLayoutConstraints()
        addDeviceTableConstraitns()
    }
    
    func addDeviceTableConstraitns() {
        deviceTableView.placeBelow(toItem: leadLabel)
        deviceTableView.applyBlockElementConstraints(horizontalMargin: 0)
        deviceTableView.setH667Height(height: 600)
        deviceTableView.bottomAlignWithParent()
    }
    
    //MARK: - Table View Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableDataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: DeviceTableViewCell = tableView.dequeueReusableCell(withIdentifier: DeviceTableViewCell.deviceCellIdentifier,
                                                                      for: indexPath) as! DeviceTableViewCell
        
        if tableDataArray.count > indexPath.row {
            let deviceDetail = tableDataArray[indexPath.row]
            cell.setDeviceDetails(details: deviceDetail, withIndex: indexPath.row)
            cell.sendButtonAction = {[weak self] (entity) in
                self?.actionButtonTapped(entity!)
            }
        }else {
            cell.setDeviceDetails(details: [:], withIndex: indexPath.row)
        }
        return cell
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
        if tableDataArray.count > 55 {
            return
        }
        if !self.isNewDataAvailable
            && self.shouldLoadNextPage
            && scrollView.panGestureRecognizer.translation(in: scrollView.superview!).y < 0 {
            
            if (shouldRequestPaginationData(isUpDirection: false,
                                            andTargetPoint: targetContentOffset.pointee.y)) {
                
                self.shouldLoadNextPage = false
                self.getDeviceList()
            }
        }
    }
    
    func shouldRequestPaginationData(isUpDirection: Bool = false,
                                     andTargetPoint targetPoint: CGFloat) -> Bool {
        
        let triggerPoint: CGFloat = CGFloat(self.paginationTriggerPageNumber) * self.deviceTableView.frame.size.height
        if (isUpDirection) {
            return targetPoint <= triggerPoint
        }else {
            return targetPoint >= (self.deviceTableView.contentSize.height - triggerPoint)
        }
    }
    
    
    //MARK: - Pull to Refresh
    @objc func pullToRefresh(_ sender: Any? = nil) {
        self.getDeviceList(hardRefresh: true)
    }
    
    func reloadDataIfNeeded() {
        
        let isScrolling: Bool = (self.deviceTableView.isDragging) || (self.deviceTableView.isDecelerating)
        
        if !isScrolling && self.isNewDataAvailable {
            self.deviceTableView.reloadData()
            self.isNewDataAvailable = false
            self.shouldLoadNextPage = true
        }
        
        if !isApiCallInProgress {
            if self.refreshControl.isRefreshing {
                self.refreshControl.endRefreshing()
            }
//            self.deviceTableView.reloadSections(IndexSet(integer: 1), with: .automatic)
        }
    }
    
    
    //MARK: - Get Device
    
    func getDeviceList(hardRefresh: Bool = false) {
        if isApiCallInProgress {
            reloadDataIfNeeded()
            return
        }
        if hardRefresh {
            meta = nil
            tableDataArray = []
        }else if nil != meta && meta!.isEmpty {
            reloadDataIfNeeded()
            return
        }
        isApiCallInProgress = true
        DeviceAPI.getDevices(meta: meta, onSuccess: {[weak self] (apiResponse) in
            if let strongSelf = self {
                strongSelf.onFetchDeviceSuccess(apiResponse)
            }
            }, onFailure: {[weak self] (apiResponse) in
                if let strongSelf = self {
                    strongSelf.isApiCallInProgress = false
                }
        })
    }
    
    func onFetchDeviceSuccess(_ apiResponse: [String: Any]?) {
        isApiCallInProgress = false
            
        meta = apiResponse!["meta"] as? [String: Any]
        guard let resultType = apiResponse!["result_type"] as? String else {return}
        guard let devices = apiResponse![resultType] as? [[String: Any]] else {return}
       
        tableDataArray.append(contentsOf: devices)
        self.isNewDataAvailable = true
        
        reloadDataIfNeeded()
    }
    
    //MAKR: - Action
    func actionButtonTapped(_ entity: [String: Any]) {
        let status = entity["status"] as! String
        switch status.lowercased() {
        case DeviceStatus.authorized.rawValue:
            return
        case DeviceStatus.revoked.rawValue:
            return
        case DeviceStatus.revoking.rawValue:
            fallthrough
        case DeviceStatus.recovering.rawValue:
            abortDeviceRecovery()
            return
        case DeviceStatus.registered.rawValue:
            showAuthorizedDevices()
        default:
            return
        }
    }
    
    func showAuthorizedDevices() {
        let intiateDeviceVC = InitiateDeviceRecoveryViewController()
        intiateDeviceVC.pushViewControllerOn(self, animated: true)
    }
    
    func abortDeviceRecovery() {
        progressIndicator?.progressText = "Abort device recovery initiated..."
        progressIndicator?.show()
        OstWalletSdk.abortDeviceRecovery(userId: CurrentUserModel.getInstance.ostUserId!,
                                         userPin: "123456",
                                         passphrasePrefix: CurrentUserModel.getInstance.userPinSalt!,
                                         delegate: self.workflowDelegate)
    }
}
