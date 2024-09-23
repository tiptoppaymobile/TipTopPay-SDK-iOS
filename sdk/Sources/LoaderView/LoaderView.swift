//
//  LoaderView.swift
//  sdk
//
//  Created by TipTopPay on 13.09.2023.
//  Copyright © 2023 TipTopPay. All rights reserved.
//

import Foundation
import UIKit

final class LoaderView: UIView {
    private let label: UILabel = .init()
    private let circleView: CircleProgressView = .init(frame: .init(x: 0, y: 0, width: 80, height: 80), width: 8)
    private var rotation: Double = 0
    private var isAnimated: Bool = true
    
    var text: String? {
        get { label.text} set { label.text = newValue}
    }
    
    override var isHidden: Bool {
        willSet {
            isAnimated = !newValue
            if !newValue { updateView()}
        }
    }

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let height = 80.0
        self.backgroundColor = .white
        
        [circleView, label].forEach({
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview($0)
        })
        
        label.numberOfLines = 0
        label.text = "Загрузка..."
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textColor = .mainText
        label.textAlignment = .center
        
        NSLayoutConstraint.activate([
            circleView.heightAnchor.constraint(equalToConstant: height),
            circleView.widthAnchor.constraint(equalTo: circleView.heightAnchor, multiplier: 1),
            circleView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            circleView.bottomAnchor.constraint(equalTo: self.centerYAnchor),
            
            label.topAnchor.constraint(equalTo: circleView.bottomAnchor, constant: 40),
            label.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 30),
            label.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -30),
            label.heightAnchor.constraint(greaterThanOrEqualToConstant: 50),
        ])
    }
    
    func startAnimated(_ text: String? = nil) {
        isHidden = false
        self.text = text ?? "ttp_update_loader".localized
        isAnimated = true
        updateView()
    }
    
    func endAnimated() {
        isAnimated = false
    }
    
    private func updateView() {
        if !isAnimated { return }
        rotation = rotation == 0 ? .pi : 0
        let transform = CGAffineTransform(rotationAngle: rotation)
        
        UIView.animate(withDuration: 1, delay: 0, options: .curveLinear) {
            self.circleView.transform = transform
            self.layoutIfNeeded()
        } completion: { _ in
            self.updateView()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
