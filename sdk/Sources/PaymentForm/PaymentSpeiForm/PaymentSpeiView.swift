//
//  PaymentSpeiView.swift
//  sdk
//
//  Created by TipTopPay on 27.10.2024.
//  Copyright © 2024 TipTopPay. All rights reserved.
//

import Foundation
import UIKit

final class PaymentSpeiView: UIView {
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let clabeView = CopyableFieldView(title: "CLABE")
    private let bankView = CopyableFieldView(title: "ttpsdk_title_bank".localized)
    private let amountView = CopyableFieldView(title: "ttpsdk_title_amount".localized)
    private let conceptView = CopyableFieldView(title: "ttpsdk_title_concept".localized)
    
    var onSendEmail: ((String) -> Void)?
    var onOtherMethodButtonTapped: (() -> Void)?
    var sentEmailComponent: SentEmailComponent?
    var inputEmailComponent: InputEmailComponent?

    private let amountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .mainText
        label.textAlignment = .center
        return label
    }()
    
    private let logoStatusContainerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
        view.backgroundColor = UIColor(red: 1.0, green: 0.87, blue: 0.28, alpha: 0.16)
        return view
    }()
    
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage.iconProgress
        return imageView
    }()
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .mainText
        label.text = "ttpsdk_text_pending_spei".localized
        return label
    }()
    
    private let instructionStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.alignment = .center
        return stack
    }()
    
    private let instructionLabel1: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = "ttpsdk_text_open_spei_bank".localized
        return label
    }()
    
    private let instructionLabel2: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = "ttpsdk_text_using_details".localized
        label.textColor = .gray
        return label
    }()
    
    private let dataStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .fill
        return stack
    }()
    
    let deadlineLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .gray
        label.textAlignment = .center
        return label
    }()
    
    private let emailStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 24
        stack.alignment = .fill
        return stack
    }()
    
    private let emailRowStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        return stack
    }()
    
    private let footerStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 24
        stack.alignment = .center
        return stack
    }()
    
    private let footerLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .gray
        label.numberOfLines = 0
        label.textAlignment = .center
        label.text = "ttpsdk_title_make_spei_payment".localized
        return label
    }()
    
    private let otherMethodButton: UIButton = {
        let otherMethod = "ttpsdk_title_other_method".localized
        let button = UIButton(type: .system)
        button.setTitle("\(otherMethod)", for: .normal)
        button.setTitleColor(.mainBlue, for: .normal)
        return button
    }()

    private let footerLogoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage.ic_secured_by_ttp
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupScrollView()
        setupLayout()
        setupTapGesture()
        setupAction()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupAction() {
        otherMethodButton.addTarget(self, action: #selector(otherMethodButtonTapped), for: .touchUpInside)
    }
    
    @objc private func otherMethodButtonTapped() {
        onOtherMethodButtonTapped?() // Вызываем замыкание при нажатии
    }
    
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        contentView.addGestureRecognizer(tapGesture)
    }

    @objc private func handleTap() {
        endEditing(true)
    }
    
    func showSentEmailComponent(email: String) {
        removeAllEmailComponents()
        let component = SentEmailComponent(email: email) { [weak self] in
            self?.showInputEmailComponent(initialEmail: email) { [weak self] newEmail in
                self?.sendEmail(newEmail)
            }
        }
        addComponent(component)
        sentEmailComponent = component
    }
    
     func showInputEmailComponent(initialEmail: String?, onSendTapped: @escaping (String) -> Void) {
         removeAllEmailComponents()
         
         let component = InputEmailComponent(onSendTapped: { [weak self] newEmail in
             self?.sendEmail(newEmail)
         }, initialEmail: initialEmail)
         
         addComponent(component)
         inputEmailComponent = component
     }
    
    private func sendEmail(_ email: String) {
         onSendEmail?(email)
     }
    
    private func addComponent(_ component: UIView) {
        contentView.addSubview(component)
        component.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            component.topAnchor.constraint(equalTo: deadlineLabel.bottomAnchor, constant: 15),
            component.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            component.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            
            footerStack.topAnchor.constraint(equalTo: component.bottomAnchor, constant: 15),
        ])
    }
    
    private func removeAllEmailComponents() {
        sentEmailComponent?.removeFromSuperview()
        sentEmailComponent = nil
        inputEmailComponent?.removeFromSuperview()
        inputEmailComponent = nil
    }
    
    private func setupScrollView() {
        addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    private func setupLayout() {
        contentView.addSubview(amountLabel)
        contentView.addSubview(logoStatusContainerView)
        logoStatusContainerView.addSubview(logoImageView)
        logoStatusContainerView.addSubview(statusLabel)
        
        instructionStack.addArrangedSubview(instructionLabel1)
        instructionStack.addArrangedSubview(instructionLabel2)
        contentView.addSubview(instructionStack)
        
        dataStack.addArrangedSubview(clabeView)
        dataStack.addArrangedSubview(bankView)
        dataStack.addArrangedSubview(amountView)
        dataStack.addArrangedSubview(conceptView)
        contentView.addSubview(dataStack)
        
        footerStack.addArrangedSubview(footerLabel)
        footerStack.addArrangedSubview(otherMethodButton)
        footerStack.addArrangedSubview(footerLogoImageView)
        
        contentView.addSubview(deadlineLabel)
        contentView.addSubview(footerStack)
        
        amountLabel.translatesAutoresizingMaskIntoConstraints = false
        logoStatusContainerView.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        instructionStack.translatesAutoresizingMaskIntoConstraints = false
        dataStack.translatesAutoresizingMaskIntoConstraints = false
        deadlineLabel.translatesAutoresizingMaskIntoConstraints = false
        footerStack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            amountLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 40),
            amountLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            logoStatusContainerView.topAnchor.constraint(equalTo: amountLabel.bottomAnchor, constant: 16),
            logoStatusContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            logoStatusContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            logoStatusContainerView.heightAnchor.constraint(equalToConstant: 60),
            
            logoImageView.leadingAnchor.constraint(equalTo: logoStatusContainerView.leadingAnchor, constant: 12),
            logoImageView.centerYAnchor.constraint(equalTo: logoStatusContainerView.centerYAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 52),
            logoImageView.heightAnchor.constraint(equalToConstant: 52),
            
            statusLabel.leadingAnchor.constraint(equalTo: logoImageView.trailingAnchor, constant: 12),
            statusLabel.trailingAnchor.constraint(equalTo: logoStatusContainerView.trailingAnchor, constant: -12),
            statusLabel.centerYAnchor.constraint(equalTo: logoImageView.centerYAnchor),
            
            instructionStack.topAnchor.constraint(equalTo: logoStatusContainerView.bottomAnchor, constant: 30),
            instructionStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            instructionStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            
            dataStack.topAnchor.constraint(equalTo: instructionStack.bottomAnchor, constant: 24),
            dataStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            dataStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            
            deadlineLabel.topAnchor.constraint(equalTo: dataStack.bottomAnchor, constant: 24),
            deadlineLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            footerStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            footerStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            footerStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24)
        ])
    }
    
    func configure(with details: PaymentSpeiDetails) {
        amountLabel.text = details.amount
        clabeView.setValue(details.clabe)
        bankView.setValue(details.bank)
        amountView.setValue(details.amount)
        conceptView.setValue(details.paymentConcept)
        let payBefore = "ttpsdk_title_pay_before".localized
        
        let attributedText = NSMutableAttributedString(
            string: "\(payBefore) ",
            attributes: [
                .foregroundColor: UIColor.gray,
                .font: UIFont.systemFont(ofSize: 12)
            ]
        )
        
        let dateText = NSAttributedString(
            string: details.paymentDeadline,
            attributes: [
                .foregroundColor: UIColor.mainText,
                .font: UIFont.systemFont(ofSize: 14)
            ]
        )
        
        attributedText.append(dateText)
        deadlineLabel.attributedText = attributedText
    }

}

