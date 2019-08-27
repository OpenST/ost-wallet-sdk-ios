//
//  DeviceMnemonicsViewController.swift
//  TestDemoApp
//
//  Created by aniket ayachit on 29/04/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import UIKit
import OstWalletSdk

class DeviceMnemonicsViewController: BaseSettingOptionsSVViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    //MARK: - Components
    var collectionView: UICollectionView?
    var tipLabel: UILabel?
    
    //MARK: - Variables
    let collectionViewMargine: CGFloat = 10.0
    var mnemonicsArray = [String]()
    var leadLabelText: String = "These 12 words can recover your wallet if you forget your username and PIN."
    var tipLabelText: String = """
        Note: Enter these 12 words to recover your wallet if you forget your PIN. The order of the words is important, so please make sure to write it down carefully.
        """
    
    //MAKR: - Themer
    var tipLabelThemer: UILabel = OstUIKit.leadLabel()

    //MARK: - View Life Cycle

    override func getNavBarTitle() -> String {
        return "View Mnemonics"
    }
    
    override func getLeadLabelText() -> String {
        return leadLabelText
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let currentUser = CurrentUserModel.getInstance
        if nil != currentUser.ostUserId {
            OstWalletSdk.getDeviceMnemonics(userId: currentUser.ostUserId!,
                                            delegate: self.workflowDelegate)
        }
    }
    
    // MARK: - Create Views
    override func addSubviews() {
        super.addSubviews()
        createCollectionView()
        createTipLabel()
        addTapGesture()
    }
    
    func createCollectionView() {
        let collectioViewFlowLayout = UICollectionViewFlowLayout()
        collectioViewFlowLayout.minimumLineSpacing = 0.0
        let loCollectionView = UICollectionView(frame: .zero, collectionViewLayout: collectioViewFlowLayout)
        loCollectionView.delegate = self
        loCollectionView.dataSource = self
        loCollectionView.backgroundColor = UIColor.color(238, 245, 248)
        loCollectionView.clipsToBounds = true
        loCollectionView.allowsSelection = false
        loCollectionView.layer.cornerRadius = 7
        loCollectionView.contentInset = UIEdgeInsets(top: collectionViewMargine, left: collectionViewMargine, bottom: collectionViewMargine, right: collectionViewMargine)
        loCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        self.collectionView = loCollectionView
        svContentView.addSubview(loCollectionView)
        
        registerCollectionViewCell()
    }
    
    func registerCollectionViewCell() {
        collectionView?.register(MnemonicsCollectionViewCell.self, forCellWithReuseIdentifier: MnemonicsCollectionViewCell.cellIdentifier)
    }
    
    func createTipLabel() {
        let label = tipLabelThemer
        label.text = tipLabelText
        label.textAlignment = .left
        label.textColor = UIColor.color(136, 136, 136)
        label.font = OstTheme.fontProvider.get(size: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        tipLabel = label
        svContentView.addSubview(label)
    }
 
    func addTapGesture() {
        weak var weakSelf = self
        let tapGesture = UITapGestureRecognizer(target: weakSelf, action: #selector(weakSelf!.doubleTapGestureDetected) )
        tapGesture.numberOfTapsRequired = 2
        
        self.collectionView?.addGestureRecognizer(tapGesture)
    }
    
    @objc func doubleTapGestureDetected() {
        let mnemonicsString = self.mnemonicsArray.joined(separator: " ")
        UIPasteboard.general.string = mnemonicsString
    }
    
    
    
    //MARK: - Apply Constraints
    override func addLayoutConstraints() {
        super.addLayoutConstraints()
        applyCollectionViewConstraints()
        applyTipLabelConstraints()
    }
    
    
    func applyCollectionViewConstraints() {
        guard let parent = collectionView?.superview else {return}
        
        collectionView?.topAnchor.constraint(equalTo: leadLabel.bottomAnchor, constant: 26).isActive = true
        collectionView?.leftAnchor.constraint(equalTo: parent.leftAnchor, constant: 26).isActive = true
        collectionView?.rightAnchor.constraint(equalTo: parent.rightAnchor, constant: -26).isActive = true
        collectionView?.heightAnchor.constraint(equalToConstant: (44*6) + (2 * collectionViewMargine)).isActive = true
    }
    
    func applyTipLabelConstraints() {
        guard let parent = tipLabel?.superview else {return}
        
        tipLabel?.topAnchor.constraint(equalTo: collectionView!.bottomAnchor, constant: 16).isActive = true
        tipLabel?.leftAnchor.constraint(equalTo: parent.leftAnchor, constant: 26).isActive = true
        tipLabel?.rightAnchor.constraint(equalTo: parent.rightAnchor, constant: -26).isActive = true
        tipLabel?.bottomAnchor.constraint(equalTo: parent.bottomAnchor, constant: -26).isActive = true
    }
    
    //MARK: - Collection View
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mnemonicsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: MnemonicsCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: MnemonicsCollectionViewCell.cellIdentifier,
                                                                                   for: indexPath) as! MnemonicsCollectionViewCell
        let mnemonics: String
        let index: Int = indexPath.row+1
        
        if  !mnemonicsArray.isEmpty && mnemonicsArray.count >= indexPath.row  {
            mnemonics = mnemonicsArray[indexPath.row]
        }else {
            mnemonics = ""
        }
        cell.setCellData(mnemonics: mnemonics, index: index)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = (collectionView.frame.width/2) - (2*collectionViewMargine)
        return CGSize(width: cellWidth, height: 44)
    }
    
    //MAKR: - Sdk Interact Delegate
    override func flowComplete(workflowId: String, workflowContext: OstWorkflowContext, contextEntity: OstContextEntity) {
        super.flowComplete(workflowId: workflowId,
                           workflowContext: workflowContext,
                           contextEntity: contextEntity)
        
        if workflowContext.workflowType == .getDeviceMnemonics {
            self.mnemonicsArray.append(contentsOf: (contextEntity.entity as! [String]))
            self.collectionView?.reloadData()
        }
    }
    
    override func flowInterrupted(workflowId: String, workflowContext: OstWorkflowContext, error: OstError) {
        super.flowInterrupted(workflowId: workflowId,
                              workflowContext: workflowContext,
                              error: error)
        
        if workflowContext.workflowType == .getDeviceMnemonics {
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
}
