//
//  ServiceManager.swift
//  BudChallenge
//
//  Created by Fong Bao on 01/08/2018.
//  Copyright © 2018 Duncan. All rights reserved.
//

import UIKit

enum ServiceResult {
    case success
    case failure
}

class ServiceManager: ServiceManagerProtocol {
    
    typealias DataRaw = (Data?, URLResponse?, Error?) -> Void
    
    static func URLEncoded(stringURL: String) -> URL? {
        return URL(string: stringURL.urlEncode() ?? "")
    }
    
    func fetchTransactions(urlString: String, completion: @escaping (APIData?, ServiceResult) -> Void) {
        
        guard let url = ServiceManager.URLEncoded(stringURL:urlString) else {
            print("URLEncoding error")
            completion(nil, .failure)
            return
        }
        
        print("*** url is... \(url)")
        
        fetchLatestTransactions(url: url, completion: { data, response, error in
            guard error == nil, let data = data else {
                print("fetchForecast error")
                completion(nil, .failure)
                return
            }
            guard let result = try? JSONDecoder().decode(APIData.self, from: data) else {
                print("fetchForecast decoder error")
                completion(nil, .failure)
                return
            }
            completion(result, .success)
        })
    }
    
    private func fetchLatestTransactions(url: URL, completion: @escaping DataRaw) {
        let sessionConfiguration = URLSessionConfiguration.default
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let urlSession = URLSession(configuration:sessionConfiguration, delegate: nil, delegateQueue: nil)
        
        let sessionTask = urlSession.dataTask(with: request) { (data, response, error) in
            completion(data, response, error)
        }
        sessionTask.resume()
    }
    
    
    static func fetchImageFor(icon: String, completion: @escaping (IconImage?) -> Void) {
        guard let url = ServiceManager.URLEncoded(stringURL: icon) else {
            print("URLEncoding icon error")
            DispatchQueue.main.async {
            completion(nil)
            }
            return
        }
        getImagefrom(url: url, completion: { data, response, error in
            guard error == nil, let data = data else {
                print("fetch icon error")
                DispatchQueue.main.async {
                completion(nil)
                }
                return
            }
            if let image = UIImage(data: data) {
                //completion(image)
                DispatchQueue.main.async {
                completion(IconImage(image: image, imagePath: icon))
                }
            } else {
                DispatchQueue.main.async {
                completion(nil)
                }
            }
        })
    }
    
    private static func getImagefrom(url: URL, completion: @escaping DataRaw) {
        let sessionConfiguration = URLSessionConfiguration.default
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let urlSession = URLSession(configuration: sessionConfiguration, delegate: nil, delegateQueue: nil)
        let sessionTask = urlSession.dataTask(with: request) {
            (data, response, error) in
            completion(data, response, error)
        }
        sessionTask.resume()
    }
    
    
    
    
    
}
