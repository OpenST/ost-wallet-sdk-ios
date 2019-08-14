/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

class OstEmptyDLTableViewCell: OstBaseTableViewCell {
    
    static var emptyDLCellIdentifier: String {
        return String(describing: OstEmptyDLTableViewCell.self)
    }
    
    //MARK: - Components
    let viewContainer: UIView = {
        let view = UIView(frame: .zero)
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let emptyDrawerImageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.contentMode = ContentMode.scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let descriptionText: OstH3Label = OstH3Label(text: "No devices found")
    
    //MARK: - Create views
    override func setValuesForComponents() {
        let image = UIImage(named: "ost_empty_drawer", in: Bundle(for: type(of: self)), compatibleWith: nil)!
        emptyDrawerImageView.image = image
    }
    
    override func createViews() {
        super.createViews()
        self.addSubview(viewContainer)
        viewContainer.addSubview(emptyDrawerImageView)
        viewContainer.addSubview(descriptionText)
    }
    
    override func applyConstraints() {
        super.applyConstraints()
        
        let parent = viewContainer.superview!
        viewContainer.topAlign(toItem: emptyDrawerImageView)
        viewContainer.leftAlign(toItem: parent)
        viewContainer.rightAlign(toItem: parent)
        viewContainer.centerYAlignWithParent()
        
        emptyDrawerImageView.centerXAlignWithParent()
        
        descriptionText.placeBelow(toItem: emptyDrawerImageView, constant: 16)
        descriptionText.applyBlockElementConstraints(horizontalMargin: 40)
        descriptionText.bottomAlign(toItem: viewContainer)
    }
}
