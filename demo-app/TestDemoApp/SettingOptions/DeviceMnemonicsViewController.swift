//
//  DeviceMnemonicsViewController.swift
//  TestDemoApp
//
//  Created by aniket ayachit on 29/04/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import UIKit
import OstWalletSdk

class DeviceMnemonicsViewController: BaseSettingOptionsViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    //MARK: - Components
    var titleLabel: UILabel?
    var collectionView: UICollectionView?
    var tipLabel: UILabel?
    
    //MARK: - Variables
    let collectionViewMargine: CGFloat = 30.0
    var mnemonicsArray = [String]()
    var leadLabelText: String = "Write down your 12-word mnemonic phrase and store them securely"
    var tipLabelText: String = """
        Tips:
        You can write the phrases down in a piece of paper or save in a password manager. Don’t email them or screenshot them. The order of words are important too.
        """
    
    //MAKR: - Themer
    var leadLabelThemer: UILabel = OstUIKit.lead()
    var tipLabelThemer: UILabel = OstUIKit.lead()
    
    
    override func getNavBarTitle() -> String {
        return "View Mnemonics"
    }
    
    //MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let currentUser = CurrentUser.getInstance()
        if nil != currentUser.ostUserId {
            let workflowCallback = SdkInteract.getInstance.getWorkflowCallback()
            SdkInteract.getInstance.subscribe(forWorkflowId: workflowCallback.workflowId, listner: self)
            OstWalletSdk.getDeviceMnemonics(userId: currentUser.ostUserId!, delegate: workflowCallback)
        }
    }
    
    // MARK: - Create Views
    override func createViews() {
        super.createViews()
        createLabel()
        createCollectionView()
        createTipLabel()
    }
    
    func createLabel() {
        let label = leadLabelThemer
        label.textAlignment = .left
        label.text = leadLabelText
        label.translatesAutoresizingMaskIntoConstraints = false
        label.sizeToFit()

        titleLabel = label
        contentView.addSubview(titleLabel!)
    }
    
    func createCollectionView() {
        let collectioViewFlowLayout = UICollectionViewFlowLayout()
        collectioViewFlowLayout.minimumLineSpacing = 0.0
        let loCollectionView = UICollectionView(frame: .zero, collectionViewLayout: collectioViewFlowLayout)
        loCollectionView.delegate = self
        loCollectionView.dataSource = self
        loCollectionView.backgroundColor = .gray
        loCollectionView.clipsToBounds = true
        loCollectionView.layer.cornerRadius = 7
        loCollectionView.contentInset = UIEdgeInsets(top: collectionViewMargine, left: collectionViewMargine, bottom: collectionViewMargine, right: collectionViewMargine)
        loCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        self.collectionView = loCollectionView
        contentView.addSubview(loCollectionView)
        
        registerCollectionViewCell()
    }
    
    func registerCollectionViewCell() {
        collectionView?.register(MnemonicsCollectionViewCell.self, forCellWithReuseIdentifier: MnemonicsCollectionViewCell.cellIdentifier)
    }
    
    func createTipLabel() {
        let label = tipLabelThemer
        label.text = tipLabelText
        label.translatesAutoresizingMaskIntoConstraints = false
        
        tipLabel = label
        contentView.addSubview(label)
    }
    
    //MARK: - Apply Constraints
    override func applyConstraints() {
        super.applyConstraints()
        applyTitleLabelConstraints()
        applyCollectionViewConstraints()
        applyTipLabelConstraints()
        
        applyContentViewBottomAnchor(with: self.tipLabel!)
    }
    
    func applyTitleLabelConstraints() {
        guard let parent = titleLabel?.superview else {return}
        titleLabel?.topAnchor.constraint(equalTo: parent.topAnchor, constant: 26).isActive = true
        titleLabel?.leftAnchor.constraint(equalTo: parent.leftAnchor, constant: 26).isActive = true
        titleLabel?.rightAnchor.constraint(equalTo: parent.rightAnchor, constant: -26).isActive = true
    }
    
    func applyCollectionViewConstraints() {
        guard let parent = collectionView?.superview else {return}
        
        collectionView?.topAnchor.constraint(equalTo: titleLabel!.bottomAnchor, constant: 26).isActive = true
        collectionView?.leftAnchor.constraint(equalTo: parent.leftAnchor, constant: 26).isActive = true
        collectionView?.rightAnchor.constraint(equalTo: parent.rightAnchor, constant: -26).isActive = true
        collectionView?.heightAnchor.constraint(equalToConstant: (44*6) + (2 * collectionViewMargine)).isActive = true
    }
    
    func applyTipLabelConstraints() {
        guard let parent = tipLabel?.superview else {return}
        
        tipLabel?.topAnchor.constraint(equalTo: collectionView!.bottomAnchor, constant: 16).isActive = true
        tipLabel?.leftAnchor.constraint(equalTo: parent.leftAnchor, constant: 26).isActive = true
        tipLabel?.rightAnchor.constraint(equalTo: parent.rightAnchor, constant: -26).isActive = true
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
        if workflowContext.workflowType == .getDeviceMnemonics {
            self.mnemonicsArray.append(contentsOf: (contextEntity.entity as! [String]))
            self.collectionView?.reloadData()
        }
    }
    
    override func flowInterrupted(workflowId: String, workflowContext: OstWorkflowContext, error: OstError) {
        
    }
}
