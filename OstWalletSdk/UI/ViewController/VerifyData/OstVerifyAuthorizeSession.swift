/*
Copyright © 2019 OST.com Inc

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0
*/

import Foundation

class OstVerifyAuthorizeSession: OstBaseViewController {
	class func newInstance(session: OstSession,
						   authorizeCallback: ((OstSession) -> Void)?,
						   cancelCallback: (() -> Void)?) -> OstVerifyAuthorizeSession {
		
		let vc = OstVerifyAuthorizeSession()
		
		vc.authorizeCallback = authorizeCallback
		vc.cancelCallback = cancelCallback
		vc.session = session
		
		return vc
	}
	
	var session: OstSession? = nil
	var authorizeCallback: ((OstSession) -> Void)? = nil
	var cancelCallback: (() -> Void)? = nil
	
	//MARK: - Components
	let containerView: UIView = {
		let view = UIView(frame: .zero)
		view.backgroundColor = UIColor.color( 255, 255, 255)
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	let leadLabel: OstH2Label = OstH2Label()
	let sessionDetailsContainer: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = UIColor.color(248, 248, 248)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
	var stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.alignment = UIStackView.Alignment.leading
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
	let actionButton: OstB1Button = OstB1Button()
	let cancelButton: OstB2Button = OstB2Button()
	
	var containerTopAnchor: NSLayoutConstraint? = nil
	var containerBottomAnchor: NSLayoutConstraint? = nil
	
	//MARK: - View LC
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.view.backgroundColor = .clear
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		let addressView = getSessionDetailView(heading: "Session Address", text: session!.address!)
		stackView.addArrangedSubview(addressView)
		
		let spendingLimit = session!.toHeighestUnitSpendingLimit() ?? session!.spendingLimit!.description
		var tokenSymbol = ""
		if let user = try? OstUser.getById(session!.userId ?? ""),
			let tokenId = user?.tokenId,
			let token = try? OstToken.getById(tokenId) {
			
			tokenSymbol = token?.symbol ?? ""
		}
		
		let spendingLimitView = getSessionDetailView(heading: "Spending Amount", text: "\(spendingLimit) \(tokenSymbol)")
		stackView.addArrangedSubview(spendingLimitView)
		
		let date = Date(timeIntervalSince1970: session!.approxExpirationTimestamp)
		let dateFormatterGet = DateFormatter()
		dateFormatterGet.dateFormat = "dd-MM-yyyy HH:mm:ss"
		
		let expirationTimeView = getSessionDetailView(heading: "Expiry Date",
												  text: dateFormatterGet.string(from: date))
		stackView.addArrangedSubview(expirationTimeView)
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		containerTopAnchor?.isActive = false
		containerBottomAnchor?.isActive = true
		
		UIView.animate(withDuration: 0.3, animations: {[weak self] in
			self?.view.backgroundColor = UIColor.color(0, 0, 0, 0.5)
			self?.view.layoutIfNeeded()
			}, completion: nil)
	}
	
	override func configure() {
		super.configure()
		
		
		let viewConfig = OstContent.getAuthorizeSessionVerifyDataVCConfig()
		
		leadLabel.updateAttributedText(data: viewConfig[OstContent.OstComponentType.leadLabel.getComponentName()],
									   placeholders: viewConfig[OstContent.OstComponentType.placeholders.getComponentName()])
		
		actionButton.addTarget(self, action: #selector(actionButtonTapped(_:)), for: .touchUpInside)
		cancelButton.addTarget(self, action: #selector(cancelButtonTapped(_:)), for: .touchUpInside)
		
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
		containerView.addSubview(sessionDetailsContainer)
		
		sessionDetailsContainer.addSubview(stackView);
		
		containerView.addSubview(actionButton)
		containerView.addSubview(cancelButton)
	}
	
	override func addLayoutConstraints() {
        super.addLayoutConstraints()
        
        addContainerViewConstraints()
        addLeadLabelConstraints()
		addSessionDetailsContainerConstraints()
		addStackViewConstraints()
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
        leadLabel.applyBlockElementConstraints(horizontalMargin: 40)
    }
	
	func addSessionDetailsContainerConstraints() {
        sessionDetailsContainer.placeBelow(toItem: leadLabel, constant: 25)
        sessionDetailsContainer.applyBlockElementConstraints()
    }
	
	func addStackViewConstraints() {
		stackView.topAlignWithParent(multiplier: 1, constant: 25)
		stackView.leftAlignWithParent(multiplier: 1, constant: 5)
		stackView.rightAlignWithParent(multiplier: 1, constant: -5)
		stackView.bottomAlignWithParent()
	}
    
    func addActionButtonConstraints() {
        actionButton.placeBelow(toItem: sessionDetailsContainer, constant: 25)
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
	
	//MARK: - Session Details
	func getSessionDetailView(heading: String,
							  text: String) -> UIView {
        
		let container = UIView()
        
        let headingLabel = OstC2Label()
        let textLabel = OstC1Label()
        
        headingLabel.text = heading
        textLabel.text = text
        
        container.addSubview(headingLabel)
        container.addSubview(textLabel)
        
        headingLabel.topAlignWithParent()
        headingLabel.leftAlignWithParent()
        headingLabel.rightAlignWithParent()
        
		textLabel.placeBelow(toItem: headingLabel, constant: 5)
		textLabel.leftAlignWithParent()
		textLabel.rightAlignWithParent()
		textLabel.bottomAlignWithParent(multiplier: 1, constant: -20)
        
        return container
    }
	
	//MARK: - Action
	@objc func actionButtonTapped(_ sender: Any) {
		if nil != session {
			authorizeCallback?(session!)
		}else {
			cancelCallback?()
		}
		dismissVC()
	}
	
	@objc func cancelButtonTapped(_ sender: Any) {
		cancelCallback?()
		dismissVC()
	}
	
	func dismissVC() {
		self.dismiss(animated: false, completion: nil)
	}
}
