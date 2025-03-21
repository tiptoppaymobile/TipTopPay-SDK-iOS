
import TipTopPayNetworking
import Combine
import Foundation

public class TipTopPayApi {
    enum Source: String {
        case ttpForm = "TipTopPay SDK iOS (Default form)"
        case ownForm = "TipTopPay SDK iOS (Custom form)"
    }
    
    private let defaultCardHolderName = "TipTopPay SDK"
    private let threeDsSuccessURL = "https://tiptoppay.kz/success"
    private let threeDsFailURL = "https://tiptoppay.kz/fail"
    private let publicId: String
    private let apiUrl: String
    private let source: Source
    
    init(publicId: String, apiUrl: String?, source: Source, region: Region) {
        self.publicId = publicId
        self.source = source
        if (apiUrl.isNilOrEmpty) {
            self.apiUrl = region.getApiUrl()
        } else {
            self.apiUrl = apiUrl ?? ""
        }
    }
    
    public class func getBankInfo(cardNumber: String, completion: ((_ bankInfo: BankInfo?, _ error: TipTopPayError?) -> ())?) {
        let cleanCardNumber = Card.cleanCreditCardNo(cardNumber)
        guard cleanCardNumber.count >= 6 else {
            completion?(nil, TipTopPayError.init(message: "You must specify at least the first 6 digits of the card number"))
            return
        }
        
        let firstSixIndex = cleanCardNumber.index(cleanCardNumber.startIndex, offsetBy: 6)
        let firstSixDigits = String(cleanCardNumber[..<firstSixIndex])
        
        BankInfoRequest(firstSix: firstSixDigits).execute(keyDecodingStrategy: .convertToUpperCamelCase, onSuccess: { response in
            completion?(response.model, nil)
        }, onError: { error in
            if !error.localizedDescription.isEmpty  {
                completion?(nil, TipTopPayError.init(message: error.localizedDescription))
            } else {
                completion?(nil, TipTopPayError.defaultCardError)
            }
        })
    }
    
    public class func getInstallmentsCalculateSumByPeriod(with configuration: TipTopPayConfiguration, completion handler: @escaping (InstallmentConfigurationResponse?) -> Void) {
        
        let publicId = configuration.publicId
        let amount = configuration.paymentData.amount
        
        guard let apiUrl = configuration.apiUrl else { return }
        
        let queryItems = [
            "TerminalPublicId": publicId,
            "Amount" :  amount,
        ] as [String : String?]
        
        let request = InstallmentsRequest(queryItems: queryItems, apiUrl: apiUrl)
        
        request.execute { result in
            handler(result)
        } onError: { error in
            print(error.localizedDescription)
            handler(nil)
        }
        
    }
    
    public class func getBinInfo(cleanCardNumber: String,
                                 with configuration: TipTopPayConfiguration,
                                 completion: @escaping (BankInfo?, Bool?) -> Void) {
        
        var firstSixDigits: String? = nil
        
        if cleanCardNumber.count >= 6 {
            let firstSixIndex = cleanCardNumber.index(cleanCardNumber.startIndex, offsetBy: 6)
            firstSixDigits = String(cleanCardNumber[..<firstSixIndex])
        }
        
        let publicId = configuration.publicId
        
        let queryItems = [
            "Bin": firstSixDigits,
            "Currency": configuration.paymentData.currency,
            "Amount": configuration.paymentData.amount,
            "TerminalPublicId": publicId,
            "IsCheckCard": "true"
        ] as [String: String?]
        
        guard let apiUrl = configuration.apiUrl else { return }
        
        let request = BinInfoRequest(queryItems: queryItems, apiUrl: apiUrl)
        
        request.execute { result in
            completion(result.model, result.success)
        } onError: { error in
            print(error)
            completion(nil, false)
        }
    }
    
