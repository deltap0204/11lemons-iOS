//
//  LemonApiProvider.swift
//  lemonapp
//
//  Copyright © 2015 11lemons. All rights reserved.
//

import Foundation
import Moya
import Bond
import SwiftyJSON
import ReactiveKit

/*
let lemonApiEndpointClosure = { (target: LemonAPI) -> Endpoint in
    let url = URL(target: target).absoluteString
    return Endpoint(url: url, sampleResponseClosure: {.networkResponse(200, target.sampleData)}, method: target.method, task: target.task, httpHeaderFields: target.headers)
}
 */

//TODO delete if is not necessary anymore
/*
private func LemonApiEndpointMapping(_ target: LemonAPI) -> Endpoint {
    let url = target.baseURL.appendingPathComponent(target.path)
    switch target {
    case .login(let email, let password):
        let headers = [
            _ = LemonAPI.USER_ID_HEADER     : email,
            _ = LemonAPI.USER_PASS_HEADER   : password
        ]
        
        //TODO migration-check
        
        //Before migration code
        //return Endpoint(URL: url.absoluteString, sampleResponseClosure: {.NetworkResponse(200, target.sampleData)}, method: target.method, parameters: target.parameters, parameterEncoding: Moya.ParameterEncoding.JSON, httpHeaderFields: headers)
        
        //Possible fix
        return Endpoint(url: url.absoluteString, sampleResponseClosure: {.networkResponse(200, target.sampleData)}, method: target.method, task: .requestParameters(parameters: target.parameters ?? [:], encoding: JSONEncoding.prettyPrinted), httpHeaderFields: headers)
        
    case .startSession(let userId, _, let password):
        let headers = [
            _ = LemonAPI.USER_NAME_HEADER         : "\(userId)",
            _ = LemonAPI.USER_PASSWORD_HEADER     : password,
            _ = LemonAPI.USER_GRANT_TYPE_HEADER   : "password"
        ]
        
        //TODO migration-check
        
        //Before migration code
        //
        //return Endpoint(URL: url.absoluteString, sampleResponseClosure: {.NetworkResponse(200, target.sampleData)}, method: target.method, parameters: target.parameters, parameterEncoding: Moya.ParameterEncoding.URL, httpHeaderFields: headers)
        
        //Possible fix
        return Endpoint(url: url.absoluteString, sampleResponseClosure: {.networkResponse(200, target.sampleData)}, method: target.method, task: .requestParameters(parameters: target.parameters ?? [:], encoding: URLEncoding.default), httpHeaderFields: headers)
        
    case .chagePassword(let password):
        var headers: [String:String]? = nil
        if let oldPassword = _ = LemonAPI.userPassword,
        let accessToken = _ = LemonAPI.accessToken?.value,
        let userId = _ = LemonAPI.userId {
            headers = [
                _ = LemonAPI.USER_ID_HEADER         : "\(userId)",
                _ = LemonAPI.USER_PASS_HEADER       : password,
                _ = LemonAPI.USER_OLD_PASS_HEADER   : oldPassword,
                "Authorization": "Bearer \(accessToken)"
            ]
        }
        //TODO migration-check
        
        //Before migration code
        //
        //return Endpoint(URL: url.absoluteString, sampleResponseClosure: {.NetworkResponse(200, target.sampleData)}, method: target.method, parameters: target.parameters, parameterEncoding: Moya.ParameterEncoding.JSON, httpHeaderFields: headers)
        
        //Possible fix
        return Endpoint(url: url.absoluteString, sampleResponseClosure: {.networkResponse(200, target.sampleData)}, method: target.method, task: .requestParameters(parameters: target.parameters ?? [:], encoding: JSONEncoding.prettyPrinted), httpHeaderFields: headers)
        
    case .restorePassword(let email):
        let headers = [
            _ = LemonAPI.USER_ID_HEADER : email
        ]
        //TODO migration-check
        
        //Before migration code
        //
        //return Endpoint(URL: url.absoluteString, sampleResponseClosure: {.NetworkResponse(200, target.sampleData)}, method: target.method, parameters: target.parameters, parameterEncoding: Moya.ParameterEncoding.JSON, httpHeaderFields: headers)
        
        //Possible fix
        return Endpoint(url: url.absoluteString, sampleResponseClosure: {.networkResponse(200, target.sampleData)}, method: target.method, task: .requestParameters(parameters: target.parameters ?? [:], encoding: JSONEncoding.prettyPrinted), httpHeaderFields: headers)
        
    case .getProfileImage,
        .getCloudClosetImage,
        .getAttributeImage:
        //TODO migration-check
        
        //Before migration code
        //
        //return Endpoint(URL: url.absoluteString, sampleResponseClosure: {.NetworkResponse(200, target.sampleData)}, method: target.method, parameters: target.parameters, parameterEncoding: Moya.ParameterEncoding.JSON, httpHeaderFields: nil)
        
        //Possible fix
        return Endpoint(url: url.absoluteString, sampleResponseClosure: {.networkResponse(200, target.sampleData)}, method: target.method, task: .requestParameters(parameters: target.parameters ?? [:], encoding: JSONEncoding.prettyPrinted), httpHeaderFields: nil)
        
    case .getOrdersUpdates:
        var headers: [String:String]? = nil
        if let accessToken = _ = LemonAPI.accessToken?.value,
            let userId = _ = LemonAPI.userId {
                headers = [
                    "Authorization": "Bearer \(accessToken)",
                    _ = LemonAPI.USER_ID_HEADER: "\(userId)"
                ]
                
        }
        //TODO migration-check
        
        //Before migration code
        //
        /*return Endpoint(URL: url.absoluteString, sampleResponseClosure: {.NetworkResponse(200, target.sampleData)}, method: target.method, parameters: target.parameters, parameterEncoding: Moya.ParameterEncoding.Custom({ (requestConverible, parameters) -> (NSMutableURLRequest, NSError?) in
            let request = requestConverible.URLRequest
            request.HTTPBody = parameters?.map { return $0.1 }.first?.dataUsingEncoding(NSUTF8StringEncoding)
            return (request, nil)
        }), httpHeaderFields: headers)*/
        
        //Possible fix
        //TODO re-check parameter encoding
        return Endpoint(url: url.absoluteString, sampleResponseClosure: {.networkResponse(200, target.sampleData)}, method: target.method, task: .requestParameters(parameters: target.parameters ?? [:], encoding: JSONEncoding.prettyPrinted), httpHeaderFields: headers)
        
    case .checkEmail,
    .checkPhone:
        var headers: [String:String]? = nil
        if let accessToken = _ = LemonAPI.accessToken?.value,
            let userId = _ = LemonAPI.userId {
                headers = [
                    "Authorization": "Bearer \(accessToken)",
                    "Content-Type":  "application/json;charset=UTF-8",
                    _ = LemonAPI.USER_ID_HEADER: "\(userId)"
                ]
                
        }
        //TODO migration-check
        
        //Before migration code
        //
        /*return Endpoint(URL: url.absoluteString, sampleResponseClosure: {.NetworkResponse(200, target.sampleData)}, method: target.method, parameters: target.parameters, parameterEncoding: Moya.ParameterEncoding.Custom({ (requestConverible, parameters) -> (NSMutableURLRequest, NSError?) in
            let request = requestConverible.URLRequest
            if let param = parameters?.map({ return $0.1 }).first {
                request.HTTPBody = "\"\(param)\"".dataUsingEncoding(NSUTF8StringEncoding)
            }
            request.setValue("application/json;charset=UTF-8", forHTTPHeaderField: "Content-Type")
            return (request, nil)
        }), httpHeaderFields: headers)
 */
        
        //Possible fix
        //TODO re-check parameter encoding
        return Endpoint(url: url.absoluteString, sampleResponseClosure: {.networkResponse(200, target.sampleData)}, method: target.method, task: .requestParameters(parameters: target.parameters ?? [:], encoding: JSONEncoding.prettyPrinted), httpHeaderFields: headers)
        
    case .getOrderImage:
        //TODO migration-check
        
        //Before migration code
        //
        //return Endpoint(URL: target.baseURL.absoluteString, sampleResponseClosure: {.NetworkResponse(200, target.sampleData)}, method: target.method, parameters: target.parameters, parameterEncoding: Moya.ParameterEncoding.JSON, httpHeaderFields: nil)
        
        //Possible fix
        return Endpoint(url: url.absoluteString, sampleResponseClosure: {.networkResponse(200, target.sampleData)}, method: target.method, task: .requestParameters(parameters: target.parameters ?? [:], encoding: JSONEncoding.prettyPrinted), httpHeaderFields: nil)
        
    case .getGarmentByBarcode, .getOrderDetails, .getAllOrders:
        var headers: [String:String]? = nil
        if let accessToken = _ = LemonAPI.accessToken?.value,
            let userId = _ = LemonAPI.userId {
            headers = [
                "Authorization": "Bearer \(accessToken)",
                _ = LemonAPI.USER_ID_HEADER: "\(userId)"
            ]
        }
        //TODO migration-check
        
        //Before migration code
        //
        //return Endpoint(URL: url.absoluteString, sampleResponseClosure: {.NetworkResponse(200, target.sampleData)}, method: target.method, parameters: target.parameters, parameterEncoding: Moya.ParameterEncoding.URL, httpHeaderFields: headers)
        
        //Possible fix
        return Endpoint(url: url.absoluteString, sampleResponseClosure: {.networkResponse(200, target.sampleData)}, method: target.method, task: .requestParameters(parameters: target.parameters ?? [:], encoding: URLEncoding.default), httpHeaderFields: headers)
        
    default:
        var headers: [String:String]? = nil
        if let accessToken = _ = LemonAPI.accessToken?.value,
            let userId = _ = LemonAPI.userId {
                headers = [
                    "Authorization": "Bearer \(accessToken)",
                    _ = LemonAPI.USER_ID_HEADER: "\(userId)"
                ]
        }
        
        //TODO migration-check
        
        //Before migration code
        //
        //return Endpoint(URL: url.absoluteString, sampleResponseClosure: {.NetworkResponse(200, target.sampleData)}, method: target.method, parameters: target.parameters, parameterEncoding: Moya.ParameterEncoding.JSON, httpHeaderFields: headers)
        
        //Possible fix
        return Endpoint(url: url.absoluteString, sampleResponseClosure: {.networkResponse(200, target.sampleData)}, method: target.method, task: .requestParameters(parameters: target.parameters ?? [:], encoding: JSONEncoding.prettyPrinted), httpHeaderFields: headers)
        
    }
}
 */