final class CopyableFieldView: UIView {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .gray
        return label
    }()
    
    private let valueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .mainText
        label.numberOfLines = 1
        return label
    }()
    
    private let copyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage.ic_copy_spei_image, for: .normal)
        button.tintColor = .gray
        return button
    }()
    
    init(title: String) {
        super.init(frame: .zero)
        titleLabel.text = title
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        layer.cornerRadius = 8
        layer.borderWidth = 1
        layer.borderColor = UIColor.border.cgColor
        backgroundColor = UIColor.colorSpeiField
        addSubview(titleLabel)
        addSubview(valueLabel)
        addSubview(copyButton)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        copyButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 56),
            
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            
            valueLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            valueLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            valueLabel.trailingAnchor.constraint(equalTo: copyButton.leadingAnchor, constant: -8),
            valueLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            
            copyButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            copyButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            copyButton.widthAnchor.constraint(equalToConstant: 16),
            copyButton.heightAnchor.constraint(equalToConstant: 16)
        ])
        
        copyButton.addTarget(self, action: #selector(copyText), for: .touchUpInside)
    }
    
    func setValue(_ value: String) {
        valueLabel.text = value
    }
    
    @objc private func copyText() {
        UIPasteboard.general.string = valueLabel.text
    }
}

final class SentEmailComponent: UIView {
    
