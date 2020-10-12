//
//  RequestHandler.swift
//  SwiftyPlate
//
//  Created by AKM Ahsanuzzaman on 12/10/20.
//  Copyright © 2020 6sense Technologies. All rights reserved.
//

import Foundation
import Alamofire

class RequestHandler: RequestInterceptor {
    
    static let alamofireManager: Session = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 40
        configuration.timeoutIntervalForResource = 40
        return Session(configuration: configuration)
    }()
    
    var adaptedCount = 0
    var retryCount = 0
    var retryErrors: [Error] = []
    
    var shouldApplyAuthorizationHeader = false
    var throwsErrorOnFirstAdapt = false
    var throwsErrorOnSecondAdapt = false
    var throwsErrorOnRetry = false
    var shouldRetry = true
    var isRefreshing = false
    var retryDelay: TimeInterval?
    
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        
        let result: Result<URLRequest, Error> = Result<URLRequest, Error> {
            if throwsErrorOnFirstAdapt {
                throwsErrorOnFirstAdapt = false
                throw AFError.invalidURL(url: "")
            }
            
            if throwsErrorOnSecondAdapt && adaptedCount == 1 {
                throwsErrorOnSecondAdapt = false
                throw AFError.invalidURL(url: "")
            }
            
            var urlRequest = urlRequest
            
            adaptedCount += 1
            
            // Implement Access Token Logic here
//            if let token = Token().get() {
//                urlRequest.headers.update(.authorization(bearerToken: token.accessToken))
//            }
            
            return urlRequest
        }
        
        completion(result)
    }
    
    
    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        if throwsErrorOnRetry {
            let error = AFError.invalidURL(url: "")
            completion(.doNotRetryWithError(error))
            return
        }

        if let response = request.task?.response as? HTTPURLResponse, response.statusCode == 401 {
            if let url = request.firstRequest?.url!.absoluteString {
                // Implement Refresh Token Logic here
//                if url == Urls.Authenticate {
//                    completion(.doNotRetry)
//                } else {
//                    // Token Refresh
//                    completion(.doNotRetry)
//                }
            } else {
                completion(.doNotRetry)
            }

        } else {
            guard shouldRetry else { completion(.doNotRetry); return }

            retryCount += 1
            retryErrors.append(error)

            if retryCount < 2 {
                if let retryDelay = retryDelay {
                    completion(.retryWithDelay(retryDelay))
                } else {
                    completion(.retry)
                }
            } else {
                completion(.doNotRetry)
            }
        }
    }
}

extension RequestHandler {
    func execute<T: Codable, E: Any>(endpoint: Endpoint, completion: ((T?, E?) -> Void)?) {
        
        let session = RequestHandler.alamofireManager
        session.request(endpoint.path, method: endpoint.method, parameters: endpoint.params,
                        encoding: endpoint.encoding, headers: nil,
                        interceptor: self).validate().response { (response) in
                            if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                                print("Data: \(utf8Text)")
                            }
                            switch response.result {
                            case .success(let data):
                                do {
                                    let result = try JSONDecoder().decode(T.self, from: response.data!)
                                    completion?(result, nil)
                                } catch {
                                    print(error)
                                    completion?(nil, error as? E)
                                }
                            case .failure(let error):
                                print(error)
                                completion?(nil, error as? E)
                            }
        }
    }
}
