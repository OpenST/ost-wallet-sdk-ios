//
//  Extension + OstQRCode.swift
//  OstSdk
//
//  Created by aniket ayachit on 11/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

extension String {
    public var qrCode: CIImage?  {
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
    public var readQRCode: [String]? {
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
    public var readQRCode: [String]? {
        let detector = CIDetector(ofType: CIDetectorTypeQRCode,
                                  context: nil,
                                  options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])
        
        let features = detector?.features(in: self) ?? []
        
        return features.compactMap { feature in
            return (feature as? CIQRCodeFeature)?.messageString
        }
    }
}
