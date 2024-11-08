//
//  PaymentSpeiViewController.swift
//  sdk
//
//  Created by TipTopPay on 27.10.2024.
//  Copyright © 2024 TipTopPay. All rights reserved.
//

import Foundation
import Combine
import UIKit

final class PaymentSpeiViewController: BaseViewController {
    
    private let configuration: TipTopPayConfiguration
    private let viewModel: PaymentSpeiViewModel
    private let paymentSpeiView = PaymentSpeiView()
    private var cancellables = Set<AnyCancellable>()
    private var isPresentingProcessForm = false // Флаг, чтобы отслеживать состояние отображения
    
    init(configuration: TipTopPayConfiguration, response: AltPayCashResponse) {
        self.configuration = configuration
        self.viewModel = PaymentSpeiViewModel(response: response, configuration: configuration)
        super.init(nibName: nil, bundle: .mainSdk)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    class func present(with response: AltPayCashResponse, with configuration: TipTopPayConfiguration, from: UIViewController) {
        let controller = PaymentSpeiViewController(configuration: configuration, response: response)
        controller.modalPresentationStyle = .overFullScreen
        controller.modalTransitionStyle = .crossDissolve
        controller.view.isOpaque = false
        controller.view.backgroundColor = .white
        from.present(controller, animated: true, completion: nil)
    }
    
    override func loadView() {
        view = paymentSpeiView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        populateData()
        observeTransactionStatus()
        observeEmailSentSuccessfully()
        dismissButtonTapped()
    }
    
    private func observeEmailSentSuccessfully() {
        
        paymentSpeiView.onSendEmail = { [weak self] email in
            self?.viewModel.sendEmailRequest(email: email)
        }
        
        viewModel.$emailSentSuccessfully
            .sink { [weak self] success in
                if success {
                    DispatchQueue.main.async { [weak self] in
                        guard let updatedEmail = self?.viewModel.paymentSpeiDetails.email, !updatedEmail.isEmpty else {
                            return
                        }
                        self?.paymentSpeiView.showSentEmailComponent(email: updatedEmail)
                    }
                } else if let errorMessage = self?.viewModel.transactionErrorMessage {
                    self?.showAlert(title: nil, message: errorMessage)
                }
            }
            .store(in: &cancellables)
        
    }
    
    private func populateData() {
        paymentSpeiView.configure(with: viewModel.paymentSpeiDetails)
        
        if let email = viewModel.paymentSpeiDetails.email, !email.isEmpty {
            paymentSpeiView.showSentEmailComponent(email: email)
        } else {
            paymentSpeiView.showInputEmailComponent(initialEmail: viewModel.paymentSpeiDetails.email) { [weak self] email in
                self?.viewModel.sendEmailRequest(email: email)
            }
        }
    }
    
    private func observeTransactionStatus() {
        viewModel.$transactionStatus
            .sink { [weak self] status in
                guard let status = status else { return }
                self?.handleTransactionStatus(status)
            }
            .store(in: &cancellables)
    }
    
    private func handleTransactionStatus(_ status: String) {
        guard let controller = presentingViewController else { return }
        
        switch status {
        case "Created", "Pending":
            break
            
        case "Authorized", "Completed", "Cancelled":
            let transaction = Transaction(transactionId: viewModel.paymentSpeiDetails.transactionId)
            presentProcessForm(controller: controller, state: .succeeded(transaction))
            
        case "Declined":
            let errorMessage = viewModel.transactionErrorMessage ?? "ttpsdk_error_5300_extra".localized
            presentProcessForm(controller: controller, state: .failed(errorMessage))
            
        default:
            break
        }
    }
    
    private func presentProcessForm(controller: UIViewController, state: PaymentProcessForm.State) {
        guard !isPresentingProcessForm else { return } // Проверка, чтобы не отображать форму повторно
        isPresentingProcessForm = true
        
        self.dismiss(animated: true) {
            PaymentProcessForm.present(with: self.configuration, cryptogram: nil, email: nil, state: state, from: controller)
            self.isPresentingProcessForm = false
        }
    }
    
    private func dismissButtonTapped() {
        paymentSpeiView.onOtherMethodButtonTapped = { [weak self] in
            self?.presentOtherController()
        }
    }
    
    private func presentOtherController() {
        guard let controller = self.presentingViewController else { return }
        self.dismiss(animated: true) {
            PaymentForm.present(with: self.configuration, from: controller)
        }
    }
    
    deinit {
        cancellables.forEach { $0.cancel() }
    }
}
