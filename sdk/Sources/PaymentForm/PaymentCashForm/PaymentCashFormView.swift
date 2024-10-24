//
//  PaymentCashFormView.swift
//  sdk
//
//  Created by TipTopPay on 09.10.2024.
//  Copyright © 2024 TipTopPay. All rights reserved.
//

import Foundation
import UIKit

// MARK: - PaymentCashFormView

final class PaymentCashFormView: UIView {
    
    // MARK: - Properties
    
    var onDismiss: (() -> Void)?
    private var viewModel: PaymentCashFormViewModel
    private var hasAnimated = false
    
    private let closeThreshold: CGFloat = 90
    private var containerOriginalY: CGFloat = 0.0
    private var containerBottomConstraint: NSLayoutConstraint?
    
    // MARK: - UI Elements
    
    lazy var modalContainerView: UIView = {
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
        label.text = "\(viewModel.configuration.paymentData.amount ) \(viewModel.configuration.paymentData.currency)"
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
        textField.text = "\(viewModel.configuration.paymentData.payer?.firstName ?? "")"
        textField.translatesAutoresizingMaskIntoConstraints = false
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
        textField.text = "\(viewModel.configuration.paymentData.email ?? "")"
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        return textField
    }()
    
    private let dimmingView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = true
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
    
    // MARK: - Init
    
    init(viewModel: PaymentCashFormViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupView()
        setupBindings()
        setupGestureRecognizers()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapOutsideTextField))
        self.addGestureRecognizer(tapGesture)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if !hasAnimated {
            setupConstraints()
            animateModalPresentation()
            hasAnimated = true
        }
    }
    
    // MARK: - Setup Bindings
    
    private func setupBindings() {
        viewModel.name = nameTextField.text ?? ""
        viewModel.email = emailTextField.text ?? ""
        
        viewModel.onNameValidationChange = { [weak self] isValid in
            self?.updateTextFieldAppearance(self?.nameTextField, withColor: isValid ? UIColor.border.cgColor : UIColor.errorBorder.cgColor, textColor: .mainText)
            self?.updateCashMethodButtonStateMethod()
        }
        
        viewModel.onEmailValidationChange = { [weak self] isValid in
            self?.updateTextFieldAppearance(self?.emailTextField, withColor: isValid ? UIColor.border.cgColor : UIColor.errorBorder.cgColor, textColor: .mainText)
            self?.updateCashMethodButtonStateMethod()
        }
        
        viewModel.onFieldsValidationChange = { [weak self] isValid in
            self?.updateCashMethodButtonStateMethod()
        }
        
        viewModel.onAvailableMethodsChange = { [weak self] availableMethods in
            self?.setupCashMethodButtons(methods: self?.viewModel.cashMethods ?? [])
        }
        
        viewModel.onCashMethodsChange = { [weak self] methods in
            self?.setupCashMethodButtons(methods: methods)
        }
        
        viewModel.onDismiss = { [weak self] in
            self?.onDismiss?()
        }
        
        viewModel.isLoadingStateChange = { [weak self] isLoading in
            self?.setCashMethodButtonsEnabled(!isLoading)
        }
        
        viewModel.updateFieldsValidState()
        updateCashMethodButtonStateMethod()
        viewModel.fetchCashMethods()
    }
}

    //MARK: - Setup Views

private extension PaymentCashFormView {
    
