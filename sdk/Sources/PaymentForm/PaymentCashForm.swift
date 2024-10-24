//
//  PaymentCashForm.swift
//  sdk
//
//  Created by TipTopPay on 07.10.2024.
//  Copyright © 2024 TipTopPay. All rights reserved.
//

import Foundation
import UIKit
import SafariServices

private struct CashMethod {
    let id: Int
    let serverKey: String
    let buttonTextKey: String
    let altPayType: String
}

final class PaymentCashForm: BaseViewController {
    
    private var configuration: TipTopPayConfiguration!
    private let closeThreshold: CGFloat = 90
    private var containerOriginalY: CGFloat = 0.0
    private var containerBottomConstraint: NSLayoutConstraint?
    
    private let cashMethods: [CashMethod] = [
        CashMethod(id: 0, serverKey: "OXXO", buttonTextKey: "ttpsdk_cash_method_oxxo".localized, altPayType: "CashOxxo"),
        CashMethod(id: 1, serverKey: "Convenience Store", buttonTextKey: "ttpsdk_cash_method_pharmacy".localized, altPayType: "CashCStores"),
        CashMethod(id: 2, serverKey: "Pharmacy", buttonTextKey: "ttpsdk_cash_method_convenience_store".localized, altPayType: "CashFarmacias")
    ]
    
    class func present(with configuration: TipTopPayConfiguration, from: UIViewController) {
        let controller = PaymentCashForm()
        controller.configuration = configuration
        controller.modalPresentationStyle = .overFullScreen
        controller.modalTransitionStyle = .crossDissolve
        controller.view.isOpaque = false
        from.present(controller, animated: true, completion: nil)
    }
    
