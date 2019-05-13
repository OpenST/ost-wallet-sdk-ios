/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation
import UIKit

class UserDetailsViewController: BaseSettingOptionsViewController, UITableViewDelegate, UITableViewDataSource {
    
    enum CellType {
        case normal,
        withLink,
        withCopy
    }
    
    struct TableViewViewModel {
        var viewModel: UserDetailsBaseViewModel
        var type: CellType = .normal
    }
    
    var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        tableView.allowsSelection = false
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        return tableView
    }()
    
    //MARK: - Variables
    var userDetails: [TableViewViewModel] = [TableViewViewModel]()
    
    //MARK: View LC
    override func getNavBarTitle() -> String {
        return "Wallet Details"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        formUserDetails()
        tableView.reloadData()
    }
    
    //MARK: - Add SubViews
    override func addSubviews() {
        super.addSubviews()
        setupTabelVeiw()
        
        addSubview(tableView)
    }
    
    func setupTabelVeiw() {
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        registerCells()
    }
    
    func registerCells() {
        self.tableView.register(UserDetailsTableViewCell.self,
                                forCellReuseIdentifier: UserDetailsTableViewCell.userDetailsCellIdentifier)
        
        self.tableView.register(UserDetailsWithLinkTableViewCell.self,
                                forCellReuseIdentifier: UserDetailsWithLinkTableViewCell.userDetailsWithLinkCellIdentifier)
        
        self.tableView.register(UserDetailsWithCopyBtnTableViewCell.self,
                                forCellReuseIdentifier: UserDetailsWithCopyBtnTableViewCell.userDetailsWithCopyCellIdentifier)
    }
    
    //MARK: - Add Constraints
    override func addLayoutConstraints() {
        tableView.topAlignWithParent()
        tableView.applyBlockElementConstraints(horizontalMargin: 0)
        tableView.bottomAlignWithParent()
    }
    
    //MARK: - Table View Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userDetails.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UserDetailsTableViewCell
        let tableViewModel = userDetails[indexPath.row]
        
        switch tableViewModel.type {
        case .normal:
            let normalCell = tableView.dequeueReusableCell(withIdentifier: UserDetailsTableViewCell.userDetailsCellIdentifier,
                                                           for: indexPath) as! UserDetailsTableViewCell
            
            normalCell.userDetails = (tableViewModel.viewModel as! UserDetailsViewModel)
            cell  = normalCell
            
        case .withCopy:
            let copyCell = tableView.dequeueReusableCell(withIdentifier: UserDetailsWithCopyBtnTableViewCell.userDetailsWithCopyCellIdentifier,
                                                           for: indexPath) as! UserDetailsWithCopyBtnTableViewCell
            
            copyCell.userDetails = (tableViewModel.viewModel as! UserDetailsViewModel)
            cell  = copyCell
            
        case .withLink:
            let LinkCell = tableView.dequeueReusableCell(withIdentifier: UserDetailsWithLinkTableViewCell.userDetailsWithLinkCellIdentifier,
                                                           for: indexPath) as! UserDetailsWithLinkTableViewCell
            
            LinkCell.userDetailsWithLink = (tableViewModel.viewModel as! UserDetailsWithLinkViewModel)
            cell  = LinkCell
            
        }
        
        return cell
    }
    
    func formUserDetails() {
        
        let currentUser = CurrentUserModel.getInstance
        let currentEconomy = CurrentEconomy.getInstance
        
        let statusThemer = OstLabelTheamer()
        statusThemer.fontSize = 15
        statusThemer.textColor = UIColor.color(15, 157, 88)
        
        let copyThemer = OstLabelTheamer()
        copyThemer.fontSize = 15
        copyThemer.textColor = UIColor.color(67, 139, 173)
        
        let userIdVM : TableViewViewModel = TableViewViewModel(
            viewModel: UserDetailsViewModel(title: "OST User ID",
                                            value: currentUser.ostUserId ?? ""),
            type: .withCopy
        )
    
        let userStatuVM : TableViewViewModel = TableViewViewModel(
            viewModel: UserDetailsViewModel(title: "User Status",
                                            value: currentUser.status?.uppercased() ?? "",
                                            themer:  statusThemer),
            type: .normal
        )
        
        let tokenIDVM : TableViewViewModel = TableViewViewModel(
            viewModel: UserDetailsViewModel(title: "Token ID",
                                            value: currentEconomy.tokenId ?? ""),
            type: .normal
        )
        
        let tokenHolderAddressVM : TableViewViewModel = TableViewViewModel(
            viewModel: UserDetailsWithLinkViewModel(title: "Token Holder Address",
                                                    value: currentUser.tokenHolderAddress ?? "",
                                                    themer: copyThemer,
                                                    urlString: currentEconomy.viewEndPoint ?? ""),
            type: .withLink
        )
        
        let deviceAddressVM : TableViewViewModel = TableViewViewModel(
            viewModel: UserDetailsViewModel(title: "Device Address",
                                            value: currentUser.currentDevice?.address ?? ""),
            type: .withCopy
        )
        
        let deviceStatuVM : TableViewViewModel = TableViewViewModel(
            viewModel: UserDetailsViewModel(title: "Device Status",
                                            value: currentUser.currentDevice?.status?.uppercased() ?? "",
                                            themer:  statusThemer),
            type: .normal
        )
        
        let deviceManagerVM : TableViewViewModel = TableViewViewModel(
            viewModel: UserDetailsWithLinkViewModel(title: "Device Manager Address",
                                                    value: currentUser.deviceManagerAddress ?? "",
                                                    themer: copyThemer,
                                                    urlString: currentEconomy.viewEndPoint ?? ""),
            type: .withLink
        )
        
        let recoveryKeyVM : TableViewViewModel = TableViewViewModel(
            viewModel: UserDetailsViewModel(title: "Recovery Key Address",
                                            value: currentUser.ostUser?.recoveryAddress ?? ""),
            type: .withCopy
        )
        
        let recoveryOwnerKeyVM : TableViewViewModel = TableViewViewModel(
            viewModel: UserDetailsWithLinkViewModel(title: "Recovery Owner Address",
                                                    value: currentUser.ostUser?.recoveryOwnerAddress ?? "",
                                                    themer: copyThemer,
                                                    urlString: currentEconomy.viewEndPoint ?? ""),
            type: .withLink
        )
        
        let platformEndPointVM : TableViewViewModel = TableViewViewModel(
            viewModel: UserDetailsViewModel(title: "Recovery Key Address",
                                            value: currentEconomy.saasApiEndpoint ?? ""),
            type: .withCopy
        )
        
        userDetails.append(contentsOf: [userIdVM, userStatuVM, tokenIDVM, tokenHolderAddressVM, deviceAddressVM, deviceStatuVM,
                                        deviceManagerVM, recoveryKeyVM, recoveryOwnerKeyVM, platformEndPointVM])
    }
}
