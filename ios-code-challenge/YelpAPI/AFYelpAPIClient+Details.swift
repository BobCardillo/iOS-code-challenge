//
//  AFYelpAPIClient+Details.swift
//  ios-code-challenge
//
//  Created by Ryan Novak on 2019-10-12.
//  Copyright © 2019 Dustin Lange. All rights reserved.
//

import Foundation

typealias YLPDetailsCompletionHandler = (YLPBusiness?, Error?) -> ()

extension AFYelpAPIClient {
    func getBusiness(id: String, completionHandler: @escaping YLPDetailsCompletionHandler) {
        self.get("businesses/\(id)", parameters: nil, progress: nil, success: {
            (task: URLSessionDataTask, response: Any) in
            if let response = response as? Dictionary<String, Any> {
                completionHandler(YLPBusiness(attributes: response), nil)
            }
        }, failure: {
            (task: URLSessionDataTask?, error: Error) in
            completionHandler(nil, error)
        })
    }
}
