//
//  CircularProgressBar.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics


@IBDesignable
class CircularProgressBar : UIView {
    
    @IBInspectable var progress: Double = 0.0 {
        didSet {
            if progress > 1.0 {
                progress = 1.0
            }
            if progress < 0 {
                progress = 0.0
            }
            progressBar.strokeEnd = CGFloat(progress)
        }
    }
    
    @IBInspectable var trackWidth: Double = 4 { didSet {} }
    @IBInspectable var trackColor: UIColor = UIColor.white { didSet {} }
    @IBInspectable var progressColor: UIColor = UIColor.blue { didSet {} }
    
    fileprivate var progressLayer = CAShapeLayer()
    fileprivate var progressBar = CAShapeLayer()
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    required override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    // MARK: drawing circular progress bar elements
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let circlePath = pathForCircle(inFrame: rect)
        
        let track = drawTrack(circlePath, aTrackWidth: trackWidth, aTrackColor: trackColor)
        layer.addSublayer(track)
        progressBar = drawProgressBar(circlePath, aTrackWidth: trackWidth, aColor: progressColor, aProgress: progress)
        layer.addSublayer(progressBar)
    }
    
    fileprivate func pathForCircle(inFrame frame: CGRect) -> UIBezierPath {
        let centerPoint = CGPoint(x: frame.width / 2, y: frame.width / 2)
        let circleRadius : CGFloat = frame.width / 2 - CGFloat(trackWidth)
        let path = UIBezierPath(arcCenter: centerPoint, radius: circleRadius, startAngle: CGFloat(-1 * M_PI), endAngle: CGFloat(1 * M_PI), clockwise: true)
        return path;
    }
    
    fileprivate func drawTrack(_ path: UIBezierPath, aTrackWidth: Double, aTrackColor: UIColor) -> CALayer {
        var track = CAShapeLayer()
        track = CAShapeLayer ()
        track.path = path.cgPath
        track.strokeColor = aTrackColor.cgColor
        track.fillColor = UIColor.clear.cgColor
        track.lineWidth = CGFloat(aTrackWidth)
        track.strokeStart = 0
        track.strokeEnd = 1
        track.lineCap = kCALineCapSquare
        track.rasterizationScale = 2.0
        track.shouldRasterize = true
        return track
    }
    
    fileprivate func contentFrame() -> CGRect {
        var contentFrame = self.frame
        contentFrame.origin = CGPoint.zero
        return contentFrame
    }
    
    fileprivate func drawProgressBar(_ path: UIBezierPath, aTrackWidth: Double, aColor: UIColor, aProgress: Double) -> CAShapeLayer {
        let bar = CAShapeLayer()
        bar.path = path.cgPath
        bar.strokeColor = aColor.cgColor
        bar.fillColor = UIColor.clear.cgColor
        bar.lineWidth = CGFloat(aTrackWidth)
        bar.strokeStart = 0
        bar.strokeEnd = CGFloat(aProgress)
        bar.lineCap = kCALineCapSquare
        bar.rasterizationScale = 2.0
        bar.shouldRasterize = true
        
        return bar
    }
}
