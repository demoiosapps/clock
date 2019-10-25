//
//  ClockView.swift
//  ClockView
//
//  Created by R on 25.10.2019.
//  Copyright © 2019 R. All rights reserved.
//

import UIKit

final class ClockView: UIView {
    
    // Storyboard
    @IBInspectable var autostart: Bool = true
    @IBInspectable var showMarkers: Bool = true { didSet { define() }}
    @IBInspectable var showSecondHand: Bool = true { didSet { define() }}
    @IBInspectable var faceColor: UIColor = .white { didSet { define() }}
    @IBInspectable var borderColor: UIColor = .lightGray { didSet { define() }}
    @IBInspectable var fiveMarkerColor: UIColor = .black { didSet { define() }}
    @IBInspectable var oneMarkerColor: UIColor = .red { didSet { define() }}
    @IBInspectable var hourHandColor: UIColor = .black { didSet { define() }}
    @IBInspectable var minuteHandColor: UIColor = .black { didSet { define() }}
    @IBInspectable var secondHandColor: UIColor = .red { didSet { define() }}
    @IBInspectable var borderThickness: CGFloat = 1 { didSet { define() }}
    @IBInspectable var fiveMarkerHeight: CGFloat = 10 { didSet { define() }}
    @IBInspectable var oneMarkerHeight: CGFloat = 5 { didSet { define() }}
    @IBInspectable var fiveMarkerThickness: CGFloat = 5 { didSet { define() }}
    @IBInspectable var oneMarkerThickness: CGFloat = 1 { didSet { define() }}
    @IBInspectable var hourHandThickness: CGFloat = 5 { didSet { define() }}
    @IBInspectable var minuteHandThickness: CGFloat = 5 { didSet { define() }}
    @IBInspectable var secondHandThickness: CGFloat = 1 { didSet { define() }}

    private var startTime: Date?
    private var faceLayer: CALayer?
    private var roundLayer: CAShapeLayer!
    private var hourHandLayer: CALayer!
    private var minuteHandLayer: CALayer!
    private var secondHandLayer: CALayer!

    override var bounds: CGRect { didSet { define() }}

    // MARK: - Action
    
    func start(time: Date? = nil) {
        startTime = time ?? Date()
        updateHands()
    }
    
    func stop() {
        clear()
    }
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        define()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        define()
    }
    
    private func define() {
        clear()
        if startTime != nil {
            startTime = startTime?.addingTimeInterval(-startTime!.timeIntervalSinceNow)
            updateHands()
        } else if autostart {
            start()
        }
    }
    
    private func clear() {
        if faceLayer != nil {
            faceLayer!.removeFromSuperlayer()
            faceLayer = nil
        }
        createFace()
        createHands()
    }
    
    private func createFace() {
        let radius = frame.width > frame.height ? frame.height / 2 : frame.width / 2
        let frame = CGRect(
            x: self.frame.width > self.frame.height ? self.frame.width / 2 - radius : 0,
            y: self.frame.width < self.frame.height ? self.frame.height / 2 - radius : 0,
            width: radius * 2,
            height: radius * 2)

        faceLayer = CALayer()
        faceLayer!.frame = frame
        layer.addSublayer(faceLayer!)

        roundLayer = CAShapeLayer()
        roundLayer.lineWidth = borderThickness
        roundLayer.fillColor = faceColor.cgColor
        roundLayer.strokeColor = borderColor.cgColor
        roundLayer.path = UIBezierPath(
            arcCenter: CGPoint(x: frame.size.width / 2, y: frame.size.height / 2),
            radius: radius,
            startAngle: 0,
            endAngle: .pi * 2,
            clockwise: true).cgPath

        faceLayer!.addSublayer(roundLayer)

        if showMarkers {
            let markerFrame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)

            faceLayer!.addSublayer(markerLayer(
                frame: markerFrame,
                count: 60 / 1,
                thickness: oneMarkerThickness,
                height: oneMarkerHeight,
                color:  oneMarkerColor))
            
            faceLayer!.addSublayer(markerLayer(
                frame: markerFrame,
                count: 60 / 5,
                thickness: fiveMarkerThickness,
                height: fiveMarkerHeight,
                color:  fiveMarkerColor))
        }
    }
    
    private func markerLayer(frame: CGRect, count: Int, thickness: CGFloat, height: CGFloat, color: UIColor) -> CAReplicatorLayer {
        let replicatorLayer = CAReplicatorLayer()
        replicatorLayer.frame = frame
        
        replicatorLayer.instanceCount = count
        let angle: CGFloat = .pi * 2 / CGFloat(count)
        replicatorLayer.instanceTransform = CATransform3DMakeRotation(angle, 0, 0, 1)
        
        let instanceLayer = CALayer()
        instanceLayer.frame = CGRect(x: frame.midX - thickness / 2, y: 0, width: thickness, height: height)
        instanceLayer.backgroundColor = color.cgColor
        replicatorLayer.addSublayer(instanceLayer)
        
        return replicatorLayer
    }
        
    private func createHands() {
        hourHandLayer = handLayer(
            thickness: hourHandThickness,
            height: 0.3,
            color: hourHandColor)
        roundLayer.addSublayer(hourHandLayer)

        minuteHandLayer = handLayer(
            thickness: minuteHandThickness,
            height: 0.4,
            color: minuteHandColor)
        roundLayer.addSublayer(minuteHandLayer)

        if showSecondHand {
            secondHandLayer = handLayer(
                thickness: secondHandThickness,
                height: 0.5,
                color: secondHandColor)
            roundLayer.addSublayer(secondHandLayer)
        }
    }
    
    private func handLayer(thickness: CGFloat, height: CGFloat, color: UIColor) -> CALayer {
        let layer = CALayer()
        layer.position = CGPoint(x: faceLayer!.frame.width / 2, y: faceLayer!.frame.height / 2)
        layer.anchorPoint = CGPoint(x: 0.5, y: 0.15)
        layer.bounds = CGRect(x: 0, y: 0, width: thickness, height: faceLayer!.frame.width * height)
        layer.backgroundColor = color.cgColor
        return layer
    }

    
    // MARK: - Update
    
    private func updateHands() {
        let calendar = Calendar.current
        let hours = calendar.component(.hour, from: startTime!)
        let minutes = calendar.component(.minute, from: startTime!)
        let seconds = calendar.component(.second, from: startTime!)
        
        animateHand(
            layer: hourHandLayer,
            angle: (CGFloat(hours) + CGFloat(minutes) * (1 / 60)) * (360 / 12),
            duration: 60 * 60 * 12,
            for: "hour")

        animateHand(
            layer: minuteHandLayer,
            angle: (CGFloat(minutes) + CGFloat(seconds) * (1 / 60)) * (360 / 60),
            duration: 60 * 60,
            for: "minute")
        
        if showSecondHand {
            animateHand(
                layer: secondHandLayer,
                angle: CGFloat(seconds) * (360 / 60),
                duration: 60,
                for: "second")
        }
    }
    
    private func animateHand(layer: CALayer, angle: CGFloat, duration: Double, for key: String) {
        layer.transform = CATransform3DMakeRotation(angle / 180 * .pi, 0, 0, 1)
        let secondAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        secondAnimation.repeatCount = .infinity
        secondAnimation.duration = duration
        secondAnimation.isRemovedOnCompletion = false
        secondAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        secondAnimation.fromValue = (angle + 180) * .pi / 180
        secondAnimation.byValue = 2 * CGFloat.pi
        layer.add(secondAnimation, forKey: key)
    }
}