    private let emailLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textAlignment = .center
        label.textColor = .mainText
        label.numberOfLines = 0
        return label
    }()
    
    private let anotherEmailButton: UIButton = {
        let sendToAnotherEmail = "ttpsdk_title_send_to_another_email".localized
        let button = UIButton(type: .custom)
        button.setTitle("\(sendToAnotherEmail)", for: .normal)
        button.setTitleColor(.mainBlue, for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 8
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.mainBlue.cgColor
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        button.heightAnchor.constraint(equalToConstant: 56).isActive = true
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.minimumScaleFactor = 0.8
        return button
    }()
    
    private var onAnotherEmailTapped: (() -> Void)?
    let sendByEmailTo = "ttpsdk_title_confirmation_sent_by_email_to".localized
    
    init(email: String, onAnotherEmailTapped: @escaping () -> Void) {
        super.init(frame: .zero)
        self.onAnotherEmailTapped = onAnotherEmailTapped
        emailLabel.text = "\(sendByEmailTo)\n\(email)"
        anotherEmailButton.addTarget(self, action: #selector(anotherEmailTapped), for: .touchUpInside)
        setupLayout()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setupLayout() {
        let stack = UIStackView(arrangedSubviews: [emailLabel, anotherEmailButton])
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .center
        addSubview(stack)
        
        stack.translatesAutoresizingMaskIntoConstraints = false
        anotherEmailButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            anotherEmailButton.leadingAnchor.constraint(equalTo: stack.leadingAnchor),
            anotherEmailButton.trailingAnchor.constraint(equalTo: stack.trailingAnchor)
        ])
    }
    
    @objc private func anotherEmailTapped() {
        onAnotherEmailTapped?()
    }
}

final class InputEmailComponent: UIView, UITextFieldDelegate {
    
    private var onSendTapped: ((String) -> Void)?
    private let initialEmail: String?
    private let customLoader: CustomLoaderView = {
        let loader = CustomLoaderView(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        loader.isHidden = true
        return loader
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textAlignment = .center
        label.textColor = .mainText
        label.text = "ttpsdk_title_confirmation_by_email".localized
        label.numberOfLines = 0
        return label
    }()
    
    private let emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "ttpsdk_text_options_email_title_spei".localized
        textField.borderStyle = .roundedRect
        textField.layer.borderColor = UIColor.gray.cgColor
        textField.layer.borderWidth = 1
        textField.layer.cornerRadius = 8
        textField.heightAnchor.constraint(equalToConstant: 48).isActive = true
        return textField
    }()
    