typealias UserResolver = () throws -> User
typealias StringResolver = () -> String
typealias GenericObjectResolver<T> = () -> T
//typealias EventResolver<T> = (Event<()-> T, NSError>)
typealias EventResolver<T> = () throws -> T
//typealias ImageResolver = (Event<UIImage?, NSError>)
typealias ImageResolver = UIImage?

typealias UserSignal = Signal<(UserResolver), NSError>
typealias StringSignal = Signal<(StringResolver), NSError>
typealias GenericObjectSignal<T> = Signal<(GenericObjectResolver<T>), NSError>

extension LemonAPI {
    
    static let USER_ID_HEADER           = "x-usr-id"
    static let USER_PASS_HEADER         = "x-pass-txt"
    static let USER_OLD_PASS_HEADER     = "x-pass-old"
    static let USER_PASSWORD_HEADER     = "password"
    static let USER_NAME_HEADER         = "username"
    static let USER_GRANT_TYPE_HEADER   = "grant_type"
    
    static var accessToken: AccessToken? {
        didSet {
            accessToken?.save()
        }
    }
    
    static var userId: Int? {
        
        didSet {
            if let userId = userId {
                UserDefaults.standard.set(userId, forKey: LemonAPI.USER_ID_HEADER)
                UserDefaults.standard.synchronize()
            }
        }
    }
    static var userPassword: String? {
        didSet {
            if let password = userPassword {
                UserDefaults.standard.set(password, forKey: LemonAPI.USER_PASSWORD_HEADER)
                UserDefaults.standard.synchronize()
            }
        }
    }
    
