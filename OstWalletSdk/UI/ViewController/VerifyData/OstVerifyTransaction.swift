/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation
import BigInt

class OstVerifyTransaction: OstBaseViewController, OstJsonApiDelegate {
    
    class func newInstance(userId: String,
                           qrData: [String: Any],
                           authorizeCallback: (([String: Any]) -> Void)?,
                           cancelCallback: (() -> Void)?,
                           hideLoaderCallback: (() ->Void)?,
                           errorCallback:((OstError?) -> Void)?) -> OstVerifyTransaction {
        
        let vc = OstVerifyTransaction()
        
        vc.userId = userId
        vc.authorizeCallback = authorizeCallback
        vc.cancelCallback = cancelCallback
        vc.qrData = qrData
        vc.hideLoaderCallback = hideLoaderCallback
        vc.errorCallback = errorCallback
        
        return vc
    }

    var qrData: [String: Any]? {
        didSet {
            transferAmounts = qrData?["amounts"] as? [String] ?? []
            tokenHolderAddress = qrData?["token_holder_addresses"] as? [String] ?? []
            ruleName = qrData?["rule_name"] as? String ?? ""
            options = qrData?["options"] as? [String: Any] ?? [:]
        }
    }
    var authorizeCallback: (([String: Any]) -> Void)? = nil
    var cancelCallback: (() -> Void)? = nil
    var hideLoaderCallback: (() ->Void)?
    var errorCallback: ((OstError?) -> Void)? = nil
    
    //MARK: - QR Params
    var tokenHolderAddress: [String]? = nil
    //Autto value address
    var transferAmounts: [String]? = nil
    var ruleName: String? = nil
    var options: [String: Any]? = nil
    var ruleType: OstExecuteTransactionType? = nil
    
    var btTransferAmount: String = ""
    var fiatTransferAmount: String = ""
    
    var balance: [String: Any?]? = nil
    var pricePoint: [String: Any]? = nil
    
    var currentUser: OstUser? {
        return try? OstUser.getById(userId!)!
    }
    var token: OstToken? {
        guard let user = currentUser else {
            return nil
        }
        
        return try? OstToken.getById(user.tokenId!)!
    }
    
    let decimals: Int = 5
    
    //MARK: - Getter
    var currencyCode: String {
        
        if let cc = options?[OstExecuteTransaction.PAYLOAD_RULE_DATA_CURRENCY_CODE_ID_KEY] as? String{
            return cc
        }
        
        return OstConfig.getPricePointCurrencySymbol()
    }
    
    var currencySymbol: String {
        if let cs = options?[OstExecuteTransaction.PAYLOAD_RULE_DATA_SYMBOL_ID_KEY] as? String{
            return cs
        }
        
        return "$"
    }
    
    func convertToBaseUnit(for val: String) -> String {
        let ostVal = OstUtils.convertNum(amount: val,
                                         exponent: (-1 * OstUtils.toInt(token!.decimals!)!))
        return ostVal
    }
    
    //MARK: - Components
    let containerView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = UIColor.color( 255, 255, 255)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let leadLabel: OstH2Label = OstH2Label()
    let infoLabel: OstH3Label = OstH3Label()
    let actionButton: OstB1Button = OstB1Button()
    let cancelButton: OstB2Button = OstB2Button()

    let amountContainer: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = UIColor.color(248, 248, 248)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let amountLabel: OstH1Label = OstH1Label()
    let fiatAmountLabel: OstH4Label = OstH4Label()
    
    var containerTopAnchor: NSLayoutConstraint? = nil
    var containerBottomAnchor: NSLayoutConstraint? = nil
    
    //MARK: - View LC
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .clear
    