    public class func altPayCash(
        with configuration: TipTopPayConfiguration,
        altPayType: String,
        completion handler: @escaping (Result<AltPayCashResponse?, TipTopPayError>) -> Void
    ) {
        let publicId = configuration.publicId
        let amount = configuration.paymentData.amount
        let email = configuration.paymentData.email
        let description = configuration.paymentData.description
        let firstName = configuration.paymentData.payer?.firstName ?? ""
        let lastName = configuration.paymentData.payer?.lastName ?? ""
        let middleName = configuration.paymentData.payer?.middleName ?? ""
        let birth = configuration.paymentData.payer?.birth ?? ""
        let address = configuration.paymentData.payer?.address ?? ""
        let street = configuration.paymentData.payer?.street ?? ""
        let city = configuration.paymentData.payer?.city ?? ""
        let country = configuration.paymentData.payer?.country ?? ""
        let postcode = configuration.paymentData.payer?.postcode ?? ""
        let phone = configuration.paymentData.payer?.phone ?? ""
        let currency = configuration.paymentData.currency
        let accountId = configuration.paymentData.accountId
        let invoiceId = configuration.paymentData.invoiceId
        let sсheme: Scheme = configuration.isUseDualMessagePayment ? .auth : .charge
        let jsonData = configuration.paymentData.getJsonData()
        
        guard let apiUrl = configuration.apiUrl else {
            handler(.failure(.invalidURL(url: nil)))
            return
        }
        
        let payerParams = [
            "FirstName": firstName,
            "LastName": lastName,
            "MiddleName": middleName,
            "Birthday": birth,
            "Address": address,
            "Street": street,
            "City": city,
            "Country": country,
            "Postcode": postcode,
            "Phone": phone,
            "Email": email
        ]
        
        let params: [String : Any?] = [
            "PublicId": publicId,
            "Amount" :  amount,
            "AltPayType": altPayType,
            "Payer": payerParams,
            "Email": email,
            "Description": description,
            "Scenario": 7,
            "Currency": currency,
            "AccountId": accountId,
            "InvoiceId": invoiceId,
            "Scheme": sсheme.rawValue,
            "CultureName": "es-US",
            "JsonData" : jsonData
        ]
        
        let request = AltPayCashRequest(params: params, apiUrl: apiUrl)
        
        request.execute { result in
            if result.success ?? false {
                handler(.success(result))
            } else {
                    let reasonCode = result.model?.reasonCode ?? 5204
                    let errorMessage = ApiError.getFullErrorDescription(code: String(reasonCode))
                    let error = TipTopPayError(message: errorMessage)
                    handler(.failure(error))
            }
        } onError: { error in
            handler(.failure(TipTopPayError(message: error.localizedDescription)))
        }
    }
        
    public class func getWaitStatus(configuration: TipTopPayConfiguration, 
                                    transactionId: Int64,
                                    publicId: String) -> AnyPublisher<TransactionStatusResponse, TipTopPayError> {
        Future { promise in
            let params: [String: Any?] = [
                "TransactionId": transactionId,
                "PublicId": publicId
            ]
            
            guard let apiUrl = configuration.apiUrl else {
                promise(.failure(.invalidURL(url: nil)))
                return
            }
            
            let request = WaitStatusRequest(params: params, apiUrl: apiUrl)
            
            TipTopPayURLSessionNetworkDispatcher.instance.dispatch(
                request: request.data,
                onSuccess: { responseData in
                    do {
                        let jsonDecoder = JSONDecoder()
                        let result = try jsonDecoder.decode(TransactionStatusResponse.self, from: responseData)
                        
                        if result.success ?? false {
                            promise(.success(result))
                        } else {
                            let errorCode = result.model?.statusCode ?? 5204
                            let errorMessage = ApiError.getFullErrorDescription(code: String(errorCode))
                            let error = TipTopPayError(message: errorMessage)
                            promise(.failure(error))
                        }
                    } catch {
                        promise(.failure(TipTopPayError.parseError))
                    }
                },
                onError: { error in
                    promise(.failure(TipTopPayError(message: error.localizedDescription)))
                }
            )
        }
        .eraseToAnyPublisher()
    }
    
