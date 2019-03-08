//
//  ImageCache.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation
import UIKit
import Bond
import ReactiveKit

final class ImageCache {
    
    static var CachesDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    
    static var memoryCache = NSCache<AnyObject, AnyObject>()
    
    static func getImage(_ url: String) -> UIImage? {
        
        if let cachedImage = memoryCache.object(forKey: url as AnyObject) as? UIImage {
            return cachedImage
        }
        let fm = FileManager.default
        if let fileName = url.toBase64() {
            let filePath = "\(CachesDirectory.appendingPathComponent(fileName).path ?? "").png"
            if fm.fileExists(atPath: filePath) {
                if let image = UIImage(contentsOfFile: filePath) {
                    self.memoryCache.setObject(image, forKey: url as AnyObject)
                    return image
                }
            }
        }
        return nil
    }
    
    static func saveImage(_ image: UIImage, url: String) -> SafeSignal<() -> URL?> {
        return SafeSignal { sink in
            if let data = UIImagePNGRepresentation(image) {
                DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async {
                    let fm = FileManager.default
                    if let fileName = url.toBase64() {
                        var auxPath = CachesDirectory
                        auxPath.appendPathComponent(fileName)
                        auxPath.appendPathExtension("png")
                        let filePath = auxPath.path
                            if !fm.fileExists(atPath:filePath) {
                                FileManager.default.createFile(atPath: filePath, contents: data, attributes: nil)
                                DispatchQueue.main.async {
                                    sink.completed(with: {
                                        return URL(fileURLWithPath: filePath)
                                    })
                                }
                            } else {
                                do {
                                    try data.write(to: auxPath, options: Data.WritingOptions.atomic)
                                    DispatchQueue.main.async {
                                        sink.completed(with: {
                                            return URL(fileURLWithPath: filePath)
                                        })
                                    }
                                } catch let error {
                                    
                                }
                                
                            }
                        
                    }
                    DispatchQueue.main.async {
                        sink.completed(with: {
                            return nil
                        })
                    }
                }
            }
            //return nil
            return BlockDisposable {}
        }
    }
}
