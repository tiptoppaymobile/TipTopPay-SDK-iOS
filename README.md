## TipTopPay SDK for iOS 

TipTopPay SDK allows to integrate payment processing service into an iOS application.

### Requirements
iOS v. 13.0 and younger

### Connection
To connect the SDK, you can use Swift Package Manager or CocoaPods.

* To connect via Swift Package Manager, use the menu File -> Add Package Dependencies, find the SDK using the Package URL - https://github.com/tiptoppaymobile/TipTopPay-SDK-iOS and add the dependency to the project.
* To connect via CocoaPods, add dependencies to the Podfile:

```
pod 'TipTopPay', :git =>  "https://github.com/tiptoppaymobile/TipTopPay-SDK-iOS", :branch => "master"
pod 'TipTopPayNetworking', :git =>  "https://github.com/tiptoppaymobile/TipTopPay-SDK-iOS", :branch => "master"
```

### Project structure

* **demo** - An example app using SDK
* **sdk** - Source code of SDK

## Initialization of TipTopPay 

Add app lifecycle notifications to `AppDelegate.swift` of your project:

```swift
func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
    return true
}

func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    return true
}
```

### Localization

If you need to use localization, add the Localization section in your application target languages (Spanish, English, Russian, Kazakh)

### Payment form usage of TipTopPay SDK:

1. Create an object TipTopPayDataPayer and initialize it, then create an object PaymentData. Send into it an object TipTopPayDataPayer, payment amount, currency and extra data. If you would like to use Apple Pay, also send Apple pay merchant id.

```
// Extra parameter for customer’s data. Use the following parameters: FirstName, LastName, MiddleName, Birth, Street, Address, City, Country, Phone, Postcode
let payer = PaymentDataPayer(firstName: "", lastName: "", middleName: "", birth: "1955-02-22", address: "home 6", street: "Baker street", city: "London", country: "KZT", phone: "39991234567", postcode: "123456")
    
// Indicate additional data if necessary
let jsonData: [String: Any] = ["age":27, "name":"Alex", "phone":"+39998881122"] // Any other data that will be associated with the transaction, including instructions for creating a subscription or generating an online receipt, must be wrapped in a TipTopPay object. We have reserved the names of the following parameters and display their criteria in the transaction register downloaded from the Control Panel: name, firstName, middleName, lastName, nick, phone, address, comment, birthDate.

let paymentData = TipTopPayData() 
    .setAmount(String(totalAmount)) // Payment amount, maximum 2 decimal places 
    .setCurrency(.ruble) // Currency
    .setApplePayMerchantId("") // Apple pay merchant id (Must be obtained from Apple)
    .setDescription("A basket of flowers") // Payment description
    .setAccountId("111") // Mandatory customer’s ID for creating a subscription and getting a token 
    .setIpAddress("98.21.123.32") // customer’s IP address
    .setInvoiceId("123") // Order or invoice number
    .setEmail("test@tiptoppay.inc") // Customer’s e-mail (used for sending payment confirmation)
    .setPayer(payer) // Customer’s information
    .setJsonData(jsonData) // Any other data linked to this payment                    
```

2. Create an object TipTopPayConfiguration, send into it an object PaymentData and your **Public_id** obtained from [TipTopPay Control Panel](https://merchant.tiptoppay.kz/). Implement TipTopPayDelegate protocol, to get payment result

```
let configuration = TipTopPayConfiguration.init(
    region: .MX, // Your region Mexico (MX) or Kazakhstan (KZ)    
    publicId: "", // Your Public ID obtained in the Control Panel
    paymentData: paymentData, // Payment data
    delegate: self, // Displaying payment completion information
    uiDelegate: self, // Displaying UI information
    scanner: nil, // Card scanner
    requireEmail: true, // Usage of email (false – not required, true – required)
    useDualMessagePayment: true, // Usage of two-staged payments (true). By default is using one-staged payments (false)
    disableApplePay: false, // Disable Apple Pay (enabled by default)
```

3. Initiate the payment UI inside your controller 

```
PaymentForm.present(with: configuration, from: self)
```

4. Card scanner

Any card scanner can be connected. To do this, the PaymentCardScanner protocol should be implemented and an object implementing the protocol should be passed when creating the PaymentConfiguration. If the protocol is not implemented, the scanning button will not be displayed

An example using [CardIO](https://github.com/card-io/card.io-iOS-SDK) scanner

* Create a controller with a scanner and return it to the protocol functions PaymentCardScanner
```
extension CartViewController: PaymentCardScanner {
    func startScanner(completion: @escaping (String?, UInt?, UInt?, String?) -> Void) -> UIViewController? {
        self.scannerCompletion = completion
        
        let scanController = CardIOPaymentViewController.init(paymentDelegate: self)
        return scanController
    }
}
```
* After scanning completion initiate locking and send the card data
```
extension CartViewController: CardIOPaymentViewControllerDelegate {
    func userDidCancel(_ paymentViewController: CardIOPaymentViewController!) {
        paymentViewController.dismiss(animated: true, completion: nil)
    }
    
    func userDidProvide(_ cardInfo: CardIOCreditCardInfo!, in paymentViewController: CardIOPaymentViewController!) {
        self.scannerCompletion?(cardInfo.cardNumber, cardInfo.expiryMonth, cardInfo.expiryYear, cardInfo.cvv)
        paymentViewController.dismiss(animated: true, completion: nil)
    }
}
```

### Update history:

#### 1.0.11
* Swift Package Manager added

#### 1.0.10
* Fix bugs

#### 1.0.9
* Stability improved

#### 1.0.8
* Spei payment method

#### 1.0.7
* Cash payment method

#### 1.0.6
* Installments payment method

#### 1.0.5
* Added region

#### 1.0.4
* Added card saving

#### 1.0.3
* Added Privacy Manifest

#### 1.0.2
* Stability improved

#### 1.0.1
* Added explanation of some reasons of payment declines

#### 1.0.0
* Initial version

### Support

Contact soporte@tiptoppay.in (Mexico) or support-kz@tiptoppay.inc (Kazakhstan)

