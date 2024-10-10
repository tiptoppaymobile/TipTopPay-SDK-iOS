//
//  BasePaymentForm.swift
//  sdk
//
//  Created by TipTopPay on 16.09.2020.
//  Copyright © 2020 TipTopPay. All rights reserved.
//

import UIKit

public class PaymentCardForm: PaymentForm {
    
    // MARK: - Private properties
    
    private var arrayChoseData: [String] = ["One", "Two", "Three"]
    private lazy var chevronSelectChoseView: ChevronSelectChoseView = .init(frame: view.bounds, style: .plain)
    private var isOpenTableView = false
    
    @IBOutlet weak var interestFreeMonthsLabel: UILabel!
    @IBOutlet weak var errorInstallmentsLabel: UILabel!
    @IBOutlet weak var selectInstallmentsLabel: UILabel!
    @IBOutlet weak var intallmentsStackView: UIStackView!
    @IBOutlet weak var errorInstallmentsView: UIView!
    @IBOutlet weak var chooseStackView: UIStackView!
    @IBOutlet private weak var cardNumberTextField: TextField!
    @IBOutlet private weak var cardExpDateTextField: TextField!
    @IBOutlet private weak var cardCvvTextField: TextField!
    @IBOutlet private weak var containerCardBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var mainCardStackView: UIStackView!
    @IBOutlet private weak var iconCvvCard: UIImageView!
    @IBOutlet private weak var containerHeightConstraint: NSLayoutConstraint?
    @IBOutlet private weak var isActiveTopConstraint: NSLayoutConstraint?
    @IBOutlet private weak var scanButton: Button!
    @IBOutlet private weak var infoButton: UIButton!
    @IBOutlet private weak var payButton: Button!
    @IBOutlet private weak var cardTypeIcon: UIImageView!
    @IBOutlet private weak var cardLabel: UILabel!
    @IBOutlet private weak var cardView: View!
    @IBOutlet private weak var expDateView: View!
    @IBOutlet private weak var cvvView: View!
    @IBOutlet private weak var threeDsView: UIView!
    @IBOutlet private weak var cardPlaceholder: UILabel!
    @IBOutlet private weak var expDatePlaceholder: UILabel!
    @IBOutlet private weak var cvvPlaceholder: UILabel!
    @IBOutlet private weak var stackInpitMainStackView: UIStackView!
    @IBOutlet private weak var eyeOpenButton: Button!
    @IBOutlet private weak var paymentCardLabel: UILabel!
    @IBOutlet private weak var paymentAttentionLabel: UILabel!
    private let alertInfoView = AlertInfoView(title: "ttp_sdk_three_ds_popup".localized)
    private var constraint: NSLayoutConstraint!
    lazy var defaultHeight: CGFloat = self.mainCardStackView.frame.height
    let maximumContainerHeight: CGFloat = UIScreen.main.bounds.height - 64
    lazy var currentContainerHeight: CGFloat = mainCardStackView.frame.height
    var cardNumberTimer: Timer?
    
    var onPayClicked: ((_ cryptogram: String, _ email: String?, _ term: Int? ) -> ())?
    
    private var selectedTerm: Int = 0
    
    @discardableResult
    public class func present(with configuration: TipTopPayConfiguration, from: UIViewController, completion: (() -> ())?) -> PaymentForm? {
        let storyboard = UIStoryboard.init(name: "PaymentForm", bundle: Bundle.mainSdk)
        
        guard let controller = storyboard.instantiateViewController(withIdentifier: "PaymentForm") as? PaymentForm else {
            return nil
        }
        
        controller.configuration = configuration
        controller.show(inViewController: from, completion: completion)
        
        return controller
    }
    
    func updatePayButtonState() {
        let isValid = isValid()
        setButtonsAndContainersEnabled(isEnabled: isValid)
    }
    
    private func setButtonsAndContainersEnabled(isEnabled: Bool) {
        self.payButton.isUserInteractionEnabled = isEnabled
        self.payButton.setAlpha(isEnabled ? 1.0 : 0.3)
    }
    