        fetchPricePoint()
    }

    override func configure() {
        super.configure()
        
        actionButton.addTarget(self, action: #selector(actionButtonTapped(_:)), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped(_:)), for: .touchUpInside)
        
        let viewConfig = OstContent.getExecuteTransactionVerifyDataVCConfig()
        
        leadLabel.updateAttributedText(data: viewConfig[OstContent.OstComponentType.leadLabel.getComponentName()],
                                       placeholders: viewConfig[OstContent.OstComponentType.placeholders.getComponentName()])
        infoLabel.updateAttributedText(data: viewConfig[OstContent.OstComponentType.infoLabel.getComponentName()],
                                       placeholders: viewConfig[OstContent.OstComponentType.placeholders.getComponentName()])
        
        setActionButtonText(pageConfig: viewConfig)
        setCancelButtonText(pageConfig: viewConfig)
    }
    
    func setActionButtonText(pageConfig: [String: Any]) {
        var buttonTitle = ""
        if let actionButton = pageConfig["accept_button"] as? [String: Any],
            let text = actionButton["text"] as? String {
            
            buttonTitle = text
        }
        
        actionButton.setTitle(buttonTitle, for: .normal)
    }
    
    func setCancelButtonText(pageConfig: [String: Any]) {
        var buttonTitle = ""
        if let actionButton = pageConfig["reject_button"] as? [String: Any],
            let text = actionButton["text"] as? String {
            
            buttonTitle = text
        }
        
        cancelButton.setTitle(buttonTitle, for: .normal)
    }
    
    
    //MARK: - Add Subviews
    override func addSubviews() {
        super.addSubviews()
        self.addSubview(containerView)
        
        containerView.addSubview(leadLabel)
        containerView.addSubview(infoLabel)
        
        containerView.addSubview(actionButton)
        containerView.addSubview(cancelButton)
        
        containerView.addSubview(amountContainer)
        
        amountContainer.addSubview(amountLabel)
        amountContainer.addSubview(fiatAmountLabel)
    }
    
    override func addLayoutConstraints() {
        super.addLayoutConstraints()
        
        addContainerViewConstraints()
        addLeadLabelConstraints()
        addInfoLabelConstraints()
        addAmountContainerConstraints()
        addAmountLabelConstaraints()
        addFiatAmountLabelConstraints()
        addActionButtonConstraints()
        addCancelButtonConstraints()
    }
    
    func addContainerViewConstraints() {
        containerView.leftAlignWithParent()
        containerView.rightAlignWithParent()
        containerTopAnchor = containerView.topAnchor.constraint(equalTo: containerView.superview!.bottomAnchor)
        containerTopAnchor?.isActive = true
        
        containerBottomAnchor = containerView.bottomAnchor.constraint(equalTo: containerView.superview!.bottomAnchor)
        containerBottomAnchor?.isActive = false
    }
    
    func addLeadLabelConstraints() {
        leadLabel.topAlignWithParent(multiplier: 1, constant: 25)
        leadLabel.applyBlockElementConstraints()
    }
    
    func addInfoLabelConstraints() {
        infoLabel.placeBelow(toItem: leadLabel, constant: 25)
        infoLabel.applyBlockElementConstraints()
    }
    
    func addAmountContainerConstraints() {
        amountContainer.placeBelow(toItem: infoLabel, constant: 25)
        amountContainer.applyBlockElementConstraints()
    }
    
    func addAmountLabelConstaraints() {
        amountLabel.topAlignWithParent(multiplier: 1, constant: 18)
        amountLabel.applyBlockElementConstraints()
    }
    
    func addFiatAmountLabelConstraints() {
        fiatAmountLabel.placeBelow(toItem: amountLabel, constant:4)
        fiatAmountLabel.applyBlockElementConstraints()
        fiatAmountLabel.bottomAlignWithParent(multiplier: 1, constant: -18)
    }
    
    func addActionButtonConstraints() {
        actionButton.placeBelow(toItem: amountContainer, constant: 25)
        actionButton.applyBlockElementConstraints()
    }
    
    func addCancelButtonConstraints() {
        cancelButton.placeBelow(toItem: actionButton, constant: 25)
        cancelButton.applyBlockElementConstraints()
        if #available(iOS 11.0, *) {
            cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -25).isActive = true
        } else {
            cancelButton.bottomAlignWithParent(multiplier: 1, constant: -25)
        }
    }
    
    //MARK: - Action
    @objc func actionButtonTapped(_ sender: Any) {
        if nil != qrData {
            sendAuthorizeCallback()
        }else {
            sendCanceCallback()
        }
    }
    
    @objc func cancelButtonTapped(_ sender: Any) {
        sendCanceCallback()
    }
    
    //MAKR: - Callbacks
    func dismissVC() {
         self.dismiss(animated: false, completion: nil)
    }
    
    func sendCanceCallback() {
        cancelCallback?()
        dismissVC()
    }
    
    func sendAuthorizeCallback() {
        authorizeCallback?(qrData!)
        dismissVC()
    }
    
    func sendErrorCallback(_ error: OstError?) {
        errorCallback?(error)
        dismissVC()
    }
    
    func sendHideLoaderCallback() {
        hideLoaderCallback?()
    }
    
    //MARK: - OstJsonApiDelegate
    func onOstJsonApiSuccess(data: [String : Any]?) {
        var isDataCorrect = false
        if let resultType = OstJsonApi.getResultType(apiData: data) {
            if "balance".caseInsensitiveCompare(resultType) == .orderedSame {
                balance = OstJsonApi.getResultAsDictionary(apiData: data)
                pricePoint = data?["price_point"] as? [String: Any]
                
                setTransactionAmount()
                showTransactionConfirmView()
                
                isDataCorrect = true
            }
        }
        
        if !isDataCorrect {
            let error = OstError("ui_vc_vd_vt_ojas_1", OstErrorCodes.OstErrorCode.unknown)
            sendErrorCallback(error)
        }
    }
    
    func onOstJsonApiError(error: OstError?, errorData: [String : Any]?) {
        sendErrorCallback(error)
    }
    
    //MAKR: - Processing
    func fetchPricePoint() {
        OstJsonApi.getBalanceWithPricePoint(forUserId: self.userId!, delegate: self)
    }
    
    func setTransactionAmount() {
        
        var totalAmount = BigInt(0)
        for amount in transferAmounts! {
            let bigIntAmount = BigInt(amount)!
            totalAmount += bigIntAmount
        }
        
        if OstExecuteTransactionType.DirectTransfer.getQRText().caseInsensitiveCompare(ruleName!) == .orderedSame {
            btTransferAmount = convertToBaseUnit(for: totalAmount.description)
            fiatTransferAmount = toFiat(value: btTransferAmount) ?? ""
            
        }else if OstExecuteTransactionType.Pay.getQRText().caseInsensitiveCompare(ruleName!) == .orderedSame {
            fiatTransferAmount = convertToBaseUnit(for:totalAmount.description)
            btTransferAmount = toBt(value: fiatTransferAmount) ?? ""
        }
    }
    
    var getFiatValue: Double? {
        guard let pricePoint = self.pricePoint else {
            return nil
        }
        
        if let ostToken: OstToken = token {
            let baseCurrency = ostToken.baseToken
            if let currencyPricePoint = pricePoint[baseCurrency] as? [String: Any],
                let strValue = OstUtils.toString(currencyPricePoint[currencyCode]) {
                return Double(strValue)
            }
        }
        return nil
    }
    
    func toFiat(value: String) -> String? {
        guard let fiatValue = getFiatValue,
            let doubleValue = Double(value) else {
                return nil
        }
        
        guard let conversionFactor = token?.conversionFactor,
            let doubleConversionFactor = Double(conversionFactor) else {
                
                return nil
        }
        
        let btToOstVal = (doubleValue/doubleConversionFactor)
        let finalVal = (fiatValue * btToOstVal).avoidNotation
        return finalVal
    }
    
    func toBt(value: String) -> String? {
        guard let ostToken = token else {
            return nil
        }
        let baseToken = ostToken.baseToken
        guard let btDecimal = ostToken.decimals,
            let conversionFactor = ostToken.conversionFactor,
            let fiatPricePoint = self.pricePoint?[baseToken] as? [String: Any],
            let fiatDecimal = OstUtils.toInt(fiatPricePoint["decimals"]) else {
                
                return nil
        }
        
        let pricePoint = String(format: "%@", fiatPricePoint[currencyCode] as! CVarArg)
        
        let btValue = try? OstConversion.fiatToBt(ostToBtConversionFactor: conversionFactor,
                                                  btDecimal: btDecimal,
                                                  fiatDecimal: fiatDecimal,
                                                  fiatAmount: BigInt(value)!,
                                                  pricePoint: pricePoint)
        
        return btValue?.description
    }
    
    func showTransactionConfirmView() {
        hideLoaderCallback?()

        let baseAmountVal = btTransferAmount.toDisplayTxValue(decimals: decimals)
        let baseFiatAmountVal = fiatTransferAmount.toDisplayTxValue(decimals: decimals)
        
        amountLabel.text = "\(baseAmountVal) \(token?.symbol ?? "")"
        fiatAmountLabel.text = "\(currencySymbol) \(baseFiatAmountVal)"
        
        containerTopAnchor?.isActive = false
        containerBottomAnchor?.isActive = true
        
        UIView.animate(withDuration: 0.3, animations: {[weak self] in
            self?.view.backgroundColor = UIColor.color(0, 0, 0, 0.5)
            self?.view.layoutIfNeeded()
        }, completion: nil)
    }
}
