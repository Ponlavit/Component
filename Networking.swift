
import Foundation
import RxSwift

public protocol PLAPIRequest {
    func makeHTTPRequest(request:URLRequest) -> Observable<Data>
}

public enum PLMethod: String {
    case GET = "GET"
    case POST = "POST"
    case DELETE = "DELETE"
    case PUT = "PUT"
}

public protocol PLRequestAble {
    var method : PLMethod { get }
    var endpoint : String! { get }
    var baseURL : String! { get }
    var headers : [String:String]? { get }
    var parameter : [String:String]? { get }
}

extension PLRequestAble {
    public func getRequest(withBody body:Data? = nil, additionalHeaderFields:[String:String]? = nil, isLog:Bool? = false) -> URLRequest {
        
        var urlString = "\(self.baseURL!)\(self.endpoint!)"

        urlString = String(format: urlString, self.parameter!)
        
        let urlComponent =  URLComponents(string:urlString)
        
        print("➡️➡️➡️ \(urlString)")
        print("    ➡️ \(self.endpoint!)")
        
        var request = URLRequest(url: (urlComponent?.url)!)
        request.httpMethod = self.method.rawValue
        print(" 🎯 \(self.method.rawValue) 🎯 ")
        
        if let headers = self.headers {
            for (key, value) in headers {
                print(" 🔑 \(key) = \(value) 🔑")
                request.addValue(value, forHTTPHeaderField: key)
            }
        }
        if let headers = additionalHeaderFields {
            for (key, value) in headers {
                let keyExists = headers[key] != nil
                if(keyExists) {
                    request.setValue(value, forHTTPHeaderField: key)
                }
                else {
                    request.addValue(value, forHTTPHeaderField: key)
                }
                print(" 🔑 \(key) = \(value) 🔑")
            }
        }
        
        if(self.method == .POST || self.method == .PUT){
            request.httpBody = body
        }
        
        return request
    }
}


