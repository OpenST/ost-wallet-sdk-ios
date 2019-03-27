/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import UIKit
import OstWalletSdk
import MaterialComponents

class WalletViewController: UIViewController {
    var appBar = MDCAppBar()
    public var showHeaderBackItem = true;
    var choosenView: BaseWalletView?;
  
  public enum ViewMode {
    case SETUP_WALLET
    case ADD_DEVICE_WITH_MNEMONICS
    case NEW_SESSION
    case EXECUTE_TRANSACTION
    case QR_CODE
    case PAPER_WALLET
    case SHOW_QR_CODE
    case RESET_PIN
    case RECOVER_DEVICE
    case ABORT_RECOVER_DEVICE
    case SHOW_USER_DETAILS
    case LOGOUT_ALL_SESSIONS
  }
    
  public var toUser:User? = nil
  
  var isLoginMode:Bool = true;
  //Default View Mode.
  public var viewMode = ViewMode.SETUP_WALLET;


  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    //Setup text field controllers
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

    
  override func viewDidLoad() {
    super.viewDidLoad()
    // choose view based on mode.
    let choosenView = chooseSubView();
    view.addSubview(choosenView)
    
    // AppBar Init
    self.addChild(appBar.headerViewController)
    appBar.addSubviewsToParent()
    self.view.backgroundColor = ApplicationScheme.shared.colorScheme.surfaceColor
    MDCAppBarColorThemer.applySemanticColorScheme(ApplicationScheme.shared.colorScheme, to:self.appBar)
    MDCAppBarTypographyThemer.applyTypographyScheme(ApplicationScheme.shared.typographyScheme, to: self.appBar)
    choosenView.backgroundColor = ApplicationScheme.shared.colorScheme.surfaceColor;

    // Setup Navigation Items
    if ( showHeaderBackItem ) {
      let backItemImage = UIImage(named: "Back")
      let templatedBackItemImage = backItemImage?.withRenderingMode(.alwaysTemplate)
      let backItem = UIBarButtonItem(image: templatedBackItemImage,
                                     style: .plain,
                                     target: self,
                                     action: #selector(backItemTapped(sender:)))
      
      self.navigationItem.leftBarButtonItem = backItem;
    }

    
    
    choosenView.translatesAutoresizingMaskIntoConstraints = false;
    choosenView.backgroundColor = .white
    choosenView.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    

    view.tintColor = .black
    choosenView.backgroundColor = .white

    

    NSLayoutConstraint.activate(
      NSLayoutConstraint.constraints(withVisualFormat: "V:|[scrollView]|",
                                     options: [],
                                     metrics: nil,
                                     views: ["scrollView" : choosenView])
    )
    NSLayoutConstraint.activate(
      NSLayoutConstraint.constraints(withVisualFormat: "H:|[scrollView]|",
                                     options: [],
                                     metrics: nil,
                                     views: ["scrollView" : choosenView])
    )
    
    let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapTouch))
    choosenView.addGestureRecognizer(tapGestureRecognizer)
    choosenView.walletViewController = self;
    //To-Do: Check the ref address of both self.choosenView and choosenView
    self.choosenView = choosenView;
    
    //Logger.log(message: "------------- Breaking Constraints before this point can be ignored.");
  }
  
  func chooseSubView() -> BaseWalletView {
    switch viewMode {
    case ViewMode.PAPER_WALLET:
      self.title = "Paper Wallet";
      return PaperWalletView();
    case ViewMode.SETUP_WALLET:
      self.title = "Setup Your Wallet";
      return SetupWalletView()
    case ViewMode.NEW_SESSION:
        self.title = "Create Sesssion";
        return AddSessionView()
    case ViewMode.QR_CODE:
        self.title = "Scan QR-Code";
        return ScanQRCodeView()
    case ViewMode.SHOW_QR_CODE:
        self.title = "Show QR-Code"
        return ShowQRView()
    case ViewMode.ADD_DEVICE_WITH_MNEMONICS:
        return AddDeviceWithMnemonics()
    case ViewMode.SHOW_USER_DETAILS:
        self.title = "View Details"
        return UserDetailsView()
    case ViewMode.RESET_PIN:
        self.title = "Reset Pin"
        return ResetPinView()
    case ViewMode.RECOVER_DEVICE:
        self.title = "Recover device"
        return RecoverDeviceView()
    case ViewMode.ABORT_RECOVER_DEVICE:
        self.title = "Abort Recover device"
        return AbortRevocerDeviceView()
    case ViewMode.LOGOUT_ALL_SESSIONS:
        self.title = "Logout All Sessions"
        return LogoutAllSessions()
    case ViewMode.EXECUTE_TRANSACTION:
        self.title = "Execute Transaction"
        let view =  SendTokensToUserView()
        view.setToUser(toUser: toUser);
        return view
    }
  }
  
  // MARK: - Gesture Handling
  
  @objc func didTapTouch(sender: UIGestureRecognizer) {
    view.endEditing(true)
  }

  @objc func backItemTapped(sender: Any) {
    self.dismiss(animated: true, completion: nil)
  }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        self.choosenView?.viewDidAppearCallback();
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated);
        self.choosenView?.viewDidDisappearCallback();
    }
    
}