    static func restore() {
        self.accessToken = AccessToken.restore()
        self.userPassword = UserDefaults.standard.object(forKey: LemonAPI.USER_PASSWORD_HEADER) as? String
        self.userId = UserDefaults.standard.object(forKey: LemonAPI.USER_ID_HEADER) as? Int
    }
    
    static func clear() {
        userId = nil
        userPassword = nil
        UserDefaults.standard.set(nil, forKey: LemonAPI.USER_PASSWORD_HEADER)
        UserDefaults.standard.set(nil, forKey: LemonAPI.USER_ID_HEADER)
        UserDefaults.standard.synchronize()
        AccessToken.clear()
        accessToken = nil
    }
    
    
    //TODO migration-check
    
    //Before migration code
    //fileprivate static var provider = MoyaProvider<LemonAPI>(endpointClosure: LemonApiEndpointMapping)
    
    //Possible fix
    fileprivate static var provider = MoyaProvider<LemonAPI>()
    
    
    func request(_ completion: @escaping Moya.Completion) -> Cancellable {
        //TODO migration-check
        
//        if let parts = parts {
//            return _ = LemonAPI.provider.request(self, parts: parts, completion: completion)
//        } else {
        
            print("REQUEST URL: ")
            print(self.path)
            return LemonAPI.provider.request(self, completion: completion)
//        }
    }
    
