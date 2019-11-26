/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import UIKit
import OstWalletSdk

class OstMockLoaderViewController: UIViewController, OstWorkflowLoader {
   
    //MARK: - Progress Components
    let progressImageView: UIImageView  = {
        let imageView = UIImageView(frame: .zero)
		let imageData = try? Data(contentsOf: Bundle.main.url(forResource: "OstProgressImage", withExtension: "gif")!)
		let advTimeGif = UIImage.gifImageWithData(imageData!)
		imageView.image = advTimeGif
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let messageLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textColor = .white
        label.text = "Processing..."
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    let progressContainerView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .clear
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    //MARK: - Alert Components
    let alertContainerView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .clear
        view.clipsToBounds = true
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    let alertIcon: UIImageView  = {
        let imageView = UIImageView(frame: .zero)
        imageView.image = UIImage(named: "")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let alertMessageLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textColor = .white
        label.text = ""
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    let dismissButton: UIButton = {
        let button = UIButton()
        
        button.backgroundColor = UIColor(red: (255/255),green: (116/255), blue: (153/255), alpha: 1)
        button.layer.cornerRadius = 5
        button.setTitleColor(.white, for: .normal)
        button.clipsToBounds = true
        button.contentEdgeInsets = UIEdgeInsets(top: 5, left: 14, bottom: 5, right: 14)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    //MARK: - Variables
    var ostloaderCompletionDelegate: OstLoaderCompletionDelegate? = nil
    var isAlertView: Bool = false
    
    //MARK: - View Life Cycle
    deinit {
        print("\(String(describing: self)) :: deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        config()
        addSubviews()
        addLayoutConstraints()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        UIView.transition(with: self.view, duration: 0.3, options: .transitionCrossDissolve, animations: {[weak self] in
          self?.view.isHidden = false
        }, completion: {[weak self] (_) in
            self?.animateLoader()
        })
    }
    
    func config() {
        self.view.isHidden = true
        
        dismissButton.addTarget(self, action: #selector(dismissButtonTapped(_:)), for: .touchUpInside)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        tap.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(tap)
    }
    
    func addSubviews() {
        self.view.addSubview(progressContainerView)
        self.view.addSubview(alertContainerView)
        
        //Progress view
        progressContainerView.addSubview(progressImageView)
        progressContainerView.addSubview(messageLabel)
        
        //Alert view
        alertContainerView.addSubview(alertIcon)
        alertContainerView.addSubview(alertMessageLabel)
        alertContainerView.addSubview(dismissButton)
        
    }
    
    //MARK: - Actions
    @objc
    func dismissButtonTapped(_ sender: Any) {
        closeLoader()
    }
    
    @objc
    func closeLoader() {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(closeLoader), object: nil)
        UIView.transition(with: self.view, duration: 0.3, options: .transitionCrossDissolve, animations: {[weak self] in
		  self?.view.isHidden = true
		}) {[weak self] (_) in
			self?.ostloaderCompletionDelegate?.dismissWorkflow()
		}
    }
    
    @objc
    func viewTapped() {
        if isAlertView {
            closeLoader()
        }
    }
    
    //MARK: - Add Layout
    func addLayoutConstraints() {
        //Progress Container
        containerViewConstraints()
        progressImageViewConstraints()
        messageLabelConstraints()
        
        let lastView = messageLabel
		lastView.bottomAnchor.constraint(equalTo: lastView.superview!.bottomAnchor).isActive = true
        
        //Alert Container
        alertContainerViewConstraints()
        alertIconViewConstraints()
        alertMessageLabelConstraints()
        dismissButtonConstraints()
        
        let alertLastView = dismissButton
		alertLastView.bottomAnchor.constraint(equalTo: alertLastView.superview!.bottomAnchor).isActive = true
    }
    
    func containerViewConstraints() {
		guard let parent = progressContainerView.superview else {return}
		
		progressContainerView.leftAnchor.constraint(equalTo: parent.leftAnchor).isActive = true
		progressContainerView.rightAnchor.constraint(equalTo: parent.rightAnchor).isActive = true
		progressContainerView.centerYAnchor.constraint(equalTo: parent.centerYAnchor).isActive = true
    }
    
    func progressImageViewConstraints() {
		guard let parent = progressImageView.superview else {return}

		progressImageView.topAnchor.constraint(equalTo: progressContainerView.topAnchor, constant: 10).isActive = true
		progressImageView.centerXAnchor.constraint(equalTo: parent.centerXAnchor).isActive = true
    		progressImageView.widthAnchor.constraint(equalToConstant: 50).isActive = true
	 	progressImageView.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    func messageLabelConstraints() {
		guard let parent = messageLabel.superview else {return}
		
		messageLabel.topAnchor.constraint(equalTo: progressImageView.bottomAnchor, constant: 10).isActive = true
        messageLabel.leftAnchor.constraint(equalTo: parent.leftAnchor, constant: 10).isActive = true
		messageLabel.rightAnchor.constraint(equalTo: parent.rightAnchor, constant: -10).isActive = true
    }
   
    //MARK: - Alert Constraints
    func alertContainerViewConstraints() {
		guard let parent = alertContainerView.superview else {return}
		
		alertContainerView.leftAnchor.constraint(equalTo: parent.leftAnchor).isActive = true
		alertContainerView.rightAnchor.constraint(equalTo: parent.rightAnchor).isActive = true
		alertContainerView.centerYAnchor.constraint(equalTo: parent.centerYAnchor).isActive = true
    }
    
    func alertIconViewConstraints() {
		guard let parent = alertIcon.superview else {return}
		
		alertIcon.topAnchor.constraint(equalTo: alertContainerView.topAnchor).isActive = true
		alertIcon.centerXAnchor.constraint(equalTo: parent.centerXAnchor).isActive = true
    }
    
    func alertMessageLabelConstraints() {
		guard let parent = alertMessageLabel.superview else {return}
		
		alertMessageLabel.topAnchor.constraint(equalTo: alertIcon.bottomAnchor, constant: 10).isActive = true
        alertMessageLabel.leftAnchor.constraint(equalTo: parent.leftAnchor, constant: 10).isActive = true
		alertMessageLabel.rightAnchor.constraint(equalTo: parent.rightAnchor, constant: -10).isActive = true
    }
    
    func dismissButtonConstraints() {
		guard let parent = dismissButton.superview else {return}
		
		dismissButton.topAnchor.constraint(equalTo: alertMessageLabel.bottomAnchor, constant: 15).isActive = true
		dismissButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
		dismissButton.centerXAnchor.constraint(equalTo: parent.centerXAnchor).isActive = true
    }
    
    //MARK: - Animate
    func animateLoader() {
        
    }
    
	//MARK: - Pepo Alert
    func closeProgressAnimation() {
        isAlertView = true
        
        progressContainerView.isHidden = true
        alertContainerView.isHidden = false
    }
    
    func showSuccessAlert(workflowContext: OstWorkflowContext,
                          contextEntity: OstContextEntity?) {
        closeProgressAnimation()
        
        alertIcon.image = UIImage(named: "OstSuccessAlertIcon")
		let successMessage = OstSdkMessageHelper.shared.getSuccessMessage(for: workflowContext)
		alertMessageLabel.text = successMessage
		
        dismissButton.isHidden = true

        perform(#selector(closeLoader), with: nil, afterDelay: 4)
        
        view.layoutIfNeeded()
    }
    
    func showFailureAlert(workflowContext: OstWorkflowContext,
                          error: OstError) {
        closeProgressAnimation()
        
        alertIcon.image = UIImage(named: "OstFailureAlertIcon")
		let errorMessage = OstSdkMessageHelper.shared.getErrorMessage(for: workflowContext, andError: error)
		alertMessageLabel.text = errorMessage
        dismissButton.setTitle("Close", for: .normal)
        
        self.alertContainerView.layoutIfNeeded()
    }
    
    
    //MARK: - OstWorkflowLoader
    func onInitLoader(workflowConfig: [String: Any]) {
        var loaderString: String = "Initializing..."
        
        if let initLoaderData = workflowConfig["initial_loader"] as? [String: String],
            let text = initLoaderData["text"] {
            loaderString = text
        }
        messageLabel.text = loaderString
    }
    
    func onPostAuthentication(workflowConfig: [String: Any]) {
        var loaderString: String = "Processing..."
        
        if let initLoaderData = workflowConfig["loader"] as? [String: String],
            let text = initLoaderData["text"] {
            loaderString = text
        }
        messageLabel.text = loaderString
    }
    
    func onAcknowledge(workflowConfig: [String: Any]) {
		var loaderString: String = "Waiting for confirmation..."
        
        if let initLoaderData = workflowConfig["acknowledge"] as? [String: String],
            let text = initLoaderData["text"] {
            loaderString = text
        }
        messageLabel.text = loaderString
    }
    
    func onSuccess(workflowContext: OstWorkflowContext,
                   contextEntity: OstContextEntity,
                   workflowConfig: [String : Any],
                   loaderCompletionDelegate: OstLoaderCompletionDelegate) {
        
        ostloaderCompletionDelegate = loaderCompletionDelegate
        
        showSuccessAlert(workflowContext: workflowContext,
                         contextEntity: contextEntity)
    }
    
    func onFailure(workflowContext: OstWorkflowContext,
                   error: OstError,
                   workflowConfig: [String : Any],
                   loaderCompletionDelegate: OstLoaderCompletionDelegate) {
        
        ostloaderCompletionDelegate = loaderCompletionDelegate
        
        showFailureAlert(workflowContext: workflowContext,
                         error: error)
    }
}