    private let modalContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let dragIndicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .mainText
        view.layer.cornerRadius = 2.5
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var amountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .mainText
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "\(configuration.paymentData.amount) \(configuration.paymentData.currency)"
        return label
    }()
    
    private let bottomLabelView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 236, green: 241, blue: 247, alpha: 1.0)
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let blueDotView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBlue
        view.layer.cornerRadius = 4
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let bottomLabel: UILabel = {
        let label = UILabel()
        label.text = "ttpsdk_text_cash_title_barcode".localized
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .mainText
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "ttpsdk_text_cash_title_name".localized
        textField.backgroundColor = .whiteColor
        textField.layer.cornerRadius = 12
        textField.layer.borderWidth = 2
        textField.layer.borderColor = UIColor.border.cgColor
        textField.setLeftPaddingPoints(16)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.text = "\(configuration.paymentData.payer?.firstName ?? "")"
        textField.delegate = self
        return textField
    }()
    
    private lazy var emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "ttpsdk_text_cash_title_email".localized
        textField.backgroundColor = .whiteColor
        textField.layer.cornerRadius = 12
        textField.layer.borderWidth = 2.0
        textField.layer.borderColor = UIColor.border.cgColor
        textField.setLeftPaddingPoints(16)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.text = "\(configuration.paymentData.email ?? "")"
        textField.delegate = self
        return textField
    }()
    
    private let dimmingView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let inputStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let payWithLabel: UILabel = {
        let label = UILabel()
        label.text = "ttpsdk_text_cash_title_pay_with".localized
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .mainText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let cashMethodsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let footerImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage.ic_secured_by_ttp
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
        setupGestureRecognizers()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapOutsideTextField))
        view.addGestureRecognizer(tapGesture)
        
        nameTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        emailTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        validateInitialTextFieldState()
        setupCashMethodButtons()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        animateModalPresentation()
        updateCashMethodButtonState()
    }
    
    private func setupView() {
        view.addSubview(dimmingView)
        view.addSubview(modalContainerView)
        modalContainerView.addSubview(dragIndicatorView)
        modalContainerView.addSubview(amountLabel)
        modalContainerView.addSubview(inputStackView)
        modalContainerView.addSubview(payWithLabel)
        modalContainerView.addSubview(cashMethodsStackView)
        modalContainerView.addSubview(footerImageView)
        inputStackView.addArrangedSubviews(nameTextField, emailTextField, bottomLabelView)
        bottomLabelView.addSubview(blueDotView)
        bottomLabelView.addSubview(bottomLabel)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDimmingViewTap))
        dimmingView.addGestureRecognizer(tapGesture)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            dimmingView.topAnchor.constraint(equalTo: view.topAnchor),
            dimmingView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            dimmingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimmingView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        NSLayoutConstraint.activate([
            modalContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            modalContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        let minHeightConstraint = modalContainerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 200)
        minHeightConstraint.priority = .defaultLow
        
        let maxHeightConstraint = modalContainerView.heightAnchor.constraint(lessThanOrEqualTo: view.heightAnchor, multiplier: 0.8)
        
        NSLayoutConstraint.activate([minHeightConstraint, maxHeightConstraint])
        
        containerBottomConstraint = modalContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        containerBottomConstraint?.isActive = true
        
        NSLayoutConstraint.activate([
            dragIndicatorView.topAnchor.constraint(equalTo: modalContainerView.topAnchor, constant: 21),
            dragIndicatorView.centerXAnchor.constraint(equalTo: modalContainerView.centerXAnchor),
            dragIndicatorView.widthAnchor.constraint(equalToConstant: 135),
            dragIndicatorView.heightAnchor.constraint(equalToConstant: 5)
        ])
        
        NSLayoutConstraint.activate([
            amountLabel.topAnchor.constraint(equalTo: dragIndicatorView.bottomAnchor, constant: 20),
            amountLabel.leadingAnchor.constraint(equalTo: modalContainerView.leadingAnchor, constant: 16),
            amountLabel.trailingAnchor.constraint(equalTo: modalContainerView.trailingAnchor, constant: -16)
        ])
        
        NSLayoutConstraint.activate([
            inputStackView.topAnchor.constraint(equalTo: amountLabel.bottomAnchor, constant: 20),
            inputStackView.leadingAnchor.constraint(equalTo: modalContainerView.leadingAnchor, constant: 25),
            inputStackView.trailingAnchor.constraint(equalTo: modalContainerView.trailingAnchor, constant: -25)
        ])
        
        NSLayoutConstraint.activate([
            nameTextField.heightAnchor.constraint(equalToConstant: 56),
            emailTextField.heightAnchor.constraint(equalToConstant: 56)
        ])
        
        NSLayoutConstraint.activate([
            bottomLabelView.heightAnchor.constraint(equalToConstant: 32),
            bottomLabelView.leadingAnchor.constraint(equalTo: inputStackView.leadingAnchor),
            bottomLabelView.trailingAnchor.constraint(equalTo: inputStackView.trailingAnchor)
        ])
        
        NSLayoutConstraint.activate([
            blueDotView.leadingAnchor.constraint(equalTo: bottomLabelView.leadingAnchor, constant: 8),
            blueDotView.centerYAnchor.constraint(equalTo: bottomLabelView.centerYAnchor),
            blueDotView.widthAnchor.constraint(equalToConstant: 8),
            blueDotView.heightAnchor.constraint(equalToConstant: 8)
        ])
        
        NSLayoutConstraint.activate([
            bottomLabel.leadingAnchor.constraint(equalTo: blueDotView.trailingAnchor, constant: 4),
            bottomLabel.trailingAnchor.constraint(equalTo: bottomLabelView.trailingAnchor, constant: -6),
            bottomLabel.centerYAnchor.constraint(equalTo: bottomLabelView.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            payWithLabel.topAnchor.constraint(equalTo: inputStackView.bottomAnchor, constant: 24),
            payWithLabel.leadingAnchor.constraint(equalTo: modalContainerView.leadingAnchor, constant: 16),
            payWithLabel.trailingAnchor.constraint(equalTo: modalContainerView.trailingAnchor, constant: -16)
        ])
        
        NSLayoutConstraint.activate([
            cashMethodsStackView.topAnchor.constraint(equalTo: payWithLabel.bottomAnchor, constant: 16),
            cashMethodsStackView.leadingAnchor.constraint(equalTo: modalContainerView.leadingAnchor, constant: 25),
            cashMethodsStackView.trailingAnchor.constraint(equalTo: modalContainerView.trailingAnchor, constant: -25),
        ])
        
        NSLayoutConstraint.activate([
            footerImageView.topAnchor.constraint(equalTo: cashMethodsStackView.bottomAnchor, constant: 20),
            footerImageView.widthAnchor.constraint(equalToConstant: 168),
            footerImageView.heightAnchor.constraint(equalToConstant: 16),
            footerImageView.centerXAnchor.constraint(equalTo: modalContainerView.centerXAnchor),
            footerImageView.bottomAnchor.constraint(equalTo: modalContainerView.bottomAnchor, constant: -20)
        ])
    }
    
    private func setupGestureRecognizers() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        modalContainerView.addGestureRecognizer(panGesture)
    }
    
    @objc private func handleTapOutsideTextField() {
        view.endEditing(true)
        if let emailText = emailTextField.text {
            if emailText.isEmpty {
                updateTextFieldAppearance(emailTextField, withColor: UIColor.errorBorder.cgColor, textColor: .errorBorder)
            } else if emailText.emailIsValid() {
                updateTextFieldAppearance(emailTextField, withColor: UIColor.border.cgColor, textColor: .mainText)
            } else {
                updateTextFieldAppearance(emailTextField, withColor: UIColor.errorBorder.cgColor, textColor: .errorBorder)
            }
        }
        validateTextField(nameTextField)
        updateCashMethodButtonState()
    }
    
    func animateModalPresentation() {
        modalContainerView.transform = CGAffineTransform(translationX: 0, y: view.bounds.height)
        
        UIView.animate(withDuration: 0.9, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
            self.modalContainerView.transform = .identity
        }, completion: { _ in
            self.containerOriginalY = self.modalContainerView.frame.origin.y
        })
    }
    
    @objc private func handleDimmingViewTap() {
        dismissModalWithAnimation()
    }
    
    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        
        switch gesture.state {
        case .began:
            containerOriginalY = modalContainerView.frame.origin.y
        case .changed:
            if translation.y > 0 {
                modalContainerView.transform = CGAffineTransform(translationX: 0, y: translation.y)
            }
        case .ended, .cancelled:
            let movedDistance = translation.y
            if movedDistance > closeThreshold {
                dismissModalWithAnimation()
            } else {
                UIView.animate(withDuration: 0.35, animations: {
                    self.modalContainerView.transform = .identity
                })
            }
            
        default:
            break
        }
    }
    
    private func dismissModalWithAnimation() {
        guard let controller = self.presentingViewController else { return }
        
        UIView.animate(withDuration: 0.35, animations: {
            self.modalContainerView.transform = CGAffineTransform(translationX: 0, y: self.view.bounds.height)
            
        }) { _ in
            self.dismiss(animated: false) {
                PaymentForm.present(with: self.configuration, from: controller)
            }
        }
    }
    
    override func onKeyboardWillShow(_ notification: Notification) {
        super.onKeyboardWillShow(notification)
        if isKeyboardShowing {
            UIView.animate(withDuration: 0.35) {
                self.containerBottomConstraint?.constant = -self.keyboardFrame.height
                self.view.layoutIfNeeded()
            }
        }
    }
    
    override func onKeyboardWillHide(_ notification: Notification) {
        super.onKeyboardWillHide(notification)
        UIView.animate(withDuration: 0.35) {
            self.containerBottomConstraint?.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    
    private func updateTextFieldAppearance(_ textField: UITextField, withColor color: CGColor, textColor: UIColor) {
        textField.layer.borderColor = color
        textField.textColor = textColor
    }
}


extension PaymentCashForm {
    
    private func setupCashMethodButtons() {
        cashMethodsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let availableMethods = configuration?.paymentData.cashMethods ?? []
        
        var activeButtons: [UIView] = []
        var inactiveButtons: [UIView] = []
        
        for method in cashMethods {
            let button = createCashMethodButton(for: method)
            
            if availableMethods.contains(method.id) {
                button.isUserInteractionEnabled = true
                button.alpha = 1.0
                activeButtons.append(button)
            } else {
                button.isUserInteractionEnabled = false
                button.alpha = 0.3
                
                let notAvailableLabel = UILabel()
                notAvailableLabel.text = "ttpsdk_text_cash_available_title".localized
                notAvailableLabel.font = .systemFont(ofSize: 12)
                notAvailableLabel.textColor = .mainText
                notAvailableLabel.textAlignment = .center
                notAvailableLabel.translatesAutoresizingMaskIntoConstraints = false
                
                let containerStackView = UIStackView(arrangedSubviews: [button, notAvailableLabel])
                containerStackView.axis = .vertical
                containerStackView.spacing = 8
                containerStackView.alignment = .fill
                
                inactiveButtons.append(containerStackView)
            }
            
            for button in activeButtons {
                cashMethodsStackView.addArrangedSubview(button)
            }
            
            for container in inactiveButtons {
                cashMethodsStackView.addArrangedSubview(container)
            }
            
            updateCashMethodButtonState()
        }
    }
    
    private func createCashMethodButton(for method: CashMethod) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(method.buttonTextKey.localized, for: .normal)
        button.layer.cornerRadius = 8
        button.backgroundColor = .white
        button.layer.borderWidth = 1
        button.setTitleColor(.mainText, for: .normal)
        button.layer.borderColor = UIColor.mainBlue.cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 56).isActive = true
        button.accessibilityIdentifier = method.altPayType
        button.tag = method.id
        button.addTarget(self, action: #selector(cashMethodButtonTapped(_:)), for: .touchUpInside)
        return button
    }
    
    private func updateCashMethodButtonState() {
        let isNameValid = !(nameTextField.text?.isEmpty ?? true)
        let isEmailValid = emailTextField.text?.emailIsValid() ?? false
        let shouldEnableButtons = isNameValid && isEmailValid
        
        for view in cashMethodsStackView.arrangedSubviews {
            if let containerStack = view as? UIStackView, let button = containerStack.arrangedSubviews.first as? UIButton {
                if button.isUserInteractionEnabled {
                    button.isUserInteractionEnabled = shouldEnableButtons
                    button.alpha = shouldEnableButtons ? 1.0 : 0.3
                }
            } else if let button = view as? UIButton {
                button.isUserInteractionEnabled = shouldEnableButtons
                button.alpha = shouldEnableButtons ? 1.0 : 0.3
            }
        }
    }
    
    private func validateInitialTextFieldState() {
        validateTextField(nameTextField)
        validateTextField(emailTextField)
        updateCashMethodButtonState()
    }
    
    @objc private func cashMethodButtonTapped(_ sender: UIButton) {
        guard let altPayType = sender.accessibilityIdentifier else { return }
        TipTopPayApi.altPayCash(with: configuration, altPayType: altPayType) { [weak self] result in
            switch result {
            case .success(let response):
                guard let link = response?.model?.extensionData?.link, let url = URL(string: link) else {
                    return
                }
                let safariVC = SFSafariViewController(url: url)
                self?.present(safariVC, animated: true, completion: nil)
            case .failure(_):
                self?.showAlert(title: nil, message: .infoOutdated)
            }
        }
    }
}

