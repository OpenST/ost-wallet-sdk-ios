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

class UserCell:   MDCCardCollectionCell {
  
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var descriptionLabel: UILabel!
  
  func configureCell() {
    self.backgroundColor = .white
    
    self.nameLabel.font = ApplicationScheme.shared.typographyScheme.subtitle1
    self.descriptionLabel.font = ApplicationScheme.shared.typographyScheme.subtitle1

    //Set to 0 to disable the curved corners
    self.cornerRadius = 0.0;
    
    //TODO: Set Border Width to 0 to disable the stroke outline
    self.setBorderWidth(0.0, for:.normal)
    self.setBorderColor(.lightGray, for: .normal)
  }
    
    func addShadow() {
        self.shadowView.layer.cornerRadius = 10
        self.shadowView.layer.shadowColor = UIColor.lightGray.cgColor
        self.shadowView.layer.shadowOpacity = 0.4
        self.shadowView.layer.shadowRadius = 5
        self.shadowView.layer.shadowOffset = CGSize.zero
    }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    configureCell()
    addShadow()
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    configureCell()
  }
}