    func request<T: JSONDecodable>(_ queue: DispatchQueue = .main) -> Signal<(() throws -> [T]), NSError> {
        return Signal { observer in
            let request = self.request({ (result) in
                switch result {
                case .success(let response):
                    do {
                        
                        if let requestUrl = response.request?.url?.absoluteString {
                            //print("Request Url: \n")
                            //print(requestUrl)
                        }
                        
                        //let resultValue = try JSONDecoder().decode([T].self, from: response.data)
                        let resultValue = try [T].decode(JSON(data: response.data))
                        let string1 = String(data: response.data, encoding: String.Encoding.utf8) ?? "Data could not be printed"
                        //print(string1)
                        
//                        observer.next({ resultValue })
//                        observer.completed()
                        observer.completed(with: {resultValue})
                    } catch let error {
                        if let backendError = try? BackendError.decode(JSON(data: response.data)["Error"]) {
                            //observer.failed(backendError as NSError)
                            observer.completed(with: { throw backendError})
                        } else {
                            //observer.failed(error as NSError)
                            observer.completed(with: { throw error})
                        }
                    }
                    
                case .failure(let error):
                    //observer.failed(error as NSError)
                    observer.completed(with: { throw error})
                }
                
            })
            return BlockDisposable {
                request.cancel()
            }
        }
    }
    
    
    func request<T: JSONDecodable>(_ queue: DispatchQueue = .main) -> Signal<(() throws -> T), NSError> {
        return Signal { observer in
            let request = self.request({ (result) in
                switch result {
                case .success(let response):
                    do {
                        
                        if let requestUrl = response.request?.url?.absoluteString {
                            //print("Request Url: \n")
                            //print(requestUrl)
                        }
                        
                        if let jsonBody = response.request?.httpBody {
                            let string0 = String(data: jsonBody, encoding: String.Encoding.utf8) ?? "Data could not be printed"
                            print("Json body: \n")
                            //print(string0)
                        }
                        
                        
                        let string1 = String(data: response.data, encoding: String.Encoding.utf8) ?? "Data could not be printed"
                        //print(string1)
                        
                        //let resultValue = try JSONDecoder().decode(T.self, from: response.data)
                        let resultValue = try T.decode(JSON(data: response.data))
                        
//                        observer.next({ resultValue })
//                        observer.completed()
                        observer.completed(with: {resultValue})
                    } catch let error {
                        if let backendError = try? BackendError.decode(JSON(data: response.data)["Error"]) {
                            //observer.failed(backendError as NSError)
                            observer.completed(with: { throw backendError})
                        } else {
                            //observer.failed(error as NSError)
                            observer.completed(with: { throw error})
                        }
                    }
                    
                case .failure(let error):
                    //observer.failed(error as NSError)
                    observer.completed(with: { throw error})
                }
                
            })
            return BlockDisposable {
                request.cancel()
            }
        }
    }
    