extension PaymentCashForm: UITextFieldDelegate {
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        updateCashMethodButtonState()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == emailTextField {
            if textField.text?.isEmpty ?? true {
                updateTextFieldAppearance(textField, withColor: UIColor.mainBlue.cgColor, textColor: .mainText)
            } else if textField.text?.emailIsValid() ?? false {
                updateTextFieldAppearance(textField, withColor: UIColor.mainBlue.cgColor, textColor: .mainText)
            } else {
                updateTextFieldAppearance(textField, withColor: UIColor.errorBorder.cgColor, textColor: .errorBorder)
            }
        } else {
            updateTextFieldAppearance(textField, withColor: UIColor.mainBlue.cgColor, textColor: .mainText)
        }
        updateCashMethodButtonState()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == emailTextField {
            if textField.text?.isEmpty ?? true {
                updateTextFieldAppearance(textField, withColor: UIColor.errorBorder.cgColor, textColor: .errorBorder)
            } else if textField.text?.emailIsValid() ?? false {
                updateTextFieldAppearance(textField, withColor: UIColor.border.cgColor, textColor: .mainText)
            } else {
                updateTextFieldAppearance(textField, withColor: UIColor.errorBorder.cgColor, textColor: .errorBorder)
            }
        } else {
            validateTextField(textField)
        }
        updateCashMethodButtonState()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == emailTextField || textField == nameTextField {
            if let text = textField.text, let textRange = Range(range, in: text) {
                let updatedText = text.replacingCharacters(in: textRange, with: string)
                
                if textField == emailTextField {
                    if updatedText.isEmpty {
                        updateTextFieldAppearance(textField, withColor: UIColor.mainBlue.cgColor, textColor: .mainText)
                    } else if updatedText.emailIsValid() {
                        if textField.isFirstResponder {
                            updateTextFieldAppearance(textField, withColor: UIColor.mainBlue.cgColor, textColor: .mainText)
                        } else {
                            updateTextFieldAppearance(textField, withColor: UIColor.border.cgColor, textColor: .mainText)
                        }
                    } else {
                        updateTextFieldAppearance(textField, withColor: UIColor.errorBorder.cgColor, textColor: .errorBorder)
                    }
                } else if textField == nameTextField {
                    if updatedText.isEmpty {
                        updateTextFieldAppearance(textField, withColor: UIColor.errorBorder.cgColor, textColor: .errorBorder)
                        if textField.isFirstResponder {
                            updateTextFieldAppearance(textField, withColor: UIColor.mainBlue.cgColor, textColor: .mainText)
                        } else {
                            updateTextFieldAppearance(textField, withColor: UIColor.border.cgColor, textColor: .mainText)
                        }
                    }
                    else {
                        updateTextFieldAppearance(textField, withColor: UIColor.mainBlue.cgColor, textColor: .mainText)
                    }
                }
                
                DispatchQueue.main.async { [weak self] in
                    self?.updateCashMethodButtonState()
                }
            }
        }
        return true
    }
    
    private func validateTextField(_ textField: UITextField) {
        if textField == nameTextField {
            if textField.text?.isEmpty ?? true {
                updateTextFieldAppearance(textField, withColor: UIColor.errorBorder.cgColor, textColor: .errorBorder)
            } else {
                updateTextFieldAppearance(textField, withColor: UIColor.border.cgColor, textColor: .mainText)
            }
        }
        
        if textField == emailTextField {
            if let text = textField.text, !text.isEmpty {
                if text.emailIsValid() {
                    updateTextFieldAppearance(textField, withColor: UIColor.border.cgColor, textColor: .mainText)
                } else {
                    updateTextFieldAppearance(textField, withColor: UIColor.errorBorder.cgColor, textColor: .errorBorder)
                }
            } else {
                updateTextFieldAppearance(textField, withColor: UIColor.errorBorder.cgColor, textColor: .errorBorder)
            }
        }
    }
}
