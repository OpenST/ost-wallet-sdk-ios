/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

extension String {
    var qrCode: CIImage?  {
        let data = self.data(using: .isoLatin1, allowLossyConversion: false)
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else {
            return nil
        }
        
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("M", forKey: "inputCorrectionLevel")
        
        return filter.outputImage
    }
}

extension UIImage {
    var readQRCode: [String]? {
        guard let ciImage = self.ciImage else {
            return nil
        }
        let detector = CIDetector(ofType: CIDetectorTypeQRCode,
                                  context: nil,
                                  options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])
        
        let features = detector?.features(in: ciImage) ?? []
        
        return features.compactMap { feature in
            return (feature as? CIQRCodeFeature)?.messageString
        }
    }
}

extension CIImage {
    var readQRCode: [String]? {
        let detector = CIDetector(ofType: CIDetectorTypeQRCode,
                                  context: nil,
                                  options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])
        
        let features = detector?.features(in: self) ?? []
        
        return features.compactMap { feature in
            return (feature as? CIQRCodeFeature)?.messageString
        }
    }
}
