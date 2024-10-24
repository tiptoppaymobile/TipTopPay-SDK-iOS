//
//  PaymentCashFormViewController.swift
//  sdk
//
//  Created by TipTopPay on 09.10.2024.
//  Copyright © 2024 TipTopPay. All rights reserved.
//

import Foundation
import UIKit
import SafariServices

final class PaymentCashFormViewController: BaseViewController {
    
    private var cashView: PaymentCashFormView
    private let configuration: TipTopPayConfiguration
    private let viewModel: PaymentCashFormViewModel
    private var isDismissing = false
    
    // MARK: - Initializer
    
    init(configuration: TipTopPayConfiguration) {
        self.configuration = configuration
        self.viewModel = PaymentCashFormViewModel(configuration: configuration)
        self.cashView = PaymentCashFormView(viewModel: viewModel)
        super.init(nibName: nil, bundle: .mainSdk)
    }
    
    // MARK: - Static method to present the view controller
    
    class func present(with configuration: TipTopPayConfiguration, from: UIViewController) {
        let controller = PaymentCashFormViewController(configuration: configuration)
        controller.modalPresentationStyle = .overFullScreen
        controller.modalTransitionStyle = .crossDissolve
        controller.view.isOpaque = false
        controller.cashView.onDismiss = { [weak controller] in
            DispatchQueue.main.async {
                guard let controller = controller else { return }
                controller.handleDismiss()
            }
        }
        from.present(controller, animated: true, completion: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.view = cashView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        onPaymentSuccessMethod()
        onPaymentErrorMethod()
    }
    
    // MARK: - Method to handle dismiss
    
    private func handleDismiss() {
        guard !isDismissing else {
            return
        }
        
        isDismissing = true
        
        let presentingController = self.presentingViewController
        self.dismiss(animated: false) { [weak self] in
            guard let self = self else { return }
            
            if let presentingController = presentingController, presentingController.viewIfLoaded?.window != nil {
                PaymentForm.present(with: self.configuration, from: presentingController)
            }
            self.isDismissing = false
        }
    }
}

private extension PaymentCashFormViewController {
    
    // MARK: - Success
    
    func onPaymentSuccessMethod() {
        viewModel.onPaymentSuccess = { [weak self] response in
            guard let transactionId = response?.model?.transactionID else { return }
            guard let link = response?.model?.extensionData?.link else {
                self?.showAlert(title: nil, message: .noData)
                return
            }
            if let url = URL(string: link) {
                let safariVC = SFSafariViewController(url: url)
                safariVC.delegate = self
                self?.present(safariVC, animated: true)
            }
            self?.configuration.paymentDelegate.paymentFinished(transactionId)
        }
    }
    
    // MARK: - Error
    
    func onPaymentErrorMethod() {
        viewModel.onPaymentError = { [weak self] error in
            guard let controller = self?.presentingViewController else { return }
            let errorMessage = error.message
            self?.dismiss(animated: true) {
                if let configuration = self?.configuration {
                    PaymentProcessForm.present(with: configuration, cryptogram: nil, email: nil, state: .failed(errorMessage), from: controller)
                }
            }
        }
    }
}

    //MARK: - SFSafariViewControllerDelegate

extension PaymentCashFormViewController: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        viewModel.isLoading = false
    }
}
