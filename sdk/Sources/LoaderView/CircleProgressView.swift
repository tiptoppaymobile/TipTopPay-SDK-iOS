//
//  CircleProgressView.swift
//  sdk
//
//  Created by TipTopPay on 13.09.2023.
//  Copyright © 2023 TipTopPay. All rights reserved.
//

import UIKit

final class CircleProgressView: UIView {
    
    private let ellipseBaseLayer = CAShapeLayer()
    private let ellipseProgressLayer = CAShapeLayer()
    
    //для разделения верхней части заполнения
    var gapAngle: CGFloat = 0 { didSet { update() } }
    
    //прогресс заполения круга от 0 до 1
    var progress: CGFloat = 0.8 {
        didSet {
            self.update()
        }
    }
    
    //ширина линии
    var widthLine: CGFloat = 4.0 {
        didSet {
            ellipseBaseLayer.lineWidth = widthLine
            ellipseProgressLayer.lineWidth = widthLine
        }
    }
    
    //нижний фоновый цвет
    var baseColor: UIColor = UIColor.colorLoader {
        didSet {
            ellipseBaseLayer.strokeColor = baseColor.cgColor
        }
    }
    
    //основной цвет
    var progressColor: UIColor = UIColor.mainBlue {
        didSet {
            ellipseProgressLayer.strokeColor = progressColor.cgColor
        }
    }
    
    init(frame: CGRect, width: CGFloat) {
        widthLine = width
        super.init(frame: frame)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func commonInit() -> Void {
        backgroundColor = .clear
        layer.addSublayer(ellipseBaseLayer)
        layer.addSublayer(ellipseProgressLayer)
        
        ellipseBaseLayer.lineWidth = widthLine
        ellipseBaseLayer.fillColor = UIColor.clear.cgColor
        ellipseBaseLayer.strokeColor = baseColor.cgColor
        
        ellipseProgressLayer.lineWidth = widthLine
        ellipseProgressLayer.fillColor = UIColor.clear.cgColor
        ellipseProgressLayer.strokeColor = progressColor.cgColor
        ellipseProgressLayer.lineCap = .round
    }
    
    //обновление представления
    private func update() {
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        var startAngle: CGFloat = 0
        var endAngle: CGFloat = 0
        var startRadians: CGFloat = 0
        var endRadians: CGFloat = 0
        var bezierPath: UIBezierPath!
        
        startAngle = 0 // тут можно изменить точку начала нижнего круга (например 15 градусов)
        endAngle = 360 // тут можно изменить точку окончания нижнего круга (например 270 градусов)
        
        let totalAngle: CGFloat = 360 - gapAngle
        
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = bounds.width / 2 // устанавливаем радиус
        
        let yScale: CGFloat = bounds.height / bounds.width
        
        let origHeight = radius * 2.0
        let ovalHeight = origHeight * yScale
        
        let y = (origHeight - ovalHeight) / 2
        
        // сдвигаем начало в верхннюю часть на место 12 часов (по умолчанию справа в 3 часа стоит)
        startRadians = (startAngle - 90).toRadians()
        endRadians = (endAngle - 90).toRadians()
        
        bezierPath = UIBezierPath()
        
        // дуга с «зазором» вверху
        bezierPath.addArc(withCenter: center, radius: radius, startAngle: startRadians, endAngle: endRadians, clockwise: true)
        
        
        // перевести по оси Y
        bezierPath.apply(CGAffineTransform(translationX: 0.0, y: y))
        // масштабировать ось Y
        bezierPath.apply(CGAffineTransform(scaleX: 1.0, y: yScale))
        
        ellipseBaseLayer.path = bezierPath.cgPath
        
        // новый endAngle равен startAngle плюс процент от общего угла
        endAngle = startAngle + totalAngle * progress
        
        // сдвигаем начало в верхннюю часть на место 12 часов (по умолчанию справа в 3 часа стоит)
        startRadians = (startAngle - 90).toRadians()
        endRadians = (endAngle - 90).toRadians()
        
        // новый bezier path
        bezierPath = UIBezierPath()
        
        bezierPath.addArc(withCenter: center, radius: radius, startAngle: startRadians, endAngle: endRadians, clockwise: true)
        
        // перевести по оси Y
        bezierPath.apply(CGAffineTransform(translationX: 0.0, y: y))
        // масштабировать ось Y
        bezierPath.apply(CGAffineTransform(scaleX: 1.0, y: yScale))
        
        ellipseProgressLayer.path = bezierPath.cgPath
    }
}
