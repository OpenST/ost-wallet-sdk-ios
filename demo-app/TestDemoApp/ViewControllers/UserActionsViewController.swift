/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import UIKit
import MaterialComponents

private let reuseIdentifier = "MDCCollectionViewTextCell"

class UserActionsViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
  var appBar = MDCAppBar()
  
  let ACTION_TYPE = "action";
  let ACTION_TEXT = "textLabel";
  let ACTION_DETAILS = "detailTextLabel";
  
  enum ACTIONS: String {
    case activateUser = "activateUser"
    case paperWallet = "paperWallet"
    case addSession = "addSession"
    case addDeviceUsingMnemonics = "addDeviceUsingMnemonics"
    case addDeviceByQRCode = "addDeviceByQRCode"
    case showQRCode = "showQRCode"
    case resetPin = "resetPin"
    case recoverDevice = "recoverDevice"
    case abortRecoverDevice = "abortRecoverDevice"
    case showUserDetails = "showUserDetails"
    case logoutAllSessions = "logoutAllSessions"
    case transactions = "transactions"
  }
  
  var dataItems:[[String:String]]?
  func buildData() {
    let currentUser = CurrentUser.getInstance();
    let ostUser = currentUser.ostUser!;
    let userDevice = currentUser.userDevice!;
    
    var addSession: [String: String] = [:];
    var showAddDeviceCode: [String: String] = [:];
    var showAddDeviceWithMnemonics: [String: String] = [:];
    var setupWallet: [String: String] = [:];
    var paperWallet: [String: String] = [:];
    var resetPin: [String: String] = [:]
    var recoverDevice: [String: String] = [:]
    var abortRecoverDevice: [String: String] = [:]
    var scanQRCode: [String: String] = [:];
    var showUserDetails: [String: String] = [:]
    var transactionsView: [String: String] = [:]
    var logoutAllSessions: [String: String] = [:]
    
    
    showUserDetails[ACTION_TYPE] = ACTIONS.showUserDetails.rawValue;
    showUserDetails[ACTION_TEXT] = "Show Details"
    showUserDetails[ACTION_DETAILS] = "View your Details"
    
    setupWallet[ACTION_TYPE] = ACTIONS.activateUser.rawValue;
    setupWallet[ACTION_TEXT] = "Setup your wallet";
    
    paperWallet[ACTION_TYPE] = ACTIONS.paperWallet.rawValue;
    paperWallet[ACTION_TEXT] = "See your paper wallet";
    
    showAddDeviceCode[ACTION_TYPE] = ACTIONS.showQRCode.rawValue
    showAddDeviceCode[ACTION_TEXT] = "Show QR-Code to Authorize Device"

    showAddDeviceWithMnemonics[ACTION_TYPE] = ACTIONS.addDeviceUsingMnemonics.rawValue
    showAddDeviceWithMnemonics[ACTION_TEXT] = "Authorize device using mnemonics."
    
    addSession[ACTION_TYPE] = ACTIONS.addSession.rawValue
    addSession[ACTION_TEXT] = "Create Session"

    scanQRCode[ACTION_TYPE] = ACTIONS.addDeviceByQRCode.rawValue
    scanQRCode[ACTION_TEXT] = "Scan QR Code"
    
    transactionsView[ACTION_TYPE] = ACTIONS.transactions.rawValue
    transactionsView[ACTION_TEXT] = "Transactions"
    transactionsView[ACTION_DETAILS] = "Likely to fail."

    resetPin[ACTION_TYPE] = ACTIONS.resetPin.rawValue
    resetPin[ACTION_TEXT] = "Reset pin"
    
    recoverDevice[ACTION_TYPE] = ACTIONS.recoverDevice.rawValue
    recoverDevice[ACTION_TEXT] = "Recover device"
    
    abortRecoverDevice[ACTION_TYPE] = ACTIONS.abortRecoverDevice.rawValue
    abortRecoverDevice[ACTION_TEXT] = "Abort Recover device"
    
    logoutAllSessions[ACTION_TYPE] = ACTIONS.logoutAllSessions.rawValue
    logoutAllSessions[ACTION_TEXT] = "Logout All Sessions"
    
    if ( userDevice.isStatusAuthorizing ) {
        addSession[ACTION_DETAILS] = "Likely to fail as device is authorizing.";
        scanQRCode[ACTION_DETAILS] = "Likely to fail as device is authorizing.";
        resetPin[ACTION_DETAILS] = "Likely to fail as device is authorizing.";
        recoverDevice[ACTION_DETAILS] = "Likely to fail as device is authorizing.";
        abortRecoverDevice[ACTION_DETAILS] = "Likely to fail as device is authorizing.";
        showAddDeviceCode[ACTION_DETAILS] = "Likely to fail as device is authorizing.";
        showAddDeviceWithMnemonics[ACTION_DETAILS] = "Authorize this device by providing Mnemonics.";
        logoutAllSessions[ACTION_DETAILS] = "Logout from device"
        transactionsView[ACTION_DETAILS] = "Likely to fail as device is authorizing.";
    } else if ( userDevice.isStatusAuthorized ) {
        addSession[ACTION_DETAILS] = "Create session a new session.";
        scanQRCode[ACTION_DETAILS] = "Perform transactions and Authorize devices by scanning QR code.";
        resetPin[ACTION_DETAILS] = "Don't worry, Reset Pin to continue.";
        recoverDevice[ACTION_DETAILS] = "Likely to fail as device is authorized.";
        abortRecoverDevice[ACTION_DETAILS] = "Likely to fail as device is authorized.";
        showAddDeviceWithMnemonics[ACTION_DETAILS] = "Likely to fail as device is already authorized.";
        showAddDeviceCode[ACTION_DETAILS] = "Likely to fail as device is already authorized.";
        logoutAllSessions[ACTION_DETAILS] = "Logout from device"
        transactionsView[ACTION_DETAILS] = "Likely to succeed if authorized session is available.";
    } else if ( userDevice.isStatusRegistered ) {
        addSession[ACTION_DETAILS] = "Likely to fail as device is not authorized";
        scanQRCode[ACTION_DETAILS] = "Likely to fail as device is not authorized";
        resetPin[ACTION_DETAILS] = "Likely to fail as device is not authorized";
        recoverDevice[ACTION_DETAILS] = "Recover device by providing device address.";
        abortRecoverDevice[ACTION_DETAILS] = "Likely to fail as device is Registered.";
        showAddDeviceCode[ACTION_DETAILS] = "Authorize this device by scanning the QR code.";
        showAddDeviceWithMnemonics[ACTION_DETAILS] = "Authorize this device by providing Mnemonics.";
        logoutAllSessions[ACTION_DETAILS] = "Likely to fail as device is Registered."
        transactionsView[ACTION_DETAILS] = "Likely to fail as device is not authorized";
    } else if ( userDevice.isStatusRevoked ) {
        addSession[ACTION_DETAILS] = "Likely to fail as device is revoked.";
        scanQRCode[ACTION_DETAILS] = "Likely to fail as device is revoked.";
        resetPin[ACTION_DETAILS] = "Likely to fail as device is revoked.";
        recoverDevice[ACTION_DETAILS] = "Likely to fail as device is revoked.";
        abortRecoverDevice[ACTION_DETAILS] = "Likely to fail as device is revoked.";
        showAddDeviceCode[ACTION_DETAILS] = "Likely to fail as device is revoked.";
        showAddDeviceWithMnemonics[ACTION_DETAILS] = "Likely to fail as device is revoked.";
        logoutAllSessions[ACTION_DETAILS] = "Likely to fail as device is revoked."
        transactionsView[ACTION_DETAILS] = "Likely to fail as device is revoked."
    }
    
    paperWallet[ACTION_DETAILS] = "See your paper wallet.";
    if ( ostUser.isStatusActivated ) {
        setupWallet[ACTION_DETAILS] = "You have already setup your wallet.";
    } else if ( ostUser.isStatusActivating) {
        setupWallet[ACTION_DETAILS] = "Your wallet is being setup.";
    } else {
        setupWallet[ACTION_DETAILS] = "You need to setup your wallet to perform other actions.";
    }
    
    
    //Add back sendTransaction later on.
    //Final Ordering.
    dataItems = [showUserDetails, setupWallet, paperWallet, addSession, scanQRCode, transactionsView,
                 showAddDeviceCode, showAddDeviceWithMnemonics, resetPin, recoverDevice,abortRecoverDevice, logoutAllSessions];
  }
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated);
    buildData();
  }
  
    override func viewDidAppear(_ animated: Bool) {
      super.viewDidAppear(animated);
      let layout: UICollectionViewFlowLayout = self.collectionViewLayout as! UICollectionViewFlowLayout;
      layout.sectionInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
      layout.estimatedItemSize = CGSize(width: 1, height: 1);
      layout.minimumInteritemSpacing = 0
      layout.minimumLineSpacing = 0
      self.collectionView!.collectionViewLayout = layout
    }
  
    override func viewDidLoad() {
      super.viewDidLoad()
      buildData();
      
      self.title = "Wallet Actions"
      
      self.collectionView?.backgroundColor = .white
      
      // AppBar Init
      self.addChild(appBar.headerViewController)
      self.appBar.headerViewController.headerView.trackingScrollView = self.collectionView
      appBar.addSubviewsToParent()

      self.view.backgroundColor = ApplicationScheme.shared.colorScheme.surfaceColor
      self.collectionView?.backgroundColor = ApplicationScheme.shared.colorScheme.surfaceColor
      
      
      // TODO: Theme our interface with our typography
      self.view.backgroundColor = ApplicationScheme.shared.colorScheme.surfaceColor
      MDCAppBarColorThemer.applySemanticColorScheme(ApplicationScheme.shared.colorScheme, to:self.appBar)
      MDCAppBarTypographyThemer.applyTypographyScheme(ApplicationScheme.shared.typographyScheme, to: self.appBar)

      let backItemImage = UIImage(named: "Back")
      let templatedBackItemImage = backItemImage?.withRenderingMode(.alwaysTemplate)
      let backItem = UIBarButtonItem(image: templatedBackItemImage,
                                     style: .plain,
                                     target: self,
                                     action: #selector(backItemTapped(sender:)))
      
      self.navigationItem.leftBarButtonItem = backItem;

      
      // Uncomment the following line to preserve selection between presentations
      // self.clearsSelectionOnViewWillAppear = false

      // Register cell classes
      self.collectionView!.register(MDCCollectionViewTextCell.self, forCellWithReuseIdentifier: reuseIdentifier)

      // Do any additional setup after loading the view.
    }

  @objc func backItemTapped(sender: Any) {
    self.dismiss(animated: true, completion: nil)
  }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

  // MARK: UICollectionViewDataSource


  override func numberOfSections(in collectionView: UICollectionView) -> Int {
      // #warning Incomplete implementation, return the number of sections
    return 1;
  }


  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
      // #warning Incomplete implementation, return the number of items
    return dataItems?.count ?? 0;
  }

  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    // Configure the cell
    let cell:MDCCollectionViewTextCell = self.collectionView?.dequeueReusableCell(withReuseIdentifier: reuseIdentifier,
                                                        for: indexPath) as! MDCCollectionViewTextCell
    
    let itemData = dataItems![indexPath.item];
    cell.textLabel?.text = itemData[ACTION_TEXT]!;
    cell.detailTextLabel?.text = itemData[ACTION_DETAILS];
    cell.detailTextLabel?.numberOfLines = 0;
    cell.layer.borderWidth = 0.5;
    cell.layer.borderColor = UIColor.lightGray.cgColor
    
    return cell
  }
  
    // MARK: UICollectionViewDelegate

  
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
  
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
  
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let actionItem = dataItems![indexPath.item];
        let actionType:String = actionItem[ACTION_TYPE]! as String;
      
        //Initialize User
        if ( actionType.caseInsensitiveCompare(ACTIONS.activateUser.rawValue) == .orderedSame ) {
            let walletController = WalletViewController(nibName: nil, bundle: nil)
            walletController.viewMode = WalletViewController.ViewMode.SETUP_WALLET;
            self.present(walletController, animated: true, completion: nil);
        }
        //Paper Wallet.
        else if ( actionType.caseInsensitiveCompare(ACTIONS.paperWallet.rawValue) == .orderedSame ) {
            let walletController = WalletViewController(nibName: nil, bundle: nil);
            walletController.viewMode = WalletViewController.ViewMode.PAPER_WALLET;
            self.present(walletController, animated: true, completion: nil);
        }
        
        else if ( actionType.caseInsensitiveCompare(ACTIONS.addSession.rawValue) == .orderedSame ) {
            let walletController = WalletViewController(nibName: nil, bundle: nil);
            walletController.viewMode = WalletViewController.ViewMode.NEW_SESSION;
            self.present(walletController, animated: true, completion: nil);
        }
      
        else if ( actionType.caseInsensitiveCompare(ACTIONS.addDeviceByQRCode.rawValue) == .orderedSame ) {
            let walletController = WalletViewController(nibName: nil, bundle: nil);
            walletController.viewMode = WalletViewController.ViewMode.QR_CODE;
            self.present(walletController, animated: true, completion: nil);
        }
        
        else if ( actionType.caseInsensitiveCompare(ACTIONS.showQRCode.rawValue) == .orderedSame ) {
            let walletController = WalletViewController(nibName: nil, bundle: nil);
            walletController.viewMode = WalletViewController.ViewMode.SHOW_QR_CODE;
            self.present(walletController, animated: true, completion: nil);
        }
        
        else if ( actionType.caseInsensitiveCompare(ACTIONS.resetPin.rawValue) == .orderedSame ) {
            let walletController = WalletViewController(nibName: nil, bundle: nil);
            walletController.viewMode = WalletViewController.ViewMode.RESET_PIN;
            self.present(walletController, animated: true, completion: nil);
        }
        else if ( actionType.caseInsensitiveCompare(ACTIONS.addDeviceUsingMnemonics.rawValue) == .orderedSame ) {
            let walletController = WalletViewController(nibName: nil, bundle: nil);
            walletController.viewMode = WalletViewController.ViewMode.ADD_DEVICE_WITH_MNEMONICS;
            self.present(walletController, animated: true, completion: nil);
        }
        
        else if ( actionType.caseInsensitiveCompare(ACTIONS.showUserDetails.rawValue) == .orderedSame ) {
            let walletController = WalletViewController(nibName: nil, bundle: nil);
            walletController.viewMode = WalletViewController.ViewMode.SHOW_USER_DETAILS;
            self.present(walletController, animated: true, completion: nil);
        }
        
        else if ( actionType.caseInsensitiveCompare(ACTIONS.recoverDevice.rawValue) == .orderedSame ) {
            let walletController = WalletViewController(nibName: nil, bundle: nil);
            walletController.viewMode = WalletViewController.ViewMode.RECOVER_DEVICE;
            self.present(walletController, animated: true, completion: nil);
        }
        
        else if ( actionType.caseInsensitiveCompare(ACTIONS.abortRecoverDevice.rawValue) == .orderedSame ) {
            let walletController = WalletViewController(nibName: nil, bundle: nil);
            walletController.viewMode = WalletViewController.ViewMode.ABORT_RECOVER_DEVICE;
            self.present(walletController, animated: true, completion: nil);
        }
        
        else if ( actionType.caseInsensitiveCompare(ACTIONS.logoutAllSessions.rawValue) == .orderedSame ) {
            let walletController = WalletViewController(nibName: nil, bundle: nil);
            walletController.viewMode = WalletViewController.ViewMode.LOGOUT_ALL_SESSIONS;
            self.present(walletController, animated: true, completion: nil);
        }
        
        else if ( actionType.caseInsensitiveCompare(ACTIONS.transactions.rawValue) == .orderedSame ) {
            let walletController = WalletViewController(nibName: nil, bundle: nil);
            walletController.viewMode = WalletViewController.ViewMode.EXECUTE_TRANSACTION;
            self.present(walletController, animated: true, completion: nil);
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemData = dataItems![indexPath.item];

        let actionDetailsLabel = UILabel(frame: collectionView.frame)
        actionDetailsLabel.numberOfLines = 0
        actionDetailsLabel.font = MDCTypography.body1Font();
        actionDetailsLabel.text = itemData[ACTION_DETAILS] ?? ""
        actionDetailsLabel.sizeToFit()
        let acLines = actionDetailsLabel.calculateMaxLines();
        let cellHeight = (acLines == 1) ? MDCCellDefaultTwoLineHeight : MDCCellDefaultThreeLineHeight;
        return CGSize(width: collectionView.frame.width, height: cellHeight);
    }

    override func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        collectionView.collectionViewLayout.invalidateLayout()
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.backgroundColor = UIColor(red: 244.0/255.0, green: 248.0/255.0, blue: 249.0/255.0, alpha: 1.0);
        UIView.transition(with: cell!, duration: 2, options: UIView.AnimationOptions.curveEaseIn, animations: {
            cell?.backgroundColor = UIColor.white
        }, completion: nil);
    }
                    
    
    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