    public class func stpSpeiPaymentDetails(
        with configuration: TipTopPayConfiguration,
        email: String,
        transactionId: Int64,
        completion handler: @escaping (Result<StpSpeiPaymentDetailsResponse?, TipTopPayError>) -> Void
    ) {
        let publicId = configuration.publicId
        
        guard let apiUrl = configuration.apiUrl else {
            handler(.failure(.invalidURL(url: nil)))
            return
        }
        
        let params: [String : Any?] = [
            "PublicId": publicId,
            "Email": email,
            "TransactionId": transactionId,
        ]
        
        let request = StpSpeiPaymentDetailsRequest(params: params, apiUrl: apiUrl)
        
        request.execute { result in
            if result.success ?? false {
                handler(.success(result))
            } else {
                let reasonCode = result.success
                let errorMessage = ApiError.getFullErrorDescription(code: String(reasonCode ?? false))
                    let error = TipTopPayError(message: errorMessage)
                    handler(.failure(error))
            }
        } onError: { error in
            handler(.failure(TipTopPayError(message: error.localizedDescription)))
        }
    }

    public func charge(cardCryptogramPacket: String,
                       email: String?,
                       paymentData: TipTopPayData,
                       term: Int?,
                       completion: @escaping TipTopPayRequestCompletion<TransactionResponse>) {
        let parameters = generateParams(cardCryptogramPacket: cardCryptogramPacket,
                                        email: email,
                                        paymentData: paymentData, term: term, installmentData: InstallmentsData(term: term ?? 0))
        ChargeRequest(params: patch(params: parameters), headers: getDefaultHeaders(), apiUrl: apiUrl).execute(keyDecodingStrategy: .convertToUpperCamelCase, onSuccess: { response in
            completion(response, nil)
        }, onError: { error in
            completion(nil, error)
        })
    }
    
    public func auth(cardCryptogramPacket: String,
                     email: String?,
                     paymentData: TipTopPayData,
                     completion: @escaping TipTopPayRequestCompletion<TransactionResponse>) {
        let parameters = generateParams(cardCryptogramPacket: cardCryptogramPacket,
                                        email: email,
                                        paymentData: paymentData, term: nil, installmentData: nil)
        AuthRequest(params: patch(params: parameters), headers: getDefaultHeaders(), apiUrl: apiUrl).execute(keyDecodingStrategy: .convertToUpperCamelCase, onSuccess: {
            response in
            completion(response, nil)
            
        }, onError: { error in
            completion(nil, error)
        })
    }
    
    public func post3ds(transactionId: String, threeDsCallbackId: String, paRes: String, completion: @escaping (_ result: ThreeDsResponse) -> ()) {
        let mdParams = ["TransactionId": transactionId,
                        "ThreeDsCallbackId": threeDsCallbackId,
                        "SuccessUrl": self.threeDsSuccessURL,
                        "FailUrl": self.threeDsFailURL]
        if let mdParamsData = try? JSONSerialization.data(withJSONObject: mdParams, options: .sortedKeys), let mdParamsStr = String.init(data: mdParamsData, encoding: .utf8) {
            let parameters: [String: Any] = [
                "MD" : mdParamsStr,
                "PaRes" : paRes
            ]
            
            PostThreeDsRequest(params: parameters, headers: getDefaultHeaders(), apiUrl: apiUrl).execute(keyDecodingStrategy: .convertToUpperCamelCase, onSuccess: { r in
            }, onError: { error in
            }, onRedirect: { [weak self] request in
                guard let self = self else {
                    return true
                }
                
                
                
                if let url = request.url {
                    let items = url.absoluteString.split(separator: "&").filter { $0.contains("ReasonCode")}
                    var reasonCode: String? = nil
                    if !items.isEmpty, let params = items.first?.split(separator: "="), params.count == 2 {
                        reasonCode = String(params[1]).removingPercentEncoding
                    }
                    
                    if url.absoluteString.starts(with: self.threeDsSuccessURL) {
                        DispatchQueue.main.async {
                            let r = ThreeDsResponse.init(success: true, reasonCode: reasonCode)
                            completion(r)
                        }
                        
                        return false
                    } else if url.absoluteString.starts(with: self.threeDsFailURL) {
                        DispatchQueue.main.async {
                            let r = ThreeDsResponse.init(success: false, reasonCode: reasonCode)
                            completion(r)
                        }
                        
                        return false
                    } else {
                        return true
                    }
                } else {
                    return true
                }
            })
        } else {
            completion(ThreeDsResponse.init(success: false, reasonCode: ""))
        }
    }
    
