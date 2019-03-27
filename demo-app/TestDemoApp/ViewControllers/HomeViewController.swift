/*
 Copyright 2018-present the Material Components for iOS authors. All Rights Reserved.
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

import UIKit

import MaterialComponents

class HomeViewController: UICollectionViewController {
  var shouldDisplayLogin = true
  var appBar = MDCAppBar()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.view.tintColor = .black
    self.view.backgroundColor = .white
    
    self.title = "Token Economy"
    
    self.collectionView?.backgroundColor = .white
    
    // AppBar Init
    self.addChild(appBar.headerViewController)
    self.appBar.headerViewController.headerView.trackingScrollView = self.collectionView
    appBar.addSubviewsToParent()
    
    // Setup Navigation Items
    let menuImage = UIImage(named: "TuneItem")
    let templatedMenuImage = menuImage?.withRenderingMode(.alwaysTemplate)
    let menuItem = UIBarButtonItem(image: templatedMenuImage,
                                   style: .plain,
                                   target: nil,
                                   action: #selector(menuItemTapped(sender:)))
    self.navigationItem.rightBarButtonItems = [menuItem]
    
    // TODO: Theme our interface with our colors
    self.view.backgroundColor = ApplicationScheme.shared.colorScheme.surfaceColor
    self.collectionView?.backgroundColor = ApplicationScheme.shared.colorScheme.surfaceColor
    
    
    // TODO: Theme our interface with our typography
    self.view.backgroundColor = ApplicationScheme.shared.colorScheme.surfaceColor
    MDCAppBarColorThemer.applySemanticColorScheme(ApplicationScheme.shared.colorScheme, to:self.appBar)
    MDCAppBarTypographyThemer.applyTypographyScheme(ApplicationScheme.shared.typographyScheme, to: self.appBar)
    
    
    // Do any additional setup after loading the view, typically from a nib.
    let screenSize = UIScreen.main.bounds
    let screenWidth = screenSize.width;
//    let screenHeight = screenSize.height;
    
    let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    layout.sectionInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
    layout.itemSize = CGSize(width: screenWidth, height: screenWidth + 150)
    layout.minimumInteritemSpacing = 0
    layout.minimumLineSpacing = 0
    collectionView!.collectionViewLayout = layout
    
    //Set size of userImages.
    User.imageSize = CGFloat(screenWidth);
  }
  
  let activityView = UIActivityIndicatorView(style: .whiteLarge)
  var users:[User] = [];
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    
    let fadeView:UIView = UIView()
    fadeView.frame = self.view.frame
    fadeView.backgroundColor = UIColor.white
    fadeView.alpha = 0.4
    
    self.view.addSubview(fadeView)
    
    self.view.addSubview(activityView)
    activityView.hidesWhenStopped = true
    activityView.center = self.view.center
    activityView.startAnimating()
    
    if (self.collectionViewLayout is UICollectionViewFlowLayout) {
      let flowLayout = self.collectionViewLayout as! UICollectionViewFlowLayout
      let HORIZONTAL_SPACING: CGFloat = 8.0
      let itemDimension: CGFloat = (self.view.frame.size.width - 3.0 * HORIZONTAL_SPACING) * 0.5
      let itemSize = CGSize(width: itemDimension, height: itemDimension)
      flowLayout.itemSize = itemSize
    }
    
    if (self.shouldDisplayLogin) {
        showLoginViewController()
    }
    
    DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {
      Users.getInstance().getUsers(onComplete: { (users: Array<User>) in
        self.users = users;
        DispatchQueue.main.async {
//          let layout = self.collectionView?.collectionViewLayout as! HomeCustomLayout;
//          layout.prepareToDisplayUsers();
          
          UIView.animate(withDuration: 1, delay: 1, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
            self.collectionView?.reloadData()
            self.collectionView?.alpha = 1
            fadeView.removeFromSuperview()
            self.activityView.stopAnimating()
          }, completion: nil)
        }
      }, onError: {
        fadeView.removeFromSuperview()
        self.activityView.stopAnimating()
      })
    }
  }
    
    func showLoginViewController(animated: Bool = false) {
        let loginViewController = LoginViewController(nibName: nil, bundle: nil)
        self.present(loginViewController, animated: animated, completion: nil)
        self.shouldDisplayLogin = false
    }
  
  //MARK - Methods
  @objc func menuItemTapped(sender: Any) {
    let layout = UICollectionViewFlowLayout();
    let userActionsViewController = UserActionsViewController(collectionViewLayout: layout);
    self.present(userActionsViewController, animated: true, completion: nil);
  }
  
  //MARK - UICollectionViewDataSource
  override func collectionView(_ collectionView: UICollectionView,
                               numberOfItemsInSection section: Int) -> Int {
    let count = self.users.count
    return count
  }
  
  override func collectionView(_ collectionView: UICollectionView,
                               cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = self.collectionView?.dequeueReusableCell(withReuseIdentifier: "UserCell",
                                                        for: indexPath) as! UserCell
    let user:User = self.users[indexPath.row];
    cell.imageView.image = UIImage(cgImage: user.userImage);
    cell.nameLabel.text = user.displayName!;
    cell.descriptionLabel.text = user.description;
    return cell
  }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let user:User = self.users[indexPath.row];
        let walletController = WalletViewController(nibName: nil, bundle: nil)
        walletController.showHeaderBackItem = true;
        walletController.toUser = user;
        walletController.viewMode = WalletViewController.ViewMode.EXECUTE_TRANSACTION;
        self.present(walletController, animated: true, completion: nil);
    }
}

//MARK: - UIScrollViewDelegate

// The following four methods must be forwarded to the tracking scroll view in order to implement
// the Flexible Header's behavior.

extension HomeViewController {
  
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
