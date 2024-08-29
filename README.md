## TipTopPay SDK for iOS 

TipTopPay SDK позволяет интегрировать прием платежей в мобильные приложения для платформы iOS.

### Требования
Для работы TipTopPay SDK необходим iOS версии 13.0 и выше.

### Подключение
Для подключения SDK мы рекомендуем использовать CocoaPods. Добавьте в файл Podfile зависимости:

```
pod 'TipTopPay', :git =>  "https://gitlab.com/tiptoppay/mobile/tiptoppay-sdk-ios", :branch => "master"
pod 'TipTopPayNetworking', :git =>  "https://gitlab.com/tiptoppay/mobile/tiptoppay-sdk-ios", :branch => "master"
```

### Структура проекта:

* **demo** - Пример реализации приложения с использованием SDK
* **sdk** - Исходный код SDK

## Инициализация TipTopPay

В `AppDelegate.swift` вашего проекта добавьте нотификацию о событиях жизненного цикла приложения:

```swift
func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
    return true
}

func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    return true
}
```

### Использование платежной формы TipTopPay:

1. Cоздайте объект TipTopPayDataPayer и проинициализируйте его, затем создайте объект PaymentData передайте в него объект TipTopPayDataPayer, сумму платежа, валюту и дополнительные данные. Если хотите иметь возможность оплаты с помощью Apple Pay, передайте также Apple pay merchant id.

```
// Доп. поле, куда передается информация о плательщике. Используйте следующие параметры: FirstName, LastName, MiddleName, Birth, Street, Address, City, Country, Phone, Postcode
let payer = PaymentDataPayer(firstName: "", lastName: "", middleName: "", birth: "1955-02-22", address: "home 6", street: "Baker street", city: "London", country: "KZT", phone: "39991234567", postcode: "123456")
    
// Указывайте дополнительные данные если это необходимо
let jsonData: [String: Any] = ["age":27, "name":"Alex", "phone":"+39998881122"] // Любые другие данные, которые будут связаны с транзакцией, в том числе инструкции для создания подписки или формирования онлайн-чека должны обёртываться в объект TipTopPay. Мы зарезервировали названия следующих параметров и отображаем их содержимое в реестре операций, выгружаемом в Личном Кабинете: name, firstName, middleName, lastName, nick, phone, address, comment, birthDate.

let paymentData = TipTopPayData() 
    .setAmount(String(totalAmount)) // Cумма платежа в валюте, максимальное количество не нулевых знаков после запятой: 2
    .setCurrency(.ruble) // Валюта
    .setApplePayMerchantId("") // Apple pay merchant id (Необходимо получить у Apple)
    .setDescription("Корзина цветов") // Описание оплаты в свободной форме
    .setAccountId("111") // Обязательный идентификатор пользователя для создания подписки и получения токена
    .setIpAddress("98.21.123.32") // IP-адрес плательщика
    .setInvoiceId("123") // Номер счета или заказа
    .setEmail("test@tiptoppay.inc") // E-mail плательщика, на который будет отправлена квитанция об оплате
    .setPayer(payer) // Информация о плательщике
    .setJsonData(jsonData) // Любые другие данные, которые будут связаны с транзакцией                    
```

2. Создайте объект TipTopPayConfiguration, передайте в него объект PaymentData и ваш **Public_id** из [личного кабинета TipTopPay](https://merchant.tiptoppay.kz/). Реализуйте протокол TipTopPayDelegate, чтобы узнать о завершении платежа

```
let configuration = TipTopPayConfiguration.init(
    publicId: "", // Ваш Public_id из личного кабинета
    paymentData: paymentData, // Информация о платеже
    delegate: self, // Вывод информации о завершении платежа
    uiDelegate: self, // Вывод информации о UI 
    scanner: nil, // Сканер банковских карт
    requireEmail: true, // Обязательный email, (по умолчанию false)
    useDualMessagePayment: true, // Использовать двухстадийную схему проведения платежа, (по умолчанию используется одностадийная схема)
    disableApplePay: false, // Выключить Apple Pay, (по умолчанию Apple Pay включен)
```

3. Вызовите форму оплаты внутри своего контроллера

```
PaymentForm.present(with: configuration, from: self)
```

4. Сканер карт

Вы можете подключить любой сканер карт. Для этого нужно реализовать протокол PaymentCardScanner и передать объект, реализующий протокол, при создании PaymentConfiguration. Если протокол не будет реализован, то кнопка сканирования не будет показана

Пример со сканером [CardIO](https://github.com/card-io/card.io-iOS-SDK)

* Создайте контроллер со сканером и верните его в функции протокола PaymentCardScanner
```
extension CartViewController: PaymentCardScanner {
    func startScanner(completion: @escaping (String?, UInt?, UInt?, String?) -> Void) -> UIViewController? {
        self.scannerCompletion = completion
        
        let scanController = CardIOPaymentViewController.init(paymentDelegate: self)
        return scanController
    }
}
```
* После завершения сканирования вызовите замыкание и передайте данные карты
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

### История обновлений:

#### 1.0.4
* Добавлено сохранение карты

#### 1.0.3
* Добавлен Privacy Manifest

#### 1.0.2
* Улучшена стабильность

#### 1.0.1
* Добавлена расшифрока некоторых причин отказа в проведении платежа

#### 1.0.0
* Опубликована первая версия SDK

### Поддержка

По возникающим вопросам технического характера обращайтесь на support-kz@tiptoppay.inc