    func setupView() {
        addSubview(dimmingView)
        addSubview(modalContainerView)
        modalContainerView.addSubview(dragIndicatorView)
        modalContainerView.addSubview(amountLabel)
        modalContainerView.addSubview(inputStackView)
        modalContainerView.addSubview(payWithLabel)
        modalContainerView.addSubview(cashMethodsStackView)
        modalContainerView.addSubview(footerImageView)
        inputStackView.addArrangedSubview(nameTextField)
        inputStackView.addArrangedSubview(emailTextField)
        inputStackView.addArrangedSubview(bottomLabelView)
        bottomLabelView.addSubview(blueDotView)
        bottomLabelView.addSubview(bottomLabel)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            dimmingView.topAnchor.constraint(equalTo: self.topAnchor),
            dimmingView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            dimmingView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            dimmingView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
        
        NSLayoutConstraint.activate([
            modalContainerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            modalContainerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            modalContainerView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        ])
        
        let minHeightConstraint = modalContainerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 200)
        minHeightConstraint.priority = .defaultLow
        let maxHeightConstraint = modalContainerView.heightAnchor.constraint(lessThanOrEqualTo: self.heightAnchor, multiplier: 0.8)
        maxHeightConstraint.priority = .defaultLow
        NSLayoutConstraint.activate([minHeightConstraint, maxHeightConstraint])
        
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
            inputStackView.leadingAnchor.constraint(equalTo: modalContainerView.leadingAnchor, constant: 10),
            inputStackView.trailingAnchor.constraint(equalTo: modalContainerView.trailingAnchor, constant: -10)
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
            cashMethodsStackView.leadingAnchor.constraint(equalTo: modalContainerView.leadingAnchor, constant: 10),
            cashMethodsStackView.trailingAnchor.constraint(equalTo: modalContainerView.trailingAnchor, constant: -10),
        ])
        
        NSLayoutConstraint.activate([
            footerImageView.topAnchor.constraint(equalTo: cashMethodsStackView.bottomAnchor, constant: 20),
            footerImageView.widthAnchor.constraint(equalToConstant: 168),
            footerImageView.heightAnchor.constraint(equalToConstant: 16),
            footerImageView.centerXAnchor.constraint(equalTo: modalContainerView.centerXAnchor),
            footerImageView.bottomAnchor.constraint(equalTo: modalContainerView.bottomAnchor, constant: -20)
        ])
    }
}

    //MARK: - Setup buttons

private extension PaymentCashFormView {
    
    func setupCashMethodButtons(methods: [PaymentCashFormViewModel.CashMethod]) {
        cashMethodsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let availableMethods = viewModel.availableMethods
        let activeMethods = methods.filter { availableMethods.contains($0.id) }
        let inactiveMethods = methods.filter { !availableMethods.contains($0.id) }
        
        for method in activeMethods {
            let button = createCashMethodButton(for: method)
            button.isUserInteractionEnabled = true
            button.alpha = 1.0
            cashMethodsStackView.addArrangedSubview(button)
        }
        
        for method in inactiveMethods {
            let button = createCashMethodButton(for: method)
            button.isUserInteractionEnabled = false
            button.alpha = 0.3
            
            let notAvailableLabel = createNotAvailableLabel()
            let containerStackView = UIStackView(arrangedSubviews: [button, notAvailableLabel])
            containerStackView.axis = .vertical
            containerStackView.spacing = 8
            containerStackView.alignment = .fill
            containerStackView.translatesAutoresizingMaskIntoConstraints = false
            containerStackView.tag = method.id
            cashMethodsStackView.addArrangedSubview(containerStackView)
        }
        
        updateCashMethodButtonStateMethod()
    }
    