//MARK: - UIScrollViewDelegate

// The following four methods must be forwarded to the tracking scroll view in order to implement
// the Flexible Header's behavior.

extension UserActionsViewController {
  
  override func scrollViewDidScroll(_ scrollView: UIScrollView) {
    if (scrollView == self.appBar.headerViewController.headerView.trackingScrollView) {
      self.appBar.headerViewController.headerView.trackingScrollDidScroll()
    }
  }
  
  override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    if (scrollView == self.appBar.headerViewController.headerView.trackingScrollView) {
      self.appBar.headerViewController.headerView.trackingScrollDidEndDecelerating()
    }
  }
  
  override func scrollViewDidEndDragging(_ scrollView: UIScrollView,
                                         willDecelerate decelerate: Bool) {
    let headerView = self.appBar.headerViewController.headerView
    if (scrollView == headerView.trackingScrollView) {
      headerView.trackingScrollDidEndDraggingWillDecelerate(decelerate)
    }
  }
  
  override func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                          withVelocity velocity: CGPoint,
                                          targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    let headerView = self.appBar.headerViewController.headerView
    if (scrollView == headerView.trackingScrollView) {
      headerView.trackingScrollWillEndDragging(withVelocity: velocity,
                                               targetContentOffset: targetContentOffset)
    }
  }
}

extension UILabel {
    func calculateMaxLines() -> Int {
        let maxSize = CGSize(width: frame.size.width, height: CGFloat(Float.infinity))
        let charSize = font.lineHeight
        let text = (self.text ?? "") as NSString
        let textSize = text.boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        let linesRoundedUp = Int(ceil(textSize.height/charSize))
        return linesRoundedUp
    }
}
