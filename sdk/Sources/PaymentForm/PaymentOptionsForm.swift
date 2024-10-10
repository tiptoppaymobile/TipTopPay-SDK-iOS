//
//  PaymentSourceForm.swift
//  sdk
//
//  Created by TipTopPay on 16.09.2020.
//  Copyright © 2020 TipTopPay. All rights reserved.
//

import UIKit
import PassKit

final class PaymentOptionsForm: PaymentForm, PKPaymentAuthorizationViewControllerDelegate  {
    @IBOutlet private weak var applePayContainer: View!
    @IBOutlet private weak var payWithCardButton: Button!
    @IBOutlet private weak var footer: FooterForPresentCard!
    @IBOutlet private weak var mainAppleView: View!
    @IBOutlet private weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var paymentLabel: UILabel!
    @IBOutlet private weak var mainInstallmentsView: View!
    @IBOutlet private weak var payWithInstallmentsButton: Button!
    
    private let alertInfoView = AlertInfoView()
    
    private var emailTextField: TextField {
        get { return footer.emailTextField } set { footer.emailTextField = newValue }
    }
    
    private var emailPlaceholder: UILabel! {
        get { return footer.emailLabel } set { footer.emailLabel = newValue}
    }
    
    private var supportedPaymentNetworks: [PKPaymentNetwork] {
        get {
            var arr: [PKPaymentNetwork] = [.visa, .masterCard, .JCB]
            if #available(iOS 12.0, *) {
                arr.append(.maestro)
            }
            if #available(iOS 14.5, *) {
                arr.append(.mir)
            }
            
