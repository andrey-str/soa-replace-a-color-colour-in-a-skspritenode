//
//  ViewController.swift
//  replace-color-iphone
//
//  Created by  Andrey Streltsov on 21/04/16.
//  Copyright © 2016  Andrey Streltsov. All rights reserved.
//

import UIKit
import SpriteKit
import CoreGraphics

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let texture:SKTexture = SKTexture(imageNamed: "B2CkX.png")
        let image:UIImage = UIImage(CGImage: texture.CGImage())
        let color:SKColor = SKColor(red: 0, green: 0, blue: 0, alpha: 1.0)
        let color2 = SKColor(red: 0, green: 0, blue: 0, alpha: 0.0)
        let tolerance:CGFloat = 0.9
        
        let newImage = replaceColor(color, withColor:color2, image: image, tolerance: tolerance)
        
        let imv = UIImageView(frame: self.view.frame)
        imv.image = newImage
        imv.contentMode = .ScaleAspectFit
        self.view.addSubview(imv)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    func replaceColor(color:SKColor, withColor:SKColor, image:UIImage, tolerance:CGFloat) -> UIImage{
        
        let imageRef = image.CGImage
        let width = CGImageGetWidth(imageRef)
        let height = CGImageGetHeight(imageRef)
        
        let colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB)!
        
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width;
        let bitsPerComponent = 8
        let bitmapByteCount = bytesPerRow * height
        
        let rawData = UnsafeMutablePointer<UInt8>.alloc(bitmapByteCount)
        
        let context = CGBitmapContextCreate(rawData, width, height, bitsPerComponent, bytesPerRow, colorSpace,
                                            CGImageAlphaInfo.PremultipliedLast.rawValue | CGBitmapInfo.ByteOrder32Big.rawValue)
        
        let rc = CGRect(x: 0, y: 0, width: width, height: height)
        
        CGContextDrawImage(context, rc, imageRef)
        
        assert(CGColorGetNumberOfComponents(color.CGColor) == 4, "Must be RGBA colorspace")
    

        let withColorComponents = CGColorGetComponents(withColor.CGColor)
        let r2 = UInt8(withColorComponents[0] * 255)
        let g2 = UInt8(withColorComponents[1] * 255)
        let b2 = UInt8(withColorComponents[2] * 255)
        let a2 = UInt8(withColorComponents[3] * 255)
        
        
        var byteIndex = 0
        
        while byteIndex < bitmapByteCount {
            
            
            let red:CGFloat = CGFloat(rawData[byteIndex + 0])/255
            let green:CGFloat = CGFloat(rawData[byteIndex + 1])/255
            let blue:CGFloat = CGFloat(rawData[byteIndex + 2])/255
            let alpha:CGFloat = CGFloat(rawData[byteIndex + 3])/255
            
            let currentColor = SKColor(red: red, green: green, blue: blue, alpha: alpha);
            
            if compareColor(color, withColor: currentColor , withTolerance: tolerance) {
            
                rawData[byteIndex + 0] = r2
                rawData[byteIndex + 1] = g2
                rawData[byteIndex + 2] = b2
                rawData[byteIndex + 3] = a2
            }
            
            byteIndex = byteIndex + 4;
        }
        
        let imgref = CGBitmapContextCreateImage(context)
        let result = UIImage(CGImage: imgref!)
        
        rawData.destroy()
        
        
        
        return result
    }
    
    func compareColor(color:SKColor, withColor:SKColor, withTolerance:CGFloat) -> Bool {
    
        var r1: CGFloat = 0.0, g1: CGFloat = 0.0, b1: CGFloat = 0.0, a1: CGFloat = 0.0;
        var r2: CGFloat = 0.0, g2: CGFloat = 0.0, b2: CGFloat = 0.0, a2: CGFloat = 0.0;
        
        color.getRed(&r1, green: &g1, blue: &b1, alpha: &a1);
        withColor.getRed(&r2, green: &g2, blue: &b2, alpha: &a2);
        
        return fabs(r1 - r2) <= withTolerance &&
            fabs(g1 - g2) <= withTolerance &&
            fabs(b1 - b2) <= withTolerance &&
            fabs(a1 - a2) <= withTolerance;
    }
    
}

