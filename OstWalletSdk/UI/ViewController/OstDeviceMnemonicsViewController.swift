/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

class OstDeviceMnemonicsViewController: OstBaseScrollViewController {
    
    class func newInstance(mnemonics: [String],
                           onClose: (() -> Void)? = nil) -> OstDeviceMnemonicsViewController {
        
        let instance = OstDeviceMnemonicsViewController()
        
        instance.mnemonics = mnemonics
        instance.onClose = onClose
        
        return instance
     }
    
    //MARK: - Components
    let titleLabel: OstH1Label = OstH1Label()
    let leadLabel: OstH3Label = OstH3Label()
    let mnemonicsContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.color(hex: "#f8f8f8")
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 6
        view.clipsToBounds = true
        
        return view
    }()
    let mnemonicsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = UIStackView.Alignment.fill
        stackView.spacing = 24
        stackView.backgroundColor = .blue
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }()
    let tcLabel: OstH4Label = OstH4Label()
    
    //MARK: - Properties
    var mnemonics: [String]? = nil
    var onClose: (() -> Void)? = nil
    
    override func configure() {
        super.configure()
        
        let deviceMnemonoicsVCConfig = OstContent.getShowDeviceMnemonicsVCConfig()
        
        titleLabel.updateAttributedText(data: deviceMnemonoicsVCConfig[OstContent.OstComponentType.titleLabel.getCompnentName()],
                                        placeholders: deviceMnemonoicsVCConfig[OstContent.OstComponentType.placeholders.getCompnentName()])
        
        leadLabel.updateAttributedText(data: deviceMnemonoicsVCConfig[OstContent.OstComponentType.infoLabel.getCompnentName()],
                                        placeholders: deviceMnemonoicsVCConfig[OstContent.OstComponentType.placeholders.getCompnentName()])
        
        tcLabel.updateAttributedText(data: deviceMnemonoicsVCConfig[OstContent.OstComponentType.bottomLabel.getCompnentName()],
                                       placeholders: deviceMnemonoicsVCConfig[OstContent.OstComponentType.placeholders.getCompnentName()])
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showMnemonics()
    }
    //MARK: - Add Subview
    override func addSubviews() {
        super.addSubviews()
        
        self.addSubview(titleLabel)
        self.addSubview(leadLabel)
        self.addSubview(mnemonicsContainer)
        mnemonicsContainer.addSubview(mnemonicsStackView)
        self.addSubview(tcLabel)
    }
    
    //MARK: - Add Layout Constraints
    override func addLayoutConstraints() {
        super.addLayoutConstraints()
        
        applyTitleLabelConstraints()
        
        applyLeadLabelConstraints()
        
        applyMnemonicsContainerConstraints()
        
        applyMnemonicsStackViewConstraints()
       
        applyTCLabelConstraints()
       
        let last = tcLabel
        last.bottomAlignWithParent()
    }
    
    func applyTitleLabelConstraints() {
        titleLabel.topAlignWithParent(multiplier: 1, constant: 20.0)
        titleLabel.applyBlockElementConstraints(horizontalMargin: 40)
    }
    
    func applyLeadLabelConstraints() {
        leadLabel.placeBelow(toItem: titleLabel)
        leadLabel.applyBlockElementConstraints(horizontalMargin: 40)
    }
    
    func applyMnemonicsContainerConstraints() {
        mnemonicsContainer.placeBelow(toItem: leadLabel)
        mnemonicsContainer.applyBlockElementConstraints(horizontalMargin: 24)
    }
    
    func applyMnemonicsStackViewConstraints() {
        mnemonicsStackView.topAlignWithParent(multiplier: 1, constant: 24.0)
        mnemonicsStackView.applyBlockElementConstraints(horizontalMargin: 40)
        mnemonicsStackView.bottomAlign(toItem: mnemonicsContainer, constant: -24)
    }
    
    func applyTCLabelConstraints() {
        tcLabel.placeBelow(toItem: mnemonicsContainer)
        tcLabel.applyBlockElementConstraints(horizontalMargin: 40)
    }
    
    //MARK: - Show Mnemonics
    func showMnemonics() {
        guard let mnemonicsArray = mnemonics else {
            return
        }
        let halfCount = Int(mnemonicsArray.count/2)
        
        for i in 0..<halfCount {
            
            let cell = getCellForMnemonics(mnemonics1: mnemonicsArray[i],
                                           mnemonics2: mnemonicsArray[i+halfCount],
                                           index: i+1,
                                           diff: halfCount)
            
            mnemonicsStackView.addArrangedSubview(cell)
        }
    }
    
    func getCellForMnemonics(mnemonics1: String,
                             mnemonics2: String,
                             index: Int,
                             diff: Int) -> UIView {
        
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        container.topAlignWithParent()
        container.applyBlockElementConstraints(horizontalMargin: 0)
        container.bottomAlignWithParent()
        
        let mnemonics1Label = OstH2Label(text: "\(index). \(mnemonics1)")
        mnemonics1Label.textAlignment = .left
        let mnemonics2Label = OstH2Label(text: "\(index+diff). \(mnemonics2)")
        mnemonics2Label.textAlignment = .left
        
        container.addSubview(mnemonics1Label)
        container.addSubview(mnemonics2Label)
        
        mnemonics1Label.topAlignWithParent()
        mnemonics1Label.leftAlignWithParent(multiplier: 1, constant: 0)
        mnemonics1Label.bottomAlign(toItem: container, relatedBy: .lessThanOrEqual)
        mnemonics1Label.setWidthFromWidth(toItem: container, multiplier: 0.45)

        
        mnemonics2Label.topAlign(toItem: mnemonics1Label)
        mnemonics2Label.rightAlignWithParent()
        mnemonics2Label.bottomAlign(toItem: container, relatedBy: .lessThanOrEqual)
        mnemonics2Label.setWidthFromWidth(toItem: container, multiplier: 0.45)
        
        return container
    }
    
    //MARK: - Actions
    override func tappedBackButton() {
        if nil != onClose {
            onClose?()
        }else {
            super.tappedBackButton()
        }
    }
}
