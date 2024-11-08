//
//  PaymentSpeiViewModel.swift
//  sdk
//
//  Created by TipTopPay on 27.10.2024.
//  Copyright © 2024 TipTopPay. All rights reserved.
//

import Combine
import Foundation
import TipTopPayNetworking

final class PaymentSpeiViewModel: ObservableObject {
    private let configuration: TipTopPayConfiguration
    private let transactionId: Int64
    private let publicId: String
    @Published private(set) var transactionStatus: String?
    @Published private(set) var transactionErrorMessage: String?
    @Published var emailSentSuccessfully: Bool = false
    private(set) var paymentSpeiDetails: PaymentSpeiDetails
    private var cancellables = Set<AnyCancellable>()
    
    init(response: AltPayCashResponse, configuration: TipTopPayConfiguration) {
        self.configuration = configuration
        self.transactionId = response.model?.transactionID ?? 0
        self.publicId = configuration.publicId
        
        let transaction = response.model
        let extensionData = transaction?.extensionData
        let paymentDeadline = extensionData?.expiredDate ?? "N/A"
        
        let formattedDeadline = PaymentSpeiViewModel.formatDeadlineDate(paymentDeadline)
        
        self.paymentSpeiDetails = PaymentSpeiDetails(
            transactionId: transactionId, amount: "\(transaction?.amount ?? 0) MXN",
            clabe: extensionData?.clabe ?? "N/A",
            bank: "STP",
            paymentConcept: configuration.paymentData.terminalName ?? "",
            paymentDeadline: formattedDeadline,
            email: configuration.paymentData.email ?? ""
        )
        startPollingStatus()
    }
    
    private static func formatDeadlineDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        if let date = formatter.date(from: dateString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateFormat = "MMM dd 'at' HH:mm"
            return displayFormatter.string(from: date)
        } else {
            return "N/A"
        }
    }
    
    private func startPollingStatus() {
        Timer.publish(every: 60.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.checkTransactionStatus()
            }
            .store(in: &cancellables)
    }
    
    private func checkTransactionStatus() {
        TipTopPayApi.getWaitStatus(configuration: configuration, transactionId: transactionId, publicId: publicId)
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.transactionErrorMessage = error.message
                    self?.stopPolling()
                }
            }, receiveValue: { [weak self] response in
                self?.handleTransactionStatus(response)
            })
            .store(in: &cancellables)
    }
    
    private func handleTransactionStatus(_ response: TransactionStatusResponse) {
        guard let status = response.model?.status else { return }
        transactionStatus = status
        
        if status == "Declined" {
            if let statusCode = response.model?.statusCode {
                transactionErrorMessage = ApiError.getFullErrorDescription(code: String(statusCode))
            } else {
                transactionErrorMessage = "ttpsdk_error_5300_extra".localized
            }
        }

        if ["Authorized", "Completed", "Cancelled", "Declined"].contains(status) {
            stopPolling()
        }
    }
    
    private func stopPolling() {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
    }
    
    func sendEmailRequest(email: String) {
        TipTopPayApi.stpSpeiPaymentDetails(with: configuration, email: email, transactionId: transactionId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.emailSentSuccessfully = true
                    if var details = self?.paymentSpeiDetails {
                        details.email = email
                        self?.paymentSpeiDetails = details
                    }
                case .failure(let error):

                    self?.emailSentSuccessfully = false
                    self?.transactionErrorMessage = error.message
                }
            }
        }
    }
  
}