    func createCashMethodButton(for method: PaymentCashFormViewModel.CashMethod) -> UIButton {
        let button = UIButton(type: .system)
        button.layer.cornerRadius = 8
        button.backgroundColor = .white
        button.layer.borderWidth = 1
        button.setTitleColor(.mainText, for: .normal)
        button.layer.borderColor = UIColor.mainBlue.cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        button.accessibilityIdentifier = method.altPayType
        button.tag = method.id
        button.addTarget(self, action: #selector(cashMethodButtonTapped(_:)), for: .touchUpInside)
        
        let buttonHeightConstraint = button.heightAnchor.constraint(equalToConstant: 56)
        buttonHeightConstraint.priority = .required
        buttonHeightConstraint.isActive = true
        
        let horizontalStackView = UIStackView()
        horizontalStackView.axis = .horizontal
        horizontalStackView.spacing = 12
        horizontalStackView.alignment = .center
        horizontalStackView.translatesAutoresizingMaskIntoConstraints = false
        horizontalStackView.isUserInteractionEnabled = false
        
        switch method.serverKey {
        case "OXXO":
            let titleLabel = UILabel()
            titleLabel.text = method.buttonTextKey
            titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
            titleLabel.textColor = .mainText
            titleLabel.textAlignment = .center
            
            let oxxoImageView = UIImageView(image: .ic_oxxo)
            oxxoImageView.translatesAutoresizingMaskIntoConstraints = false
            oxxoImageView.widthAnchor.constraint(equalToConstant: 47).isActive = true
            oxxoImageView.heightAnchor.constraint(equalToConstant: 27).isActive = true
            
            horizontalStackView.addArrangedSubview(titleLabel)
            horizontalStackView.addArrangedSubview(oxxoImageView)
            
        case "Convenience Store":
            let titleLabel = UILabel()
            titleLabel.text = method.buttonTextKey
            titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
            titleLabel.textColor = .mainText
            
            let sevenElevenImageView = UIImageView(image: .ic_seven_eleven)
            let walmartImageView = UIImageView(image: .ic_wallmart)
            
            [sevenElevenImageView, walmartImageView].forEach {
                $0.translatesAutoresizingMaskIntoConstraints = false
                $0.widthAnchor.constraint(equalToConstant: 27).isActive = true
                $0.heightAnchor.constraint(equalToConstant: 27).isActive = true
            }
            
            let plusTen = "+10"
            let storesLabel = "ttpsdk_cash_method_stores_label".localized
            
            let storeLabel = UILabel()
            storeLabel.text = "\(plusTen) \(storesLabel)"
            storeLabel.font = .systemFont(ofSize: 12, weight: .medium)
            storeLabel.textColor = .colorProgressText
            
            horizontalStackView.addArrangedSubview(titleLabel)
            horizontalStackView.addArrangedSubview(sevenElevenImageView)
            horizontalStackView.addArrangedSubview(walmartImageView)
            horizontalStackView.addArrangedSubview(storeLabel)
            
        case "Pharmacy":
            let titleLabel = UILabel()
            titleLabel.text = method.buttonTextKey
            titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
            titleLabel.textColor = .mainText
            
            let pharmaImageView = UIImageView(image: .ic_pharma)
            let sevenElevenPharmaImageView = UIImageView(image: .ic_seven_eleven_pharma)
            
            [sevenElevenPharmaImageView, pharmaImageView,].forEach {
                $0.translatesAutoresizingMaskIntoConstraints = false
                $0.widthAnchor.constraint(equalToConstant: 27).isActive = true
                $0.heightAnchor.constraint(equalToConstant: 27).isActive = true
            }
            
            let plusThree = "+3"
            let storesLabel = "ttpsdk_cash_method_stores_label".localized
            
            let pharmacyLabel = UILabel()
            pharmacyLabel.text = "\(plusThree) \(storesLabel)"
            pharmacyLabel.font = .systemFont(ofSize: 12, weight: .medium)
            pharmacyLabel.textColor = .colorProgressText
            
            horizontalStackView.addArrangedSubview(titleLabel)
            horizontalStackView.addArrangedSubview(sevenElevenPharmaImageView)
            horizontalStackView.addArrangedSubview(pharmaImageView)
            horizontalStackView.addArrangedSubview(pharmacyLabel)
            
        default:
            break
        }
        
        button.addSubview(horizontalStackView)
        
        NSLayoutConstraint.activate([
            horizontalStackView.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            horizontalStackView.centerXAnchor.constraint(equalTo: button.centerXAnchor)
        ])
        
        return button
    }
    
    func createNotAvailableLabel() -> UILabel {
        let notAvailableLabel = UILabel()
        notAvailableLabel.text = "ttpsdk_text_cash_available_title".localized
        notAvailableLabel.font = .systemFont(ofSize: 12)
        notAvailableLabel.textColor = .mainText
        notAvailableLabel.textAlignment = .center
        notAvailableLabel.numberOfLines = 0
        notAvailableLabel.translatesAutoresizingMaskIntoConstraints = false
        return notAvailableLabel
    }
    
    func updateCashMethodButtonStateMethod() {
        let isNameValid = viewModel.isNameValid
        let isEmailValid = viewModel.isEmailValid
        let shouldEnableButtons = isNameValid && isEmailValid
        setCashMethodButtonsEnabled(shouldEnableButtons)
    }
    
    func setCashMethodButtonsEnabled(_ enabled: Bool) {
        for view in cashMethodsStackView.arrangedSubviews {
            if let containerStack = view as? UIStackView, let button = containerStack.arrangedSubviews.first as? UIButton {
                button.isUserInteractionEnabled = enabled && viewModel.availableMethods.contains(button.tag)
                button.alpha = button.isUserInteractionEnabled ? (enabled ? 1.0 : 0.5) : 0.3
            } else if let button = view as? UIButton {
                button.isUserInteractionEnabled = enabled
                button.alpha = button.isUserInteractionEnabled ? (enabled ? 1.0 : 0.5) : 0.3
            }
        }
    }
    
    //MARK: - Fields
    
    func updateFieldsValidStateMethod() {
        viewModel.updateFieldsValidState()
    }
    
    func updateFieldsWithNewDataMethod() {
        viewModel.name = nameTextField.text ?? ""
        viewModel.email = emailTextField.text ?? ""
        viewModel.updateConfigurationWithNewData()
    }
    
    //MARK: - Button Tapped
    
    func payWithCashMethod(_ altPayType: String) {
        viewModel.payWithCash(altPayType: altPayType)
    }
    
    @objc func cashMethodButtonTapped(_ sender: UIButton) {
        updateFieldsWithNewDataMethod()
        guard let altPayType = sender.accessibilityIdentifier else { return }
        payWithCashMethod(altPayType)
    }
}