    @objc private func secureButtonTapped(_ sender: UIButton) {
        cardCvvTextField.becomeFirstResponder()
        let isSelected = sender.isSelected
        sender.isSelected = !isSelected
        cardCvvTextField.isSecureTextEntry = !isSelected
        
        let image = isSelected ? EyeStatus.open.image : EyeStatus.closed.image
        eyeOpenButton.setImage(image, for: .normal)
    }
    
    
    @IBAction func dismissButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    func setupEyeButton() {
        eyeOpenButton.addTarget(self, action: #selector(secureButtonTapped), for: .touchUpInside)
        eyeOpenButton.setImage(UIImage(named: EyeStatus.closed.toString()), for: .normal)
        eyeOpenButton.tintColor = .clear
        eyeOpenButton.isSelected = true
        cardCvvTextField.isSecureTextEntry = true
    }
    
    public override func viewDidLoad() {
        
        super.viewDidLoad()
        alertInfoView.isHidden = true
        setupEyeButton()
        setupPanGesture()
        containerHeightConstraint?.constant = mainCardStackView.frame.height
        paymentAttentionLabel.text = "ttp_sdk_three_ds_label".localized
        cardNumberTextField.delegate = self
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(addAction(_:)))
        chooseStackView.addGestureRecognizer(tap)
        
        chooseStackView.layer.cornerRadius = 10
        chooseStackView.layer.borderWidth = 2
        chooseStackView.layer.borderColor = UIColor(red: 226/255.0, green: 232/255.0, blue: 239/255.0, alpha: 1).cgColor
        
        if configuration.region == .MX {
            threeDsView.isHidden = false
        }
        
        if configuration.scanner == nil {
            scanButton.isHidden = true
        } else {
            self.scanButton.onAction = { [weak self] in
                guard let self = self else {
                    return
                }
                if let controller = self.configuration.scanner?.startScanner(completion: { number, month, year, cvv in
                    self.cardNumberTextField.text = number?.formattedCardNumber()
                    if let month = month, let year = year {
                        let y = year % 100
                        self.cardExpDateTextField.cardExpText = String(format: "%02d/%02d", month, y)
                    }
                    self.cardCvvTextField.text = cvv
                    
                    self.updatePaymentSystemIcon(cardNumber: number)
                }) {
                    self.present(controller, animated: true, completion: nil)
                }
            }
        }
        configureTextFields()
        hideKeyboardWhenTappedAround()
        setButtonsAndContainersEnabled(isEnabled: false)
        paymentCardLabel.textColor = .mainText
        cardLabel.text = "ttpsdk_text_card_hint_number".localized
        
        cardNumberTextField.textColor = .mainText
        cardExpDateTextField.textColor = .mainText
        cardCvvTextField.textColor = .mainText
        
        cardLabel.textColor = .colorProgressText
        expDatePlaceholder.textColor = .colorProgressText
        expDatePlaceholder.text = "ttpsdk_text_card_hint_exp".localized
        cvvPlaceholder.textColor = .colorProgressText
        cvvPlaceholder.text = "ttpsdk_text_card_hint_cvv".localized
        selectInstallmentsLabel.text = "ttpsdk_text_card_select_installments_label".localized
        errorInstallmentsLabel.text = "ttpsdk_text_card_error_installments_label".localized
        interestFreeMonthsLabel.text = "ttpsdk_text_card_pay_term_installments".localized
        
        setupAlertView()
        infoButton.addTarget(self, action: #selector(infoButtonAction(_:)), for: .touchUpInside)
        
        chevronSelectChoseView.myDelegate = self
        view.addSubview(chevronSelectChoseView)
        chevronSelectChoseView.isHidden = true
    }
    
    private func paymentCardMethod() {
        
        if !configuration.paymentData.isInstallmentsMode {
            
            errorInstallmentsView.isHidden = true
            
            let paymentData = configuration.paymentData
            
            let payTitle = "ttpsdk_text_card_pay_button".localized
            paymentCardLabel.text = "ttpsdk_text_card_title".localized
            
            self.payButton.setTitle("\(payTitle) \(paymentData.amount) \(Currency.getCurrencySign(code: paymentData.currency))", for: .normal)
            
            self.payButton.onAction = { [weak self] in
                guard let self = self else {
                    return
                }
                
                guard self.isValid(), let cryptogram = Card.makeCardCryptogramPacket(self.cardNumberTextField.text!, expDate: self.cardExpDateTextField.cardExpText!, cvv: self.cardCvvTextField.text!, merchantPublicID: self.configuration.publicId)
                else {
                    self.showAlert(title: .errorWord, message: .errorCreatingCryptoPacket)
                    return
                }
                
                DispatchQueue.main.async {
                    self.dismiss(animated: true) { [weak self] in
                        guard let self = self else {
                            return
                        }
                        self.onPayClicked?(cryptogram, paymentData.email, nil)
                    }
                }
            }
        }
    }
    
    private func paymentInstallmentsMethod() {
        
        if configuration.paymentData.isInstallmentsMode {
            intallmentsStackView.isHidden = false
            
            payButton.backgroundColor = UIColor(red: 23/255.0, green: 88/255.0, blue: 146/255.0, alpha: 1)
            
            let payTitle = "ttpsdk_text_card_pay_button_installments".localized
            paymentCardLabel.text = "\(configuration.paymentData.amount) \(configuration.paymentData.currency)"
            self.payButton.setTitle("\(payTitle)", for: .normal)
            
            self.payButton.onAction = { [weak self] in
                guard let self = self else {
                    return
                }
                
                guard self.isValid(), let cryptogram = Card.makeCardCryptogramPacket(self.cardNumberTextField.text!, expDate: self.cardExpDateTextField.cardExpText!, cvv: self.cardCvvTextField.text!, merchantPublicID: self.configuration.publicId)
                else {
                    self.showAlert(title: .errorWord, message: .errorCreatingCryptoPacket)
                    return
                }
                
                DispatchQueue.main.async {
                    self.dismiss(animated: true) { [weak self] in
                        guard let self = self else {
                            return
                        }
                        
                        self.onPayClicked?(cryptogram, self.configuration.paymentData.email, self.selectedTerm)
                    }
                }
            }
        }
    }
    
    private func setupAlertView() {
        view.addSubview(alertInfoView)
        alertInfoView.translatesAutoresizingMaskIntoConstraints = false
        alertInfoView.alpha = 0
        
        NSLayoutConstraint.activate([
            alertInfoView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            alertInfoView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1),
        ])
        
        constraint = alertInfoView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        constraint.isActive = true
    }
    