    private let sendButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage.ic_send_btn_logo, for: .normal)
        button.tintColor = .white
        button.backgroundColor = .mainBlue
        button.layer.cornerRadius = 8
        button.isUserInteractionEnabled = true
        button.widthAnchor.constraint(equalToConstant: 48).isActive = true
        button.heightAnchor.constraint(equalToConstant: 48).isActive = true
        return button
    }()
    
    private let errorContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 1.0, green: 0.8, blue: 0.8, alpha: 0.5)
        view.layer.cornerRadius = 12
        view.isHidden = true
        return view
    }()
    
    private let errorIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage.iconFailed
        imageView.contentMode = .scaleAspectFit
        imageView.widthAnchor.constraint(equalToConstant: 52).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 52).isActive = true
        return imageView
    }()
    
    private let errorTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.textColor = .red
        label.text = "ttpsdk_title_error_sending".localized
        label.numberOfLines = 0
        return label
    }()
    
    private let errorDescriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .red
        label.text = "ttpsdk_title_error_try_again".localized
        label.numberOfLines = 0
        return label
    }()
    
    init(onSendTapped: @escaping (String) -> Void, initialEmail: String?) {
        self.initialEmail = initialEmail
        super.init(frame: .zero)
        sendButton.addSubview(customLoader)
        self.onSendTapped = onSendTapped
        emailTextField.delegate = self
        
        if let initialEmail = initialEmail, initialEmail.isEmpty {
            showTextFieldErrorBorder()
        } else if let initialEmail = initialEmail {
            emailTextField.text = initialEmail
            if !initialEmail.emailIsValid() {
                showTextFieldErrorBorder()
            }
        }
        
        setupLayout()
        sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
        
        
        customLoader.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            customLoader.centerXAnchor.constraint(equalTo: sendButton.centerXAnchor),
            customLoader.centerYAnchor.constraint(equalTo: sendButton.centerYAnchor),
            customLoader.widthAnchor.constraint(equalToConstant: 24),
            customLoader.heightAnchor.constraint(equalToConstant: 24),
        ])
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setupLayout() {
        let textStack = UIStackView(arrangedSubviews: [errorTitleLabel, errorDescriptionLabel])
        textStack.axis = .vertical
        textStack.spacing = 4
        textStack.alignment = .leading
        
        let errorStack = UIStackView(arrangedSubviews: [errorIconImageView, textStack])
        errorStack.axis = .horizontal
        errorStack.spacing = 12
        errorStack.alignment = .center
        
        errorContainerView.addSubview(errorStack)
        errorStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            errorStack.topAnchor.constraint(equalTo: errorContainerView.topAnchor, constant: 12),
            errorStack.leadingAnchor.constraint(equalTo: errorContainerView.leadingAnchor, constant: 12),
            errorStack.trailingAnchor.constraint(equalTo: errorContainerView.trailingAnchor, constant: -12),
            errorStack.bottomAnchor.constraint(equalTo: errorContainerView.bottomAnchor, constant: -12)
        ])
        
        let emailRowStack = UIStackView(arrangedSubviews: [emailTextField, sendButton])
        emailRowStack.axis = .horizontal
        emailRowStack.spacing = 8
        emailRowStack.isUserInteractionEnabled = true
        
        let stack = UIStackView(arrangedSubviews: [titleLabel, errorContainerView, emailRowStack])
        stack.axis = .vertical
        stack.spacing = 12
        stack.alignment = .fill
        stack.isUserInteractionEnabled = true
        
        addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    private func configureInitialState() {
        if let initialEmail = initialEmail, !initialEmail.isEmpty {
            emailTextField.text = initialEmail
            if initialEmail.emailIsValid() {
                emailTextField.layer.borderColor = UIColor.gray.cgColor
                emailTextField.textColor = .mainText
            } else {
                showTextFieldErrorBorder()
            }
        } else {
            showTextFieldErrorBorder()
        }
    }
    
    @objc private func sendButtonTapped() {
        self.endEditing(true)
        setNeedsLayout()
        layoutIfNeeded()
        
        if let email = emailTextField.text, email.emailIsValid() {
            showLoader()
            onSendTapped?(email)
            hideError()
        } else {
            showError()
        }
    }
    
    private func showLoader() {
        customLoader.isHidden = false
        sendButton.setImage(nil, for: .normal)
        customLoader.startAnimating()
    }

    func hideLoader() {
        sendButton.isHidden = false
        customLoader.isHidden = true
        customLoader.stopAnimating()
    }

    func showError() {
        errorContainerView.isHidden = false
    }
    
    func showTextFieldErrorBorder() {
        emailTextField.layer.borderColor = UIColor.red.cgColor
        emailTextField.textColor = .red
    }
    
    func hideError() {
        emailTextField.layer.borderColor = UIColor.gray.cgColor
        emailTextField.textColor = .mainText
        errorContainerView.isHidden = true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.layer.borderColor = UIColor.systemBlue.cgColor
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        validateEmailInput(for: textField.text)
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let updatedText = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? string
        
        DispatchQueue.main.async { [weak self] in
            self?.validateEmailInput(for: updatedText)
        }
        
        return true
    }

    private func validateEmailInput(for text: String?) {
        if let text = text, text.emailIsValid() {
            emailTextField.layer.borderColor = UIColor.gray.cgColor
            emailTextField.textColor = .mainText
        } else {
            emailTextField.layer.borderColor = UIColor.red.cgColor
            emailTextField.textColor = .red
        }
    }
}

final class CustomLoaderView: UIView {
    
    private let lineWidth: CGFloat = 4.0
    private let radius: CGFloat = 12.0
    private let animationDuration: CFTimeInterval = 1.0
    private var rotationAnimation: CABasicAnimation?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLoader()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLoader() {
        let circularPath = UIBezierPath(
            arcCenter: CGPoint(x: bounds.width / 2, y: bounds.height / 2),
            radius: radius,
            startAngle: 0,
            endAngle: .pi * 1.5,
            clockwise: true
        )
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circularPath.cgPath
        shapeLayer.strokeColor = UIColor.white.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = lineWidth
        shapeLayer.lineCap = .round
        layer.addSublayer(shapeLayer)
        
        rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotationAnimation?.fromValue = 0
        rotationAnimation?.toValue = Double.pi * 2
        rotationAnimation?.duration = animationDuration
        rotationAnimation?.repeatCount = .infinity
    }
    
    func startAnimating() {
        guard let rotationAnimation = rotationAnimation else { return }
        layer.add(rotationAnimation, forKey: "rotateAnimation")
    }
    
    func stopAnimating() {
        layer.removeAnimation(forKey: "rotateAnimation")
    }
}
