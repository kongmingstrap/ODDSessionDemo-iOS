//
//  ODDSession.swift
//  ODDSession
//

import Foundation
import MobileCoreServices

func __ODDQueryPair(key: String, value: String) -> String {
    let queryPair = key + "=" + value
    return queryPair
}

func __ODDRequestURL(URL: NSURL, parameters: Dictionary<String, AnyObject>?) -> NSURL {
    var pairs = [String]()
    if let param = parameters {
        for key in param {
            var value: AnyObject? = key.1
            if value is String == false {
                if value is NSNumber == true {
                    value = (value as NSNumber).description
                } else {
                    continue
                }
            }
            let pairValue: String = value as String
            pairs.append(__ODDQueryPair(key.0, pairValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!))
        }
    }
    if pairs.count > 0 {
        let parameterString = "?" + "&".join(pairs)
        return NSURL(string: parameterString, relativeToURL: URL)!
    } else {
        return NSURL(string: "", relativeToURL: URL)!
    }
}

func __ODDMultipartBody(boundary: String, parameters: Dictionary<String, AnyObject>) -> NSData {
    var body = NSMutableData()
    var datas = [String:NSData]()
    let dashBoundary = "--" + boundary
    let dashBoundaryData = dashBoundary.dataUsingEncoding(NSUTF8StringEncoding)!
    let crlfData = NSData(bytes: "\r\n", length: 2)
    for key in parameters.keys {
        var value: AnyObject? = parameters[key]
        if value is String == false {
            if value is NSNumber == true {
                value = (value as NSNumber).description
            } else {
                if value is NSData == true {
                    datas[key] = (value as NSData)
                }
                continue
            }
        }
        //let valueValue: String = value as String
        // dash-boundary CRLF
        body.appendData(dashBoundaryData)
        body.appendData(crlfData)
        // Content-Disposition header CRLF
        let header = "Content-Disposition: form-data; name=\"" + key + "\""
        body.appendData(header.dataUsingEncoding(NSUTF8StringEncoding)!)
        body.appendData(crlfData)
        // empty line
        body.appendData(crlfData)
        // content
        let valueData: NSData = (value as String).dataUsingEncoding(NSUTF8StringEncoding)!
        body.appendData(valueData)
        // CRLF
        body.appendData(crlfData)
    }
    for key in datas.keys {
        // dash-boundary CRLF
        body.appendData(dashBoundaryData)
        body.appendData(crlfData)
        // Content-Disposition header CRLF
        var header: String = "Content-Disposition: form-data; name=\"" + key.stringByDeletingPathExtension + "\"; filename=\"" + key + "\""
        body.appendData(header.dataUsingEncoding(NSUTF8StringEncoding)!)
        body.appendData(crlfData)
        // Content-Type header CRLF
        
        // TODO
        
        body.appendData(crlfData)
        // Content-Transfer-Encoding header CRLF
        header = "Content-Transfer-Encoding: binary"
        body.appendData(header.dataUsingEncoding(NSUTF8StringEncoding)!)
        body.appendData(crlfData)
        // empty line
        body.appendData(crlfData)
        // content
        body.appendData(datas[key]!)
        // CRLF
        body.appendData(crlfData)
    }
    // dash-boundary "--" CRLF
    body.appendData(dashBoundaryData)
    body.appendBytes("--", length: 2)
    body.appendData(crlfData)
    return body
}

class ODDSession: NSObject, NSURLSessionDelegate {
    
    lazy var session: NSURLSession = {
        NSURLSession(configuration: NSURLSessionConfiguration.ephemeralSessionConfiguration(), delegate: self, delegateQueue: nil)
    }()
    var requestURL: NSURL?
    var queue: NSOperationQueue?
    var allowsSelfSignedCertificates: Bool = false
    
    func hasTasksWithCompletionHandler(completionHandler: ((hasTasks: Bool!) -> Void)?) {
        self.session.getTasksWithCompletionHandler { (dataTasks: [AnyObject]!, uploadTasks: [AnyObject]!, downloadTasks: [AnyObject]!) -> Void in
            if let handler = completionHandler {
                let hasTask = ((dataTasks.count > 0) || (uploadTasks.count > 0) || (downloadTasks.count > 0))
                if let queue = self.queue {
                    queue.addOperationWithBlock({ () -> Void in
                        handler(hasTasks: hasTask)
                    })
                } else {
                    handler(hasTasks: hasTask)
                }
            } else {
                // do nothing
            }
        }
    }
    
    func cancelAllTasksWithCompletionHandler(completionHandler: ((Void) -> Void)?) {
        self.session.getTasksWithCompletionHandler { (dataTasks: [AnyObject]!, uploadTasks: [AnyObject]!, downloadTasks: [AnyObject]!) -> Void in
            var datas = dataTasks as Array

            // TODO
            
            if let handler = completionHandler {
                if let queue = self.queue {
                    queue.addOperationWithBlock({ () -> Void in
                        handler()
                    })
                } else {
                    handler()
                }
            } else {
                // do nothing
            }
        }
    }
    
    func getTaskWithAdditionalHeaders(headers: Dictionary<String, String>?, parameters: Dictionary<String, AnyObject>?, completionHandler: ((data: NSData?, response: NSURLResponse?, error: NSError?) -> Void)?) -> ODDSessionTask {
        assert(self.requestURL != nil, "*** self.requestURL is nil")
        let url = __ODDRequestURL(self.requestURL!, parameters)
        let URLRequest = NSMutableURLRequest(URL: url)
        URLRequest.HTTPMethod = "GET"
        if let h = headers {
            URLRequest.allHTTPHeaderFields = NSMutableDictionary(dictionary: h)
        } else {
            // do nothing
        }
        let task = self.session.dataTaskWithRequest(URLRequest, completionHandler: {
            (data, response, error) in
            if let handler = completionHandler {
                if let queue = self.queue {
                    queue.addOperationWithBlock({
                        handler(data: data, response: response, error: error)
                    })
                } else {
                    handler(data: data, response: response, error: error)
                }
            } else {
                // do nothing
            }
        })
        let sessionTask = ODDSessionTask(task: task)
        return sessionTask
    }
    
    // MARK: - NSURLSessionDelegate
    
    func URLSession(session: NSURLSession, didReceiveChallenge challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential!) -> Void) {
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            if self.allowsSelfSignedCertificates == true {
                let credential = NSURLCredential(trust: challenge.protectionSpace.serverTrust)
                completionHandler(.UseCredential, credential)
            } else {
                completionHandler(.PerformDefaultHandling, nil)
            }
        } else {
            completionHandler(.PerformDefaultHandling, nil)
        }
    }

}

class ODDSessionTask: NSObject {
    
    var task: NSURLSessionDataTask
    
    init(task: NSURLSessionDataTask) {
        self.task = task
    }
    
    func cancel() {
        self.task.cancel()
    }
    
    func resume() {
        self.task.resume()
    }
}