    func setupPanGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.handlePanGesture(gesture:)))
        panGesture.delaysTouchesBegan = false
        panGesture.delaysTouchesEnded = false
        containerView.addGestureRecognizer(panGesture)
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if configuration.paymentData.isInstallmentsMode {
            paymentInstallmentsMethod()
        } else {
            paymentCardMethod()
        }
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        containerHeightConstraint?.constant = -defaultHeight
        presentThreeDsAttentionView(isOn: true)
    }
    
    private func presentThreeDsAttentionView(isOn: Bool) {
        UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseInOut, animations: {
            self.isActiveTopConstraint?.isActive = !isOn
            self.view.layoutIfNeeded()
        })
    }
    
    // MARK: Pan gesture handler
    
    @objc func handlePanGesture(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        let isDraggingDown = translation.y > 0
        
        guard isDraggingDown else { return }
        
        let newHeight = currentContainerHeight - translation.y
        let percent = 15.0
        let newContainerHeight = currentContainerHeight - ((currentContainerHeight * percent) / 100)
        
        switch gesture.state {
        case .changed:
            if newHeight > defaultHeight && newHeight < maximumContainerHeight {
                containerHeightConstraint?.constant = -newHeight
                view.layoutIfNeeded()
            }
        case .ended:
            if newHeight < newContainerHeight {
                UIView.animate(withDuration: 0.9, animations: {
                    self.animateDismissView()
                }) { _ in
                    let parent = self.presentingViewController
                    self.dismiss(animated: true) {
                        if let parent = parent {
                            if !self.configuration.disableApplePay {
                                PaymentForm.present(with: self.configuration, from: parent)
                            } else {
                                PaymentForm.present(with: self.configuration, from: parent)
                            }
                        }
                    }
                }
            } else {
                UIView.animate(withDuration: 0.9) {
                    self.animateContainerHeight(self.defaultHeight)
                }
            }
        default:
            break
        }
    }
    
    func animateContainerHeight(_ height: CGFloat) {
        self.containerHeightConstraint?.constant = -height
        self.view.layoutIfNeeded()
        currentContainerHeight = height
    }
    
    func animateDismissView() {
        self.containerHeightConstraint?.constant = view.bounds.height
        self.view.layoutIfNeeded()
    }
    
    func setInputFieldValues(fieldType: InputFieldType, placeholderColor: UIColor, placeholderText: String, borderViewColor: UIColor, textFieldColor: UIColor? = .mainText ) {
        switch fieldType {
        case .card:
            self.cardPlaceholder.textColor = placeholderColor
            self.cardPlaceholder.text = placeholderText
            self.cardView.layer.borderColor = borderViewColor.cgColor
            self.cardNumberTextField.textColor = textFieldColor
        case .expDate:
            self.expDatePlaceholder.textColor = placeholderColor
            self.expDatePlaceholder.text = placeholderText
            self.expDateView.layer.borderColor = borderViewColor.cgColor
            self.cardExpDateTextField.textColor = textFieldColor
        case .cvv:
            self.cvvPlaceholder.textColor = placeholderColor
            self.cvvPlaceholder.text = placeholderText
            self.cvvView.layer.borderColor = borderViewColor.cgColor
            self.cardCvvTextField.textColor = textFieldColor
        }
    }
    
    private func configureTextFields() {
        
        [cardNumberTextField, cardExpDateTextField, cardCvvTextField].forEach { textField in
            textField.addTarget(self, action: #selector(didChange(_:)), for: .editingChanged)
            textField.addTarget(self, action: #selector(didBeginEditing(_:)), for: .editingDidBegin)
            textField.addTarget(self, action: #selector(didEndEditing(_:)), for: .editingDidEnd)
            textField.addTarget(self, action: #selector(shouldReturn(_:)), for: .editingDidEndOnExit)
        }
    }
    
    private func isValid() -> Bool {
        let cardNumberIsValid = Card.isCardNumberValid(self.cardNumberTextField.text?.formattedCardNumber())
        let cardExpIsValid = Card.isExpDateValid(self.cardExpDateTextField.cardExpText?.formattedCardExp())
        let cardCvvIsValid = Card.isCvvValid(self.cardNumberTextField.text?.formattedCardNumber(), self.cardCvvTextField.text?.formattedCardCVV())
        
        let isInstallmentAllowed = self.errorInstallmentsView.isHidden
        
        if !isInstallmentAllowed {
            return false
        }
        
        let isFullPaymentSelected = selectedTerm == 0
        let termIsValid = isFullPaymentSelected || (selectedTerm > 0)
        
        return cardNumberIsValid && cardExpIsValid && cardCvvIsValid && termIsValid
    }
    
    private func validateAndErrorCardNumber(){
        if let cardNumber = self.cardNumberTextField.text?.formattedCardNumber() {
            self.cardNumberTextField.isErrorMode = !Card.isCardNumberValid(cardNumber)
        }
    }
    
    private func validateAndErrorCardExp(){
        if let cardExp = self.cardExpDateTextField.cardExpText?.formattedCardExp() {
            let text = cardExp.replacingOccurrences(of: " ", with: "")
            self.cardExpDateTextField.isErrorMode = !Card.isExpDateValid(text)
        }
    }
    
    private func validateAndErrorCardCVV(){
        self.cardCvvTextField.isErrorMode = !Card.isCvvValid(self.cardNumberTextField.text?.formattedCardNumber(), self.cardCvvTextField.text)
    }
    
    private func updatePaymentSystemIcon(cardNumber: String?){
        if let number = cardNumber {
            let cardType = Card.cardType(from: number)
            if cardType != .unknown {
                self.cardTypeIcon.image = cardType.getIcon()
                self.cardTypeIcon.isHidden = false
                self.scanButton.isHidden = true
            } else {
                self.cardTypeIcon.isHidden = true
                self.scanButton.isHidden = self.configuration.scanner == nil
            }
        } else {
            self.cardTypeIcon.isHidden = true
            self.scanButton.isHidden = self.configuration.scanner == nil
        }
    }
    
    @objc internal override func onKeyboardWillShow(_ notification: Notification) {
        super.onKeyboardWillShow(notification)
        
        self.containerCardBottomConstraint.constant = self.keyboardFrame.height
        
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
    }
    
    @objc internal override func onKeyboardWillHide(_ notification: Notification) {
        super.onKeyboardWillHide(notification)
        
        self.containerCardBottomConstraint.constant = 0
        
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
    }
    
}

//MARK: - Delegates for TextField

extension PaymentCardForm {
    
    private var isHiddenCvv: Bool {
        guard let text = cardNumberTextField.text else { return false }
        return Card.isHumoCard(cardNumber: text) || Card.isUzcardCard(cardNumber: text)
    }
    
    /// Did Begin Editings
    /// - Parameter textField:
    @objc private func didBeginEditing(_ textField: UITextField) {
        
        switch textField {
            
        case cardNumberTextField:
            if let cardNumber = cardNumberTextField.text?.formattedCardNumber() {
                cardNumberTextField.text = cardNumber
                
                if !cardNumber.isEmpty || !Card.isCardNumberValid(cardNumber) {
                    setInputFieldValues(fieldType: .card, placeholderColor: ValidState.border.color, placeholderText: "ttpsdk_text_card_hint_number".localized, borderViewColor: ValidState.normal.color, textFieldColor: ValidState.text.color)
                }
            }
            
        case cardExpDateTextField:
            if let cardExp = cardExpDateTextField.cardExpText?.formattedCardExp() {
                cardExpDateTextField.cardExpText = cardExp
                
                if !cardExp.isEmpty || !Card.isExpDateValid(cardExp) {
                    setInputFieldValues(fieldType: .expDate, placeholderColor: ValidState.border.color, placeholderText: "ttpsdk_text_card_hint_exp".localized, borderViewColor: ValidState.normal.color, textFieldColor: ValidState.text.color)
                }
            }
            
        case cardCvvTextField:
            if let text = cardCvvTextField.text?.formattedCardCVV() {
                cardCvvTextField.text = text
                
                let cardNumber = cardNumberTextField.text?.formattedCardNumber()
                
                if !cardCvvTextField.isEmpty || !Card.isCvvValid(cardNumber, text) {
                    setInputFieldValues(fieldType: .cvv, placeholderColor: ValidState.border.color, placeholderText: PlaceholderType.correctCvv.toString(), borderViewColor: ValidState.normal.color, textFieldColor: ValidState.text.color)
                }
            }
        default: break
        }
    }
    
    /// Did Change
    /// - Parameter textField:
    @objc private func didChange(_ textField: UITextField) {
        cvvView.isHidden = isHiddenCvv
        
        switch textField {
            
        case cardNumberTextField:
            updatePayButtonState()
            
            if let cardNumber = cardNumberTextField.text?.formattedCardNumber() {
                cardNumberTextField.text = cardNumber
                
                updatePaymentSystemIcon(cardNumber: cardNumber)
                
                if cardNumber.isEmpty {
                    setInputFieldValues(fieldType: .card, placeholderColor: ValidState.border.color, placeholderText: "ttpsdk_text_card_hint_number".localized, borderViewColor: ValidState.normal.color)
                    return
                }
                
                if Card.isCardNumberValid(cardNumber) {
                    setInputFieldValues(fieldType: .card, placeholderColor: ValidState.border.color, placeholderText: "ttpsdk_text_card_hint_number".localized, borderViewColor: ValidState.normal.color)
                }
                
                _ = cardNumber.clearCardNumber()
                
                //MAX CARD NUMBER LENGHT
                cardNumberTextField.isErrorMode = false
            }
            
        case cardExpDateTextField:
            updatePayButtonState()
            
            if let cardExp = cardExpDateTextField.cardExpText?.formattedCardExp() {
                cardExpDateTextField.cardExpText = cardExp
                cardExpDateTextField.isErrorMode = false
                
                if cardExp.isEmpty {
                    setInputFieldValues(fieldType: .expDate, placeholderColor: ValidState.border.color, placeholderText: "ttpsdk_text_card_hint_exp".localized, borderViewColor: ValidState.normal.color)
                    return
                }
                
                if Card.isExpDateValid(cardExp) {
                    setInputFieldValues(fieldType: .expDate, placeholderColor: ValidState.border.color, placeholderText: "ttpsdk_text_card_hint_exp".localized, borderViewColor: ValidState.normal.color)
                }
            }
            
        case cardCvvTextField:
            updatePayButtonState()
            
            if let text = cardCvvTextField.text?.formattedCardCVV() {
                cardCvvTextField.text = text
                
                iconCvvCard.isHidden = !cardCvvTextField.isEmpty
                eyeOpenButton.isHidden = cardCvvTextField.isEmpty
                cardCvvTextField.isErrorMode = false
                
                if text.isEmpty {
                    setInputFieldValues(fieldType: .cvv, placeholderColor: ValidState.border.color, placeholderText: "ttpsdk_text_card_hint_cvv".localized, borderViewColor: ValidState.normal.color)
                    iconCvvCard.isHidden = false
                    return
                }
                
                let cardNumber = cardNumberTextField.text?.formattedCardNumber()
                
                if Card.isCvvValid(cardNumber, text) {
                    setInputFieldValues(fieldType: .cvv, placeholderColor: ValidState.border.color, placeholderText: "ttpsdk_text_card_hint_cvv".localized, borderViewColor: ValidState.normal.color)
                }
                
                if text.count == 4 {
                    cardCvvTextField.resignFirstResponder()
                }
            }
        default: break
        }
    }
    
    /// Did End Editing
    /// - Parameter textField:
    @objc private func didEndEditing(_ textField: UITextField) {
        
        switch textField {
            
        case cardNumberTextField:
            if let cardNumber = cardNumberTextField.text?.formattedCardNumber() {
                cardNumberTextField.text = cardNumber
                
                if !Card.isCardNumberValid(cardNumber) {
                    setInputFieldValues(fieldType: .card, placeholderColor: ValidState.error.color, placeholderText: "ttpsdk_text_card_hint_number_incorrect".localized, borderViewColor: ValidState.error.color)
                    
                    if cardNumber.isEmpty {
                        setInputFieldValues(fieldType: .card, placeholderColor: ValidState.error.color, placeholderText: "ttpsdk_text_card_hint_number".localized, borderViewColor: ValidState.error.color)
                    }
                }
                else {
                    cardView.layer.borderColor = ValidState.border.color.cgColor
                }
                validateAndErrorCardNumber()
            }
            
        case cardExpDateTextField:
            if let cardExp = cardExpDateTextField.cardExpText?.formattedCardExp() {
                cardExpDateTextField.cardExpText = cardExp
                
                if !Card.isExpDateValid(cardExp) {
                    setInputFieldValues(fieldType: .expDate, placeholderColor: ValidState.error.color, placeholderText: "ttpsdk_text_card_hint_exp_error".localized, borderViewColor: ValidState.error.color)
                    
                    if cardExp.isEmpty {
                        setInputFieldValues(fieldType: .expDate, placeholderColor: ValidState.error.color, placeholderText: "ttpsdk_text_card_hint_exp".localized, borderViewColor: ValidState.error.color)
                    }
                }
                else {
                    expDateView.layer.borderColor = ValidState.border.color.cgColor
                }
                validateAndErrorCardExp()
            }
            
        case cardCvvTextField:
            if let cardCvv = cardCvvTextField.text?.formattedCardCVV() {
                cardCvvTextField.text = cardCvv
                
                let cardNumber = cardNumberTextField.text?.formattedCardNumber()
                
                if !Card.isCvvValid(cardNumber, cardCvv) {
                    setInputFieldValues(fieldType: .cvv, placeholderColor: ValidState.error.color, placeholderText: "ttpsdk_text_card_hint_cvv_error".localized, borderViewColor: ValidState.error.color)
                    
                    if cardCvv.isEmpty {
                        setInputFieldValues(fieldType: .cvv, placeholderColor: ValidState.error.color, placeholderText: "ttpsdk_text_card_hint_cvv".localized, borderViewColor: ValidState.error.color)
                    }
                }
                else {
                    cvvView.layer.borderColor = ValidState.border.color.cgColor
                    cvvPlaceholder.textColor = ValidState.border.color
                    
                }
                validateAndErrorCardCVV()
            }
        default: break
        }
    }
    
    /// Should Return
    /// - Parameter textField:
    @objc private func shouldReturn(_ textField: UITextField) {
        
        switch textField {
            
        case cardNumberTextField:
            
            if let cardNumber = self.cardNumberTextField.text?.formattedCardNumber() {
                self.cardNumberTextField.resignFirstResponder()
                if Card.isCardNumberValid(cardNumber) {
                    self.cardExpDateTextField.becomeFirstResponder()
                }
            }
        case cardExpDateTextField:
            
            if let cardExp = self.cardExpDateTextField.text?.formattedCardExp() {
                if cardExp.count == 5 {
                    self.cardCvvTextField.becomeFirstResponder()
                }
            }
            
        case cardCvvTextField:
            
            if let text = self.cardCvvTextField.text?.formattedCardCVV() {
                if text.count == 3 || text.count == 4 {
                    self.cardCvvTextField.resignFirstResponder()
                }
            }
        default: break
        }
    }
}

extension PaymentCardForm {
    
    @objc private func infoButtonAction(_ sender: UIButton) {
        sender.isSelected.toggle()
        setupPositionAlertView(sender)
        animation(sender.isSelected)
    }
    
    //MARK: - AlertView
    
    private func setupPositionAlertView(_ sender: UIButton) {
        let frame = sender.convert(sender.bounds, to: view)
        let height = view.bounds.height - frame.midY + 12
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
}

extension PaymentCardForm: UITextFieldDelegate {
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if let currentText = textField.text, let range = Range(range, in: currentText) {
            let newCardNumber = currentText.replacingCharacters(in: range, with: string)
            let cleanCard = Card.cleanCreditCardNo(newCardNumber)
            if cleanCard.count < 6 {
                cvvView.isHidden = isHiddenCvv
                errorInstallmentsView.isHidden = true
                return true
            }
        }
        
        cardNumberTimer?.invalidate()
        cardNumberTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.sendRequest), userInfo: nil, repeats: false)
        
        return true
    }
    
    @objc private func sendRequest() {
        cardNumberTimer?.invalidate()
        
        if let cardNumber = cardNumberTextField.text, cardNumber.count >= 6 {
            let cleanCardNumber = Card.cleanCreditCardNo(cardNumber)
            
            TipTopPayApi.getBinInfo(cleanCardNumber: cleanCardNumber, with: configuration) { [weak self] model, success in
                guard let self = self else { return }
                guard let isCardAllowed = model?.isCardAllowed else { return }
                
                let hideCvvInput = model?.hideCvvInput ?? false
                self.cvvView.isHidden = hideCvvInput
                
                DispatchQueue.main.async {
                    
                    if self.configuration.paymentData.isInstallmentsMode {
                        self.errorInstallmentsView.isHidden = isCardAllowed
                    } else {
                        self.errorInstallmentsView.isHidden = true
                        
                    }
                    
                    if !isCardAllowed {
                        self.selectedTerm = 0
                        
                    }
                    
                    self.updatePayButtonState()
                }
            }
        }
    }
}

extension PaymentCardForm: ChevronSelectChoseViewDelegate {
    
    func numberOfRow(_ choseView: ChevronSelectChoseView) -> Int {
        let count = configuration.paymentData.installmentConfigurations.count + 1
        return count
    }
    
    func choseView(_ choseView: ChevronSelectChoseView, row: Int) -> String {
        if row == 0 {
            let payFullNow = "ttpsdk_text_card_pay_button_full_installments".localized
            return "\(configuration.paymentData.amount) \(configuration.paymentData.currency) \(payFullNow)"
        }
        let installment = configuration.paymentData.installmentConfigurations[row - 1]
        if let term = installment.term, let monthlyPayment = installment.monthlyPayment {
            let interestFreeMonth = "ttpsdk_text_card_pay_term_installments".localized
            return "\(monthlyPayment) \(configuration.paymentData.currency) x \(term) \(interestFreeMonth)"
        }
        return ""
    }
    
    func choseView(_ choseView: ChevronSelectChoseView, didSelect row: Int) {
        if row == 0 {
            selectedTerm = 0
            let payFullNow = "ttpsdk_text_card_pay_button_full_installments".localized
            interestFreeMonthsLabel.text = "\(configuration.paymentData.amount) \(configuration.paymentData.currency) \(payFullNow)"
        } else {
            let installment = configuration.paymentData.installmentConfigurations[row - 1]
            if let term = installment.term, let monthlyPayment = installment.monthlyPayment {
                selectedTerm = term
                let interestFreeMonth = "ttpsdk_text_card_pay_term_installments".localized
                interestFreeMonthsLabel.text = "\(monthlyPayment) \(configuration.paymentData.currency) x \(term) \(interestFreeMonth)"
            }
        }
        
        updatePayButtonState()
        isOpenTableView = false
        chevronSelectChoseView.isHidden = true
    }
    
    @objc private func addAction(_ sender: UITapGestureRecognizer) {
        isOpenTableView.toggle()
        chevronSelectChoseView.isHidden = !isOpenTableView
        setupPositionChoseView()
        
        if isOpenTableView {
            setupPositionChoseView()
            chevronSelectChoseView.reloadData()
        }
    }
    
    private func setupPositionChoseView() {
        let position = chooseStackView.convert(chooseStackView.bounds, to: view)
        let x = position.minX
        let y = position.maxY
        
        let rowHeight: CGFloat = 44.0
        let totalRows = configuration.paymentData.installmentConfigurations.count + 1
        let totalHeight = rowHeight * CGFloat(totalRows)
        
        let maxHeight: CGFloat = rowHeight * 5
        let height = min(totalHeight, maxHeight)
        
        chevronSelectChoseView.frame = CGRect(x: x, y: y, width: position.width, height: height)
        chevronSelectChoseView.isScrollEnabled = totalHeight > maxHeight
        view.bringSubviewToFront(chevronSelectChoseView)
    }
}
protocol ChevronSelectChoseViewDelegate: AnyObject {
    func numberOfRow(_ choseView: ChevronSelectChoseView) -> Int
    func choseView(_ choseView: ChevronSelectChoseView, row: Int) -> String
    func choseView(_ choseView: ChevronSelectChoseView, didSelect row: Int)
}

final class ChevronSelectChoseView: UITableView, UITableViewDelegate, UITableViewDataSource {
    
    weak var myDelegate: ChevronSelectChoseViewDelegate?
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        dataSource = self
        delegate = self
        
        register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowOpacity = 0.2
        layer.shadowRadius = 4
        layer.masksToBounds = true
        clipsToBounds = false
        layer.cornerRadius = 8
        layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        backgroundColor = .white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myDelegate?.numberOfRow(self) ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let string = myDelegate?.choseView(self, row: indexPath.row)
        cell.textLabel?.text = string
        
        cell.backgroundColor = .clear
        cell.contentView.backgroundColor = .clear
        
        cell.separatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        myDelegate?.choseView(self, didSelect: indexPath.row)
    }
    
}
