//
//  Extensions.swift
//  Note
//
//  Created by Ян Нурков on 30.01.2023.
//

import Foundation
import UIKit

// MARK: - ExtensionNSData

extension NSData {
    func toAttributedString() -> NSAttributedString? {
        let data = Data(referencing: self)
        let options : [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.rtfd,
            .characterEncoding: String.Encoding.utf8
        ]
        
        return try? NSAttributedString(data: data,
                                       options: options,
                                       documentAttributes: nil)
    }
}

// MARK: - ExtensionsNSAttributedString

extension NSAttributedString {
    func toNSData() -> NSData? {
        let options : [NSAttributedString.DocumentAttributeKey: Any] = [
            .documentType: NSAttributedString.DocumentType.rtfd,
            .characterEncoding: String.Encoding.utf8
        ]
        
        let range = NSRange(location: 0, length: length)
        guard let data = try? data(from: range, documentAttributes: options) else {
            return nil
        }
        
        return NSData(data: data)
    }
    
    convenience init?(base64EndodedImageString encodedImageString: String) {
        let html = """
        <!DOCTYPE html>
        <html>
          <body>
            <img src="data:image/png;base64,\(encodedImageString)">
          </body>
        </html>
        """
        let data = Data(html.utf8)
        let options: [NSAttributedString.DocumentReadingOptionKey : Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        try? self.init(data: data, options: options, documentAttributes: nil)
    }
}

// MARK: - ExtensionUIImage

extension UIImage {
    func resized(toWidth width: CGFloat) -> UIImage? {
        let height = CGFloat(ceil(width / size.width * size.height))
        let canvasSize = CGSize(width: width, height: height)
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
