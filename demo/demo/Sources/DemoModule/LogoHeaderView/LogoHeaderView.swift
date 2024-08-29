//
//  LogoHeaderView.swift
//  demo
//
//  Created by TipTopPay on 27.06.2023.
//  Copyright © 2023 TipTopPay. All rights reserved.
//

class LogoHeaderView: UIView {
    // MARK: - Outlets
    @IBOutlet weak var logoImageView: UIImageView!
    
    // MARK: - Init
    override init(frame: CGRect) { super.init(frame: frame)
        setupXib()
    }
    
    required init?(coder: NSCoder) { super.init(coder: coder)
        setupXib()
    }
    
    // MARK: - Private methods
    private func setupXib() {
        let arrayView = Bundle.main.loadNibNamed(LogoHeaderView.identifier, owner: self)
        if let view = arrayView?.first as? UIView  {
            view.frame = bounds
            addSubview(view)
        }
    }
}
