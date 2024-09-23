//
//  FooterForPresentCard.swift
//  TipTopPay
//
//  Created by TipTopPay on 06.07.2023.
//

import UIKit

final class FooterForPresentCard: UIView {
    
    @IBOutlet private weak var savingButton: UIButton!
    @IBOutlet private weak var receiptButton: Button!
    @IBOutlet private weak var defaultInformationButton: UIButton!
    @IBOutlet private weak var forcedInformationButton: UIButton!
    
    @IBOutlet weak var emailView: UIView!
    @IBOutlet private weak var emailInputView: UIView!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var emailTextField: TextField!
    
    @IBOutlet weak var attentionView: UIView!
    @IBOutlet weak var attentionImage: UIImageView!
    @IBOutlet private weak var paymentEmailLabel: UILabel!
    @IBOutlet weak var paymentSaveLabel: UILabel!
    
    var isHiddenCardView: Bool {
        get { return receiptButton.superview?.isHidden ?? false }
        set {
            receiptButton.superview?.isHidden = newValue
        }
    }
    
    var saveCardButtonView: Bool {
        get { return savingButton.superview?.isHidden ?? false }
        
        set {
            forcedInformationButton.superview?.isHidden = newValue
            savingButton.superview?.isHidden = newValue
        }
    }
    
    var isHiddenAttentionView: Bool {
        get { return attentionView.isHidden }
        set {
            attentionView.isHidden = newValue
        }
    }
    
    var emailBorderColor: UIColor {
        get { return .clear }
        set { emailInputView.layer.borderColor = newValue.cgColor }
    }
    
    var isSelectedReceipt: Bool {
        get { return receiptButton.isSelected }
        set {
            receiptButton.isSelected = newValue
        }
    }
    
    var isSelectedSave: Bool? {
        get {
            guard let isOnHidden = savingButton.superview?.isHidden,
                    !isOnHidden
            else {
                return nil
            }
            let isSelected = savingButton.isSelected
           
            return isSelected
        }
        set {
            guard let newValue = newValue else { return }
            savingButton.isSelected = newValue
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        addXib()
        setup()
        setupColors()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        addXib()
        setup()
        setupColors()
    }
    
    private func setupColors() {
        emailTextField.textColor = .mainText
        emailLabel.textColor = .colorProgressText
        paymentEmailLabel.textColor = .colorProgressText
        
        savingButton.setTitle("ttpsdk_text_options_save_card".localized, for: .normal)
        receiptButton.setTitle("ttpsdk_text_options_email_checkbox".localized, for: .normal)
        
        emailLabel.text = "ttpsdk_text_options_email_title_2".localized
        paymentEmailLabel.text = "ttpsdk_text_options_email_require".localized
        paymentSaveLabel.text = "ttpsdk_text_options_card_be_saved".localized
        
        receiptButton.setTitleColor(.colorTextButton, for: .normal)
        savingButton.setTitleColor(.colorTextButton, for: .normal)
        forcedInformationButton.setTitleColor(.colorTextButton, for: .normal)
        defaultInformationButton.setTitleColor(.colorTextButton, for: .normal)
    }
    
    private func setup() {
        let spasing: CGFloat = 10
        
        [savingButton, receiptButton].forEach {
            let unselected = UIImage.iconUnselected
            let selected = UIImage.iconSelected
            
            $0.setImage(unselected, for: .normal)
            $0.setImage(selected, for: .selected)
            $0.titleEdgeInsets = .init(top: 0, left: spasing, bottom: 0, right: -spasing)
            $0.contentEdgeInsets.right = spasing
        }
        
        [defaultInformationButton, forcedInformationButton].forEach {
            let attention = UIImage.icn_attention
            
            $0?.setImage(attention, for: .normal)
        }
        
        attentionImage.image = UIImage.icn_attention
        attentionImage.colorRenderForImage = UIColor(red: 0.95, green: 0.79, blue: 0.04, alpha: 1)
    }

    func addTarget(_ target: Any, action: Selector, type: TypeButton) {
        switch type {
        case .info:
            defaultInformationButton.addTarget(target, action: action, for: .touchUpInside)
            forcedInformationButton.addTarget(target, action: action, for: .touchUpInside)
        case .receipt:
            receiptButton.addTarget(target, action: action, for: .touchUpInside)
        case .saving:
            savingButton.addTarget(target, action: action, for: .touchUpInside)
        }
    }
    
    func setup(_ status: SaveCardState) {
        savingButton.superview?.isHidden = !(status == .isOnCheckbox)
        forcedInformationButton.superview?.isHidden = !(status == .isOnHint)
        if status == .isOnCheckbox {
            isSelectedSave = false
        }
    }
}

extension FooterForPresentCard {
    enum TypeButton {
        case saving
        case receipt
        case info
    }
}

enum SaveCardState {
    case isOnCheckbox
    case isOnHint
    case none
}


final class AlertInfoView: UIView {
    private var triangleConstraint: NSLayoutConstraint!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    init(title: String) {
        super.init(frame: .zero)
        setupInfoLabelView(text: title)
    }
    
