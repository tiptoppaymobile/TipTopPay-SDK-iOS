//
//  PaymentProgressForm.swift
//  sdk
//
//  Created by TipTopPay on 24.09.2020.
//  Copyright © 2020 TipTopPay. All rights reserved.
//

import UIKit
import WebKit

public class PaymentProcessForm: PaymentForm {
    
    public enum State {
        
        case inProgress
        case succeeded(Transaction?)
        case failed(String?)
        
        func getImage() -> UIImage? {
            switch self {
            case .inProgress:
                return .iconProgress
            case .succeeded:
                return .iconSuccess
            case .failed:
                return .iconFailed
            }
        }
        
        func getMessage() -> String? {
            switch self {
            case .inProgress:
                return "ttpsdk_text_process_title".localized
            case .succeeded:
                return "ttpsdk_text_process_title_success".localized
            case .failed(let message):
                return message ?? "ttpsdk_text_process_title_error".localized
            }
        }
        
        func getActionButtonTitle() -> String? {
            switch self {
            case .succeeded:
                return "ttpsdk_text_process_button_success".localized
            case .failed:
                return "ttpsdk_text_process_button_error".localized
            default:
                return nil
            }
        }
    }
    
    // MARK: - Private properties
    
    @IBOutlet private weak var progressIcon: UIImageView!
    @IBOutlet private weak var messageLabel: UILabel!
    @IBOutlet private weak var actionButton: Button!
    @IBOutlet private weak var secondDescriptionLabel: UILabel!
    @IBOutlet private weak var progressView: View!
    @IBOutlet private weak var errorView: View!
    @IBOutlet private weak var buttonView: View!
    @IBOutlet private weak var progressStackView: UIStackView!
    @IBOutlet private weak var selectPaymentButton: Button!
    
    private var state: State = .inProgress
    private var cryptogram: String?
    private var email: String?
    private var transactionId: Int64?
    private var isSaveCard: Bool? = nil
    private var term: Int?
    
    @discardableResult
    public class func present(with configuration: TipTopPayConfiguration, cryptogram: String?, email: String?, state: State = .inProgress, from: UIViewController, isSaveCard: Bool? = nil, term: Int? = nil, completion: (() -> ())? = nil) -> PaymentForm? {
        let storyboard = UIStoryboard.init(name: "PaymentForm", bundle: Bundle.mainSdk)
        
        let controller = storyboard.instantiateViewController(withIdentifier: "PaymentProcessForm") as! PaymentProcessForm
        controller.configuration = configuration
        controller.cryptogram = cryptogram
        controller.email = email
        controller.state = state
        controller.isSaveCard = isSaveCard
        controller.term = term
        
        controller.show(inViewController: from, completion: completion)
        
        return controller
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.updateUI(with: self.state)
        
        if let cryptogram = self.cryptogram {
            if configuration.isUseDualMessagePayment {
                self.auth(cardCryptogramPacket: cryptogram, email: self.email) { [weak self] status, canceled, transaction, errorMessage in
                    guard let self = self else {
                        return
                    }
                    if status {
                        self.updateUI(with: .succeeded(transaction))
                    } else if !canceled {
                        let apiErrorDescription = ApiError.getFullErrorDescription(code: String(transaction?.reasonCode ?? 5204))
                        self.updateUI(with: .failed(apiErrorDescription))
                    } else {
                        self.configuration.paymentUIDelegate.paymentFormWillHide()
                        self.dismiss(animated: true) { [weak self] in
                            guard let self = self else {
                                return
                            }
                            self.configuration.paymentUIDelegate.paymentFormDidHide()
                        }
                    }
                }
            } else {
                self.charge(cardCryptogramPacket: cryptogram, email: self.email, term: term) { [weak self] status, canceled, transaction, errorMessage in
                    guard let self = self else {
                        return
                    }
                    if status {
                        self.updateUI(with: .succeeded(transaction))
                    } else if !canceled {
                        let apiErrorDescription = ApiError.getFullErrorDescription(code: String(transaction?.reasonCode ?? 5204))
                        self.updateUI(with: .failed(apiErrorDescription))
                    } else {
                        self.configuration.paymentUIDelegate.paymentFormWillHide()
                        self.dismiss(animated: true) { [weak self] in
                            guard let self = self else {
                                return
                            }
                            self.configuration.paymentUIDelegate.paymentFormDidHide()
                        }
                    }
                }
            }
        }
        