    private func generateParams(cardCryptogramPacket: String,
                                email: String?,
                                paymentData: TipTopPayData,
                                term: Int?,
                                installmentData: InstallmentsData?) -> [String: Any] {
        
        var parameters: [String: Any] = [
            "Amount" : paymentData.amount, // Сумма платежа (Обязательный)
            "Currency" : paymentData.currency, // Валюта (Обязательный)
            "Name" : paymentData.cardholderName ?? defaultCardHolderName, // Имя держателя карты в латинице (Обязательный для всех платежей кроме Apple Pay и Google Pay)
            "CardCryptogramPacket" : cardCryptogramPacket, // Криптограмма платежных данных (Обязательный)
            "Email" : email ?? "", // E-mail, на который будет отправлена квитанция об оплате
            "InvoiceId" : paymentData.invoiceId ?? "", // Номер счета или заказа в вашей системе (Необязательный)
            "Description" : paymentData.description ?? "", // Описание оплаты в свободной форме (Необязательный)
            "AccountId" : paymentData.accountId ?? "", // Идентификатор пользователя в вашей системе (Необязательный)
            "Payer" : paymentData.payer?.dictionary as Any, // Доп. поле, куда передается информация о плательщике. (Необязательный)
            "scenario" : 7
        ]
        
        if let jsonData = paymentData.getJsonData() {
            parameters["JsonData"] = jsonData // Любые другие данные, которые будут связаны с транзакцией, в том числе инструкции для создания подписки или формирования онлайн-чека (Необязательный)
        }
        
        if let term = term {
            parameters["Term"] = term
        }
        
        if let installmentData = installmentData {
            parameters["InstallmentData"] = ["Term": installmentData.term]
        }
        
        if let saveCard = paymentData.saveCard {
            parameters["SaveCard"] = saveCard
        }
        
        return parameters
    }
    
    private func patch(params: [String: Any]) -> [String: Any] {
        var parameters = params
        parameters["PublicId"] = self.publicId
        return parameters
    }
    
    private func getDefaultHeaders() -> [String: String] {
        var headers = [String: String]()
        headers["MobileSDKSource"] = self.source.rawValue
        return headers
    }
}

public typealias TipTopPayRequestCompletion<T> = (_ response: T?, _ error: Error?) -> Void

private struct TipTopPayCodingKey: CodingKey {
    var stringValue: String
    
    init(stringValue: String) {
        self.stringValue = stringValue
    }
    
    var intValue: Int? {
        return nil
    }
    
    init?(intValue: Int) {
        return nil
    }
}

extension JSONDecoder.KeyDecodingStrategy {
    static var convertToUpperCamelCase: JSONDecoder.KeyDecodingStrategy {
        return .custom({ keys -> CodingKey in
            let lastKey = keys.last!
            if lastKey.intValue != nil {
                return lastKey
            }
            
            let firstLetter = lastKey.stringValue.prefix(1).lowercased()
            let modifiedKey = firstLetter + lastKey.stringValue.dropFirst()
            return TipTopPayCodingKey(stringValue: modifiedKey)
        })
    }
}

enum Scheme: String, Codable {
    case charge = "charge"
    case auth = "auth"
}