    var trianglPosition: CGFloat {
        get { triangleConstraint.constant}
        set {
            triangleConstraint.constant = newValue
            self.layoutIfNeeded()
        }
    }
    
    private func setupView() {
        self.backgroundColor = .clear
        let array = [
            
            "ttpsdk_text_options_save_card_popup_1".localized,
            
            "ttpsdk_text_options_save_card_popup_2".localized
        ]
            .map ({ string in
                let label = UILabel()
                label.font = .systemFont(ofSize: 13)
                label.textColor = .whiteColor
                label.numberOfLines = 0
                label.addSpacing(text: string, 5)
                label.sizeToFit()
                let view = UIView()
                view.addSubview(label)
                view.backgroundColor = .clear
                label.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    label.topAnchor.constraint(equalTo: view.topAnchor),
                    label.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                    label.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                    label.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                ])
                return view
            })
            .map { labelView in
                let height = 10.0
                let dot = UIView()
                dot.backgroundColor = .mainBlue
                dot.layer.cornerRadius = height / 2
                dot.heightAnchor.constraint(equalToConstant: height).isActive = true
                dot.widthAnchor.constraint(equalTo: dot.heightAnchor, multiplier: 1).isActive = true
                let view = UIView()
                view.backgroundColor = .clear
                view.addSubview(dot)
                dot.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    dot.topAnchor.constraint(equalTo: view.topAnchor, constant: 5),
                    dot.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                    dot.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                    dot.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor),
                ])
                
                let stackView = UIStackView(.horizontal, .fill, .fill, 15, [view, labelView])
                return stackView
            }
        
        let stackView = UIStackView(.vertical, .equalSpacing, .fill, 10, array)
        
        let triangleView = UIView()
        triangleView.backgroundColor = .colorAlertView
        let transform = CGAffineTransform(rotationAngle: .pi / 1 / 4)
        triangleView.transform = transform
        triangleView.translatesAutoresizingMaskIntoConstraints = false
        
        let view = UIView()
        view.backgroundColor = .colorAlertView
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        
        view.addSubview(stackView)
        stackView.fullConstraint(top: 22, bottom: -22, leading: 10, trailing: -10 )
        self.addSubview(triangleView)
        self.addSubview(view)
        view.fullConstraint(bottom: -10, leading: 30, trailing: -30)
        
        NSLayoutConstraint.activate([
            triangleView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -2),
            triangleView.centerYAnchor.constraint(equalTo: view.bottomAnchor, constant: -5),
            triangleView.widthAnchor.constraint(equalTo: triangleView.heightAnchor, multiplier: 1)
        ])
        
        triangleConstraint = triangleView.centerXAnchor.constraint(equalTo: self.leadingAnchor)
        triangleConstraint.isActive = true
    }
    
    private func setupInfoLabelView(text: String) {
        self.backgroundColor = .clear
     
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.textColor = .whiteColor
        label.numberOfLines = 0
        label.addSpacing(text: text, 5)
        label.sizeToFit()
        
        let view = UIView()
        view.addSubview(label)
        
        
        let triangleView = UIView()
        triangleView.backgroundColor = .colorAlertView
        let transform = CGAffineTransform(rotationAngle: .pi / 1 / 4)
        triangleView.transform = transform
        triangleView.translatesAutoresizingMaskIntoConstraints = false
        
        view.backgroundColor = .colorAlertView
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        
        label.fullConstraint(top: 20, bottom: -20, leading: 20, trailing: -20)
        self.addSubview(triangleView)
        self.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: topAnchor),
            view.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -2),
            view.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            view.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 366 / 462),
            
            triangleView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -2),
            triangleView.heightAnchor.constraint(equalToConstant: 15),
            triangleView.widthAnchor.constraint(equalTo: triangleView.heightAnchor, multiplier: 1)
        ])
        
        triangleConstraint = triangleView.centerXAnchor.constraint(equalTo: self.leadingAnchor)
        triangleConstraint.isActive = true
    }
}


struct TipTopPayModel: Codable {
    let tiptoppay: TipTopPay?
}

struct TipTopPay: Codable {
    let recurrent: Recurrent?
}

struct Recurrent: Codable {
    let interval, period: String?
    let amount: Int?
}
