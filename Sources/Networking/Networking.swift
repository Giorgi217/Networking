// The Swift Programming Language
// https://docs.swift.org/swift-book


import Foundation

public enum NetworkError: Error {
    case badURL
    case requestFailed
    case decodingError
    case unknown
}

public final class NetworkManager {
    public  let shared = NetworkManager()
    
    private init() {}
    
    public func request<T: Decodable>(
        urlString: String,
        method: String = "GET",
        parameters: [String: Any]? = nil,
        headers: [String: String]? = nil,
        completion: @escaping @Sendable (Result<T, NetworkError>) -> Void
    ) {
        guard let url = URL(string: urlString) else {
            completion(.failure(.badURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        
        if let headers = headers {
            for (key, value) in headers {
                request.addValue(value, forHTTPHeaderField: key)
            }
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.requestFailed))
                print("Request failed with error: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                completion(.failure(.unknown))
                return
            }

            do {
                let decodedResponse = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decodedResponse))
            } catch {
                completion(.failure(.decodingError))
            }
        }
        task.resume()
    }
}