    // MARK: - Animation Methods

private extension PaymentCashFormView {
    
    @objc func handleDimmingViewTap() {
        endEditing(true)
        nameTextField.resignFirstResponder()
        emailTextField.resignFirstResponder()
    }
    
    @objc func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)
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
    
    func setupGestureRecognizers() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        modalContainerView.addGestureRecognizer(panGesture)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDimmingViewTap))
        dimmingView.addGestureRecognizer(tapGesture)
    }
    
    func animateModalPresentation() {
        self.layoutIfNeeded()
        modalContainerView.transform = CGAffineTransform(translationX: 0, y: self.bounds.height)
        UIView.animate(withDuration: 0.9, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
            self.modalContainerView.transform = .identity
        }, completion: { _ in
            self.containerOriginalY = self.modalContainerView.frame.origin.y
        })
    }
    
    func dismissModalWithAnimation(completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.35, animations: {
            self.modalContainerView.transform = CGAffineTransform(translationX: 0, y: self.bounds.height)
        }) { [weak self] _ in
            self?.viewModel.triggerDismiss()
            completion?()
        }
    }
}

    // MARK: - UITextFieldDelegate Methods

extension PaymentCashFormView: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        updateAppearance(for: textField, isEditing: true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == nameTextField {
            viewModel.name = textField.text ?? ""
        } else if textField == emailTextField {
            viewModel.email = textField.text ?? ""
        }
        updateFieldsWithNewDataMethod()
        updateAppearance(for: textField, isEditing: false)
        updateFieldsValidStateMethod()
        updateCashMethodButtonStateMethod()
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if textField == nameTextField {
            viewModel.name = textField.text ?? ""
        } else if textField == emailTextField {
            viewModel.email = textField.text ?? ""
        }
        updateFieldsValidStateMethod()
        updateCashMethodButtonStateMethod()
    }
    
    private func updateAppearance(for textField: UITextField, isEditing: Bool) {
        if textField == emailTextField {
            let color: CGColor = isEditing ? UIColor.mainBlue.cgColor : (textField.text?.emailIsValid() ?? false ? UIColor.border.cgColor : UIColor.errorBorder.cgColor)
            updateTextFieldAppearance(textField, withColor: color, textColor: .mainText)
        } else {
            let color: CGColor = isEditing ? UIColor.mainBlue.cgColor : (textField.text?.isEmpty ?? true ? UIColor.errorBorder.cgColor : UIColor.border.cgColor)
            updateTextFieldAppearance(textField, withColor: color, textColor: .mainText)
        }
    }
    
    private func updateTextFieldAppearance(_ textField: UITextField?, withColor color: CGColor, textColor: UIColor) {
        guard let textField = textField else { return }
        textField.layer.borderColor = color
        textField.textColor = textColor
    }
    
    private func validateTextField(_ textField: UITextField) {
        if textField == nameTextField {
            updateTextFieldAppearance(textField, withColor: textField.text?.isEmpty ?? true ? UIColor.errorBorder.cgColor : UIColor.border.cgColor, textColor: .mainText)
        }
    }
    
    @objc private func handleTapOutsideTextField() {
        self.endEditing(true)
        updateTextFieldAppearance(emailTextField, withColor: emailTextField.text?.emailIsValid() ?? false ? UIColor.border.cgColor : UIColor.errorBorder.cgColor, textColor: .mainText)
        validateTextField(nameTextField)
    }
}