            return arr
        }
    }
    
    private var isOnKeyboard: Bool = false
    private var isCloused = false
    private let loaderView = LoaderView()
    private var constraint: NSLayoutConstraint!
    private var rotation: Double = 0
    private var applePaymentSucceeded: Bool?
    private var resultTransaction: Transaction?
    private var errorMessage: String?

    private lazy var currentContainerHeight: CGFloat = containerView.bounds.height
    private var heightPresentView: CGFloat { return containerView.bounds.height }
    
    var onCardOptionSelected: ((_  isSaveCard: Bool?, _ isInstallmentsMode: Bool) -> ())?
    
    @discardableResult
    public class func present(with configuration: TipTopPayConfiguration, from: UIViewController, completion: (() -> ())?) -> PaymentForm {
        let storyboard = UIStoryboard.init(name: "PaymentForm", bundle: Bundle.mainSdk)
        
        let controller = storyboard.instantiateViewController(withIdentifier: "PaymentOptionsForm") as! PaymentOptionsForm
    
        controller.configuration = configuration
        controller.open(inViewController: from, completion: completion)
        
        return controller
    }
    
    override func loadView() {
        super.loadView()
        view.addSubview(loaderView)
        loaderView.fullConstraint()
        loaderView.isHidden = true
    }
    
    // MARK: - Lifecycle app
    override func viewDidLoad() {
        super.viewDidLoad()
        isReceiptButtonEnabled(configuration.requireEmail)
        alertInfoView.isHidden = true
        setupButton()
        configureContainers()
        self.hideKeyboardWhenTappedAround()
        emailTextField.delegate = self
        setupEmailPlaceholder()
        setupPanGesture()
        setupAlertView()
       
        getMerchantConfiguration(configuration: configuration)
        paymentLabel.textColor = .mainText
        
        paymentLabel.text = "ttpsdk_text_options_title".localized
        payWithCardButton.setTitle("ttpsdk_text_options_card".localized, for: .normal)
        payWithInstallmentsButton.setTitle("ttpsdk_text_card_pay_button_installments".localized, for: .normal)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        footer.isSelectedSave = configuration.paymentData.saveCard
        
        if !footer.saveCardButtonView {
            self.configuration.paymentData.saveCard = footer.isSelectedSave
        }
    }
    
    private func setupAlertView() {
        view.addSubview(alertInfoView)
        alertInfoView.translatesAutoresizingMaskIntoConstraints = false
        alertInfoView.alpha = 0
        
        NSLayoutConstraint.activate([
            alertInfoView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            alertInfoView.widthAnchor.constraint(equalTo: view.widthAnchor),
        ])
        
        constraint = alertInfoView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        constraint.isActive = true
    }
    
    private func getMerchantConfiguration(configuration: TipTopPayConfiguration) {
        let terminalPublicId = configuration.publicId
        
        guard let apiUrl = configuration.apiUrl else {
            return
        }
        
        if let status = GatewayRequest.payButtonStatus {
            showPayButtons(status, delay: false)
            return
        }

        loaderView.startAnimated("ttp_update_loader".localized)
        
        GatewayRequest.getTerminalConfiguration(baseURL: apiUrl, terminalPublicId: terminalPublicId) { [weak self] response, error in
            guard let self = self else { return }
            
            if let _ = error {
                self.showAlert(title: nil, message: .noCorrectData) {
                    self.presentesionView(false) {
                        self.dismiss(animated: false)
                    }
                }
                return
            }
            
            guard let response = response else {
                self.showAlert(title: nil, message: .noCorrectData) {
                    self.presentesionView(false) {
                        self.dismiss(animated: false)
                    }
                }
                return
            }
            
            if let isCvvRequired = response.isCvvRequired {
                configuration.paymentData.isCvvRequired = isCvvRequired
            }
            
            self.showPayButtons(response, delay: true)
            
            if response.isOnInstallments {
                TipTopPayApi.getInstallmentsCalculateSumByPeriod(with: configuration) { [weak self] response in
                    guard let _ = self else { return }
                    
                    if let installmentsConfiguration = response?.model?.configuration {
                        configuration.paymentData.installmentConfigurations = installmentsConfiguration
                    }
                }
            }
        }
    }
    
    @objc private func updateButtons(_  observer: NSNotification) {
        NotificationCenter.default.removeObserver(self, name: ObserverKeys.networkConnectStatus.key, object: nil)
        guard let value = observer.object as? Bool, value else {
            return
        }
        
        self.currentContainerHeight = 0
        
        UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseInOut) {
            self.heightConstraint.isActive = false
            self.heightConstraint.constant = 0
            self.view.backgroundColor = .init(red: 1, green: 1, blue: 1, alpha: 0)
            self.view.layoutIfNeeded()
        } completion: { _ in
            self.loaderView.isHidden = false
            self.loaderView.alpha = 1
            self.getMerchantConfiguration(configuration: self.configuration)
            
        }
    }
    
    private func showPayButtons(_  status: PayButtonStatus, delay: Bool = true) {
        
        if status.isOnInstallments {
            payWithInstallmentsButton.isHidden = false
            mainInstallmentsView.isHidden = false
        }
        
        self.setupCheckbox(status.isSaveCard)
        view.layoutIfNeeded()
        view.layoutMarginsDidChange()
        
        let deadline: DispatchTime = delay ? (.now() + 2) : .now()
        
        DispatchQueue.main.asyncAfter(deadline: deadline) {
            self.loaderView(isOn: false) {
                self.presentesionView(true) { }
            }
        }
    }
    
    @IBAction func dismissModalButtonTapped(_ sender: UIButton) {
        presentesionView(false) {
            self.dismiss(animated: false)
        }
    }
    
    // MARK: - Private methods
    private func setButtonsAndContainersEnabled(isEnabled: Bool, select: UIButton! = nil) {
        
        let views: [UIView?] = [payWithCardButton, applePayContainer, payWithInstallmentsButton]

        views.forEach {
            guard let view = $0, select != view else { return }
            
            view.isUserInteractionEnabled = isEnabled
            view.alpha = isEnabled ? 1.0 : 0.3
        }
    }
    
    private func isEnabledView(isEnabled: Bool, select: UIButton) {
        setButtonsAndContainersEnabled(isEnabled: isEnabled, select: select)

        footer.subviews.forEach {
            $0.isUserInteractionEnabled = isEnabled
            $0.alpha = isEnabled ? 1.0 : 0.3
        }
        
        alertInfoView.subviews.forEach {
            $0.isUserInteractionEnabled = isEnabled
            $0.alpha = isEnabled ? 1.0 : 0.3
        }
    }
    
    private func resetEmailView(isReceiptSelected: Bool, isEmailViewHidden: Bool, isEmailTextFieldHidden: Bool) {
        footer.isSelectedReceipt = isReceiptSelected
        footer.emailView.isHidden = isEmailViewHidden
        emailTextField.isHidden = isEmailTextFieldHidden
    }
    
    fileprivate func addConfiguration(_ sender: UIButton, _ backgroundColor: UIColor? = nil, _ textColor: UIColor? = nil) {
        if #available(iOS 15.0, *) {
            var configuration = UIButton.Configuration.plain()
            
            if let color = backgroundColor { configuration.baseBackgroundColor = color }
            configuration.imagePadding = 10
            
            if let color = textColor {
                configuration.baseForegroundColor = color
            }
            sender.configuration = configuration
            
            if let color = textColor {
                sender.setTitleColor(color, for: .normal)
                sender.tintColor = color
            }
        } else {
            if let color = backgroundColor { sender.backgroundColor = color }
            if let color = textColor { sender.setTitleColor(color, for: .normal) }
            sender.imageEdgeInsets = .init(top: 0, left: 10, bottom: 0, right: 10)
            sender.titleEdgeInsets = .init(top: 0, left: 10, bottom: 0, right: 10)
        }
    }

    private func setupButton() {
        emailTextField.text = configuration.paymentData.email?.trimmingCharacters(in: .whitespaces)
        isReceiptButtonEnabled(configuration.requireEmail)

        if configuration.requireEmail {
            resetEmailView(isReceiptSelected: false, isEmailViewHidden: false, isEmailTextFieldHidden: false)
            
            if emailTextField.isEmpty {
                setButtonsAndContainersEnabled(isEnabled: false)
            }
            
            if emailTextField.text?.emailIsValid() == false {
                showErrorStateForEmail(with: "ttpsdk_text_options_email_error".localized , borderView: .errorBorder, textColor: .errorBorder, placeholderColor: .errorBorder)
                self.setButtonsAndContainersEnabled(isEnabled: false)
            }
        }
        
        if configuration.requireEmail == false {
            resetEmailView(isReceiptSelected: true, isEmailViewHidden: true, isEmailTextFieldHidden: true)
            emailTextField.isUserInteractionEnabled = true

            if emailTextField.text?.emailIsValid() == false {
                showErrorStateForEmail(with: "ttpsdk_text_options_email_error".localized , borderView: .errorBorder, textColor: .errorBorder, placeholderColor: .errorBorder)
                self.setButtonsAndContainersEnabled(isEnabled: false)
            }
            
            if emailTextField.isEmpty {
                resetEmailView(isReceiptSelected: false, isEmailViewHidden: true, isEmailTextFieldHidden: true)
                self.setButtonsAndContainersEnabled(isEnabled: true)
            }
            
            else {
                resetEmailView(isReceiptSelected: true, isEmailViewHidden: false, isEmailTextFieldHidden: false)
            }
        }
        
        footer.addTarget(self, action: #selector(receiptButtonAction(_:)), type: .receipt)
        footer.addTarget(self, action: #selector(saveButtonAction(_:)), type: .saving)
        footer.addTarget(self, action: #selector(infoButtonAction(_:)), type: .info)
    }
    
    private func normalEmailState() {
        self.emailPlaceholder.text = "ttpsdk_text_options_email_title".localized
        self.footer.emailBorderColor = UIColor.mainBlue
        self.emailTextField.textColor = UIColor.mainText
        self.emailPlaceholder.textColor = UIColor.border
        self.setButtonsAndContainersEnabled(isEnabled: false)
    }
    
    private func isReceiptButtonEnabled(_ isEnabled: Bool ) {
        footer.isHiddenAttentionView = !isEnabled
        footer.isHiddenCardView = isEnabled
        
        if isEnabled {
            footer.emailView.isHidden = false
            emailTextField.isHidden = false
        }
    }
    
    private func setupEmailPlaceholder() {
        emailPlaceholder.text = configuration.requireEmail ? "ttpsdk_text_options_email_title_2".localized : "ttpsdk_text_options_email_title".localized
    }
    
    private func configureContainers() {
        
        if configuration.disableApplePay == true {
            mainAppleView.isHidden = true
            applePayContainer.isHidden = true
        } else {
            initializeApplePay()
            
        }
    }
    
    @objc private func receiptButtonAction(_ sender: UIButton) {
        sender.isSelected.toggle()

        if sender.isSelected {
            self.configuration.paymentData.email = self.emailTextField.text
        } else {
            self.configuration.paymentData.email = nil
        }

        let isEmailValid = self.emailTextField.text?.emailIsValid() ?? false
        if sender.isSelected && isEmailValid == false {
            self.emailTextField.becomeFirstResponder()

            self.normalEmailState()

        } else {
            self.setButtonsAndContainersEnabled(isEnabled: true)

        }
        
        self.footer.emailView.isHidden.toggle()
        self.footer.emailTextField.isHidden.toggle()
        self.view.layoutIfNeeded()
    }
    
    @objc private func saveButtonAction(_ sender: UIButton) {
        sender.isSelected.toggle()
        
        let isSelect = sender.isSelected
        self.configuration.paymentData.saveCard = isSelect
    }
    
    @objc private func infoButtonAction(_ sender: UIButton) {
        sender.isSelected.toggle()
        setupPositionAlertView(sender)
        animation(sender.isSelected)
    }
    
    //MARK: - AlertView
    
    private func setupPositionAlertView(_ sender: UIButton) {
        let frame = sender.convert(sender.bounds, to: view)
        let height = view.bounds.height - frame.minY
        let x = frame.midX
        constraint.constant = -height
        alertInfoView.trianglPosition =  x
    }
    
    //MARK: - animation AlertView
    
    private func animation(_ preview: Bool) {
        self.alertInfoView.isHidden = false
        UIView.animate(withDuration: 0.2) {
            self.alertInfoView.alpha = preview ? 1 : 0
        } completion: { _ in
            if !preview { self.alertInfoView.isHidden = true }
        }
    }
    
    //MARK: - setup Checkbox
    
    private func setupCheckbox(_ isSaveCard: Int?) {
        
        // accountId
        let accountId = configuration.paymentData.accountId
        let isOnAccountId = accountId != nil
        
        // recurrent
        var isOnRecurrent: Bool {
            guard let jsonData = configuration.paymentData.jsonData,
                  let data = jsonData.data(using: .utf8),
                  let value = try? JSONDecoder().decode(TipTopPayModel.self, from: data),
                  let _ = value.tiptoppay?.recurrent
            else { return false }
            return true
        }
        
        var checkBox: SaveCardState {
            switch (isOnAccountId, isOnRecurrent, isSaveCard) {
            case (false, _, _): return .none
            case (_, _, 0): return .none
            case (true, true, 1): return .isOnHint
            case (true, true, 2): return .isOnHint
            case (true, true, 3): return .isOnHint
            case (true, false, 1): return .none
            case (true, false, 2): return .isOnCheckbox
            case (true, false, 3): return .isOnHint
            default: return .none
            }
        }
        
        footer.setup(checkBox)
    }
    
    //MARK: - Keyboard
    @objc override func onKeyboardWillShow(_ notification: Notification) {
        super.onKeyboardWillShow(notification)
        isOnKeyboard = true
        self.heightConstraint.constant = self.keyboardFrame.height
        UIView.animate(withDuration: 0.35, delay: 0) {
            self.view.layoutIfNeeded()
        }
    }

    @objc override func onKeyboardWillHide(_ notification: Notification) {
        super.onKeyboardWillHide(notification)
        isOnKeyboard = false
        self.heightConstraint.constant = 0
        self.currentContainerHeight = 0
        UIView.animate(withDuration: 0.35, delay: 0) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func isValid(email: String? = nil) -> Bool {
        // если email обязателен, то проверка на валидность
        if configuration.requireEmail, let emailIsValid = email?.emailIsValid() {
            return emailIsValid
        }
        
        if let email = email {
            let emailIsValid = !self.footer.isSelectedReceipt || email.emailIsValid() == true
            return emailIsValid
        }
        let emailIsValid = !self.footer.isSelectedReceipt || self.emailTextField.text?.emailIsValid() == true
        return emailIsValid
    }
    
    @objc private func onApplePay(_ sender: UIButton) {
        errorMessage = nil
        resultTransaction = nil
        applePaymentSucceeded = false
        
        let paymentData = self.configuration.paymentData
        if let applePayMerchantId = paymentData.applePayMerchantId {
            let amount = Double(paymentData.amount) ?? 0.0
            
            let request = PKPaymentRequest()
            request.merchantIdentifier = applePayMerchantId
            request.supportedNetworks = self.supportedPaymentNetworks
            request.merchantCapabilities = PKMerchantCapability.capability3DS
            request.countryCode = "RU"
            request.currencyCode = paymentData.currency
            
            let paymentSummaryItems = [PKPaymentSummaryItem(label: self.configuration.paymentData.description ?? "К оплате", amount: NSDecimalNumber.init(value: amount))]
            request.paymentSummaryItems = paymentSummaryItems
            
            if let applePayController = PKPaymentAuthorizationViewController(paymentRequest:
                                                                                request) {
                applePayController.delegate = self
                applePayController.modalPresentationStyle = .formSheet
                self.present(applePayController, animated: true, completion: nil)
            }
        }
    }
    
    @objc private func onSetupApplePay(_ sender: UIButton) {
        PKPassLibrary().openPaymentSetup()
    }
    
    @IBAction private func onCard(_ sender: UIButton) {
        openCardForm()
    }
    
    private func openCardForm() {
        let isSave = self.footer.isSelectedSave
        presentesionView(false) {
            self.dismiss(animated: false) {
                self.onCardOptionSelected?(isSave, false)
            }
        }
    }
    
    @IBAction private func openInstallmentsForm(_ sender: UIButton) {
        openInstallmentsForm()
    }
    
    private func openInstallmentsForm() {
        let isSave = self.footer.isSelectedSave
        presentesionView(false) {
            self.dismiss(animated: false) {
                self.onCardOptionSelected?(isSave, true)
            }
        }
    }
    
    //MARK: - PKPaymentAuthorizationViewControllerDelegate -
    
    private func initializeApplePay() {
        
        mainAppleView.isHidden = false
        applePayContainer.isHidden = false
        
        if let _  = configuration.paymentData.applePayMerchantId, PKPaymentAuthorizationViewController.canMakePayments() {
            let button: PKPaymentButton!
            if PKPaymentAuthorizationController.canMakePayments(usingNetworks: supportedPaymentNetworks) {
                button = PKPaymentButton.init(paymentButtonType: .plain, paymentButtonStyle: .black)
                button.addTarget(self, action: #selector(onApplePay(_:)), for: .touchUpInside)
            } else {
                button = PKPaymentButton.init(paymentButtonType: .setUp, paymentButtonStyle: .black)
                button.addTarget(self, action: #selector(onSetupApplePay(_:)), for: .touchUpInside)
            }
            button.translatesAutoresizingMaskIntoConstraints = false
            
            if #available(iOS 12.0, *) {
                button.cornerRadius = 8
            } else {
                button.layer.cornerRadius = 8
                button.layer.masksToBounds = true
            }
            
            applePayContainer.isHidden = false
            applePayContainer.addSubview(button)
            button.bindFrameToSuperviewBounds()
        } else {
            applePayContainer.isHidden = true
        }
    }
    
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        controller.dismiss(animated: true) { [weak self] in
            guard let self = self else {
                return
            }
            if let status = self.applePaymentSucceeded {
                let state: PaymentProcessForm.State
                
                if status {
                    state = .succeeded(self.resultTransaction)
                } else {
                    state = .failed(self.errorMessage)
                }
                
                let parent = self.presentingViewController
                self.dismiss(animated: true) { [weak self] in
                    guard let self = self else {
                        return
                    }
                    if parent != nil {
                        PaymentProcessForm.present(with: self.configuration, cryptogram: nil, email: nil, state: state, from: parent!, completion: nil)
                    }
                }
            }
        }
    }
    
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
        
        if let cryptogram = payment.convertToString() {
            if configuration.isUseDualMessagePayment {
                self.auth(cardCryptogramPacket: cryptogram, email: nil) { [weak self] status, canceled, transaction, errorMessage in
                    guard let self = self else {
                        return
                    }
                    self.applePaymentSucceeded = status
                    self.resultTransaction = transaction
                    self.errorMessage = errorMessage
                    
                    if status {
                        completion(PKPaymentAuthorizationResult(status: .success, errors: nil))
                    } else {
                        var errors = [Error]()
                        if let message = errorMessage {
                            let userInfo = [NSLocalizedDescriptionKey: message]
                            let error = PKPaymentError(.unknownError, userInfo: userInfo)
                            errors.append(error)
                        }
                        completion(PKPaymentAuthorizationResult(status: .failure, errors: errors))
                    }
                }
            } else {
                self.charge(cardCryptogramPacket: cryptogram, email: nil, term: nil) { [weak self] status, canceled, transaction, errorMessage in
                    guard let self = self else {
                        return
                    }
                    self.applePaymentSucceeded = status
                    self.resultTransaction = transaction
                    self.errorMessage = errorMessage
                    
                    if status {
                        completion(PKPaymentAuthorizationResult(status: .success, errors: nil))
                    } else {
                        var errors = [Error]()
                        if let message = errorMessage {
                            let userInfo = [NSLocalizedDescriptionKey: message]
                            let error = PKPaymentError(.unknownError, userInfo: userInfo)
                            errors.append(error)
                        }
                        completion(PKPaymentAuthorizationResult(status: .failure, errors: errors))
                    }
                }
            }
        } else {
            completion(PKPaymentAuthorizationResult(status: PKPaymentAuthorizationStatus.failure, errors: []))
        }
    }
}

extension PaymentOptionsForm: UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if let text = textField.text,
           let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange,with: string)
            
            if isValid(email: updatedText) || updatedText.isEmpty {
                self.setButtonsAndContainersEnabled(isEnabled: true)
                configureEmailFieldToDefault(borderView: .mainBlue, textColor: .mainText, placeholderColor: .border)
                setupEmailPlaceholder()
                configuration.paymentData.email = updatedText
                
                if updatedText.isEmpty {
                    footer.emailBorderColor = UIColor.mainBlue
                    self.setButtonsAndContainersEnabled(isEnabled: false)
                }
                
            }
            else {
                showErrorStateForEmail(with: "ttpsdk_text_options_email_error".localized , borderView: .errorBorder, textColor: .errorBorder, placeholderColor: .errorBorder)
                self.setButtonsAndContainersEnabled(isEnabled: false)
            }
        }
        return true
    }
    
    func configureEmailFieldToDefault(borderView: UIColor?, textColor: UIColor?, placeholderColor: UIColor?) {
        footer.emailBorderColor = borderView ?? .clear
        emailTextField.textColor = textColor
        emailPlaceholder.textColor = placeholderColor
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        configureEmailFieldToDefault(borderView: .mainBlue, textColor: .mainText, placeholderColor: .border)
        setupEmailPlaceholder()
    }
    
    func showErrorStateForEmail(with message: String, borderView: UIColor?, textColor: UIColor?, placeholderColor: UIColor?) {
        emailTextField.textColor = textColor
        footer.emailBorderColor = borderView ?? .clear
        emailPlaceholder.textColor = placeholderColor
        emailPlaceholder.text = message
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        let emailIsValid = emailTextField.text?.emailIsValid()
        
        if emailIsValid == false {
            setButtonsAndContainersEnabled(isEnabled: false)
            showErrorStateForEmail(with: "ttpsdk_text_options_email_error".localized , borderView: .errorBorder, textColor: .errorBorder, placeholderColor: .errorBorder)
        } else {
            footer.emailBorderColor = UIColor.border
            setButtonsAndContainersEnabled(isEnabled: true)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

private extension PaymentOptionsForm {
    func loaderView(isOn: Bool, completion: @escaping () -> Void) {
        if isOn {
            self.loaderView.isHidden = false
            self.loaderView.startAnimated()
        } else {
            self.loaderView.endAnimated()
        }
        
        UIView.animate(withDuration: 0.2) {
            self.loaderView.alpha = isOn ? 1 : 0
            self.view.layoutIfNeeded()
        } completion: { _ in
            self.loaderView.isHidden = !isOn
            completion()
        }
    }
}

@objc private extension PaymentOptionsForm {
    
    // MARK: Setup PanGesture
    
    func setupPanGesture() {
        let panGesture = UIPanGestureRecognizer()
        panGesture.delaysTouchesBegan = false
        panGesture.delaysTouchesEnded = false
        panGesture.addTarget(self, action: #selector(handlePanGesture(_:)))
        containerView.addGestureRecognizer(panGesture)
    }
    
    // MARK: Pan gesture handler
    
    func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let y = gesture.translation(in: view).y
        let newHeight = currentContainerHeight - y
        
        if isOnKeyboard {
            view.endEditing(true)
            return
        }
        
        let procent = 30.0
        let defaultHeight = ((heightPresentView * procent) / 100)
        
        switch gesture.state {
        case .changed:
            if 0 < newHeight {
                currentContainerHeight = 0
                heightConstraint.constant = 0
                view.layoutIfNeeded()
                return
            }
            
            self.heightConstraint.constant = newHeight
            self.view.layoutIfNeeded()
            
        case .ended, .cancelled:
            
            if -newHeight > defaultHeight {
                presentesionView(false) {
                    self.dismiss(animated: false)
                }
            } else {
                currentContainerHeight = 0
                heightConstraint.constant = 0
                UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseInOut) {
                    self.view.layoutIfNeeded()
                }
            }
            
        default:
            break
        }
    }
    
    func presentesionView(_ isPresent: Bool, completion: @escaping () -> Void) {
        if isCloused { return }
        isCloused = !isPresent
        let alpha = isPresent ? 0.4 : 0
        self.currentContainerHeight = 0
        
        UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseInOut) {
            self.heightConstraint.constant = 0
            self.heightConstraint.isActive = isPresent
            self.view.backgroundColor = .black.withAlphaComponent(alpha)
            self.view.layoutIfNeeded()
        } completion: { _ in
            completion()
        }
    }
}