    func request(_ queue: DispatchQueue = .main) -> Signal<(() throws -> ()), NSError> {
        return Signal { observer in
            let request = self.request({ (result) in
                switch result {
                case .success(let response):
                    if let backendError = try? BackendError.decode(JSON(data: response.data)["Error"]) {
                        //observer.failed(backendError as NSError)
                        observer.completed(with: { throw backendError})
                    } else {
//                        observer.next({ })
//                        observer.completed()
                        observer.completed(with: {})
                    }
                    
                case .failure(let error):
                    //observer.failed(error as NSError)
                    observer.completed(with: { throw error})
                }
            })
            return BlockDisposable {
                request.cancel()
            }
        }
    }
    
    func request(_ queue: DispatchQueue = .main) -> Signal<(() throws -> String), NSError> {
        return Signal { observer in
            let request = self.request({ (result) in
                switch result {
                case .success(let response):
                    do {
                        
                        if let requestUrl = response.request?.url?.absoluteString {
                            print("Request Url: \n")
                            print(requestUrl)
                        }
                        
                        if let jsonBody = response.request?.httpBody {
                            let string0 = String(data: jsonBody, encoding: String.Encoding.utf8) ?? "Data could not be printed"
                            print("Json body: \n")
                            //print(string0)
                        }
                        
                        //print("Request Response: \n")
                        let string1 = String(data: response.data, encoding: String.Encoding.utf8) ?? "Data could not be printed"
                        //print(string1)
                        
                        if let backendError = try? BackendError.decode(JSON(data: response.data)["Error"]) {
                            //observer.failed(backendError as NSError)
                            observer.completed(with: { throw backendError})
                        } else {
                            let result = try JSON(data: response.data, options: [JSONSerialization.ReadingOptions.allowFragments]).stringValue
//                            observer.next({ result })
//                            observer.completed()
                            observer.completed(with: {result})
                        }
                    } catch let error {
                        //observer.failed(error as NSError)
                        observer.completed(with: { throw error})
                    }
                    
                case .failure(let error):
                    //observer.failed(error as NSError)
                    observer.completed(with: { throw error})
                }
                
            })
            return BlockDisposable {
                request.cancel()
            }
        }
    }
    
    func request(_ queue: DispatchQueue = .main) -> Signal<UIImage?, NSError> {
        return Signal { observer in
            let request = self.request({ (result) in
                switch result {
                case .success(let response):
                    if let backendError = try? BackendError.decode(JSON(data: response.data)["Error"]) {
                        //observer.failed(backendError as NSError)
                        observer.completed(with: nil)
                    } else {
                        let resultValue = UIImage(data: response.data)
//                        observer.next({ resultValue }())
//                        observer.completed()
                        observer.completed(with: resultValue)
                    }
                case .failure(let error):
                    //observer.failed(error as NSError)
                    observer.completed(with: nil)
                }
                
            })
            return BlockDisposable {
                request.cancel()
            }
        }
    }
    
    //TODO delete if not used
    fileprivate class SerializationTask {
        
        fileprivate let queue: OperationQueue = {
            let operationQueue = OperationQueue()
            operationQueue.maxConcurrentOperationCount = 1
            operationQueue.isSuspended = true
            return operationQueue
        }()
        
        init() {}
        
        init(operation: @escaping () -> ()) {
            addOperation(operation)
        }
        
        func addOperation(_ operation: @escaping () -> ()) {
            queue.addOperation { [weak self] in
                operation()
                DispatchQueue.main.async {
                    self?.queue.isSuspended = self?.queue.operationCount == 0
                }
            }
            queue.isSuspended = false
        }
        
        func cancel() {
            queue.cancelAllOperations()
            queue.isSuspended = false
        }
        
        deinit {
            cancel()
        }
        
    }
    
}