        messageLabel.textColor = .mainText
        secondDescriptionLabel.textColor = .colorProgressText
        selectPaymentButton.setTitle("ttpsdk_text_options_title".localized, for: .normal)
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        self.stopAnimation()
    }
    
    private func updateUI(with state: State){
        self.state = state
        self.stopAnimation()
        
        
        switch state {
            
        case .inProgress:
            buttonView.isHidden = true
            errorView.isHidden = true
            selectPaymentButton.superview?.isHidden = true
        case .succeeded(_):
            selectPaymentButton.superview?.isHidden = true
            buttonView.isHidden = false
            errorView.isHidden = true
        case .failed(_):
            selectPaymentButton.superview?.isHidden = true
            buttonView.isHidden = false
        }
        
        if let message = self.state.getMessage(), message.contains("#") {
            let messages: [String] = message.components(separatedBy: "#")
            self.messageLabel.text = messages[0]
            self.secondDescriptionLabel.text = messages[1]
            self.errorView.isHidden = false
        } else {
            self.messageLabel.text = self.state.getMessage()
            self.secondDescriptionLabel.text = nil
            self.errorView.isHidden = true
        }
        
        self.progressIcon.image = self.state.getImage()
        self.actionButton.setTitle(self.state.getActionButtonTitle(), for: .normal)
        
        if case .succeeded(let transaction) = self.state {
            
            self.configuration.paymentDelegate.paymentFinished(transaction?.transactionId)
            self.actionButton.onAction = { [weak self] in
                self?.hide()
            }
        } else if case .failed(let errorMessage) = self.state {
            self.configuration.paymentDelegate.paymentFailed(errorMessage)
            self.actionButton.onAction = { [weak self] in
                guard let self = self else {
                    return
                }
                
                let parent = self.presentingViewController
                self.dismiss(animated: true) { [weak self] in
                    guard let self = self else {
                        return
                    }
                    if let parent = parent {
                        PaymentForm.present(with: self.configuration, from: parent)
                    }
                }
            }
        }
    }
    
    private func startAnimation(){
        self.stopAnimation()
        
        if case .inProgress = self.state {
            let animation = CABasicAnimation.init(keyPath: "transform.rotation")
            animation.toValue = NSNumber.init(value: Double.pi * 2.0)
            animation.duration = 1.0
            animation.timingFunction = CAMediaTimingFunction.init(name: .easeInEaseOut)
            animation.isCumulative = true
            animation.repeatCount = Float.greatestFiniteMagnitude
            self.progressIcon.layer.add(animation, forKey: "rotationAnimation")
        }
    }
    
    private func stopAnimation(){
        self.progressIcon.layer.removeAllAnimations()
    }
    
    override internal func makeContainerCorners(){
        let path = UIBezierPath(roundedRect: self.containerView.bounds, byRoundingCorners: [.topLeft, .topRight, .bottomLeft, .bottomRight], cornerRadii: CGSize(width: 20, height: 20))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.containerView.layer.mask = mask
    }
    
    private func hide(_ completion: (() -> ())? = nil) {
        self.configuration.paymentUIDelegate.paymentFormWillHide()
        self.dismiss(animated: true) { [weak self] in
            guard let self = self else {
                return
            }
            self.configuration.paymentUIDelegate.paymentFormDidHide()
            completion?()
        }
    }
}
