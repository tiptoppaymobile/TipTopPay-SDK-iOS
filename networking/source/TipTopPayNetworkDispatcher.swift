//
//  TipTopPayURLSessionNetworkDispatcher.swift
//  TipTopPay
//
//  Created by TipTopPay on 01.07.2021.
//

public protocol TipTopPayNetworkDispatcher {
    func dispatch(request: TipTopPayRequest,
                  onSuccess: @escaping (Data) -> Void,
                  onError: @escaping (Error) -> Void,
                  onRedirect: ((URLRequest) -> Bool)?)
}

public class TipTopPayURLSessionNetworkDispatcher: NSObject, TipTopPayNetworkDispatcher {
    private lazy var session = URLSession(configuration: .default, delegate: self, delegateQueue: .main)
    
    public static let instance = TipTopPayURLSessionNetworkDispatcher()
    
    private var onRedirect: ((URLRequest) -> Bool)?
    
    public func dispatch(request: TipTopPayRequest,
                         onSuccess: @escaping (Data) -> Void,
                         onError: @escaping (Error) -> Void,
                         onRedirect: ((URLRequest) -> Bool)? = nil) {
        self.onRedirect = onRedirect
        
        guard let url = URL(string: request.path) else {
            onError(TipTopPayConnectionError.invalidURL)
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue
        
        
        do {
            if !request.params.isEmpty {
                urlRequest.httpBody = try JSONSerialization.data(withJSONObject: request.params, options: [])
            }
        } catch let error {
            onError(error)
            return
        }
        
        if let data = urlRequest.httpBody {
            print(url.absoluteString)
            print(String(data: data, encoding: .utf8)!)
        }
        
        var headers = request.headers
        headers["Content-Type"] = "application/json"
        headers["User-Agent"] = "iOS SDK 1.5.0"
        urlRequest.allHTTPHeaderFields = headers
                
        session.dataTask(with: urlRequest) { (data, response, error) in
            if let error = error {
                onError(error)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode != 200 {
                    onError(TipTopPayError(message: "\(httpResponse.statusCode)"))
                    return
                }
            }
            
            guard let data = data else {
                onError(TipTopPayConnectionError.noData)
                return
            }
            
            onSuccess(data)
        }.resume()
    }
}

extension TipTopPayURLSessionNetworkDispatcher: URLSessionTaskDelegate {
    public func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        if let _ = onRedirect?(request) {
            completionHandler(request)
        } else {
            completionHandler(nil)
        }
    }
}
