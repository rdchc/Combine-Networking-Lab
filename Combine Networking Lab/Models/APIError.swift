//
//  APIError.swift
//  Combine Networking Lab
//
//  Created by CCH on 15/6/2021.
//

import Foundation

enum APIError: LocalizedError {
  case network(URLError)
  case parsing(DecodingError)
  case other(Swift.Error)
  
  var errorDescription: String? {
    switch self {
    case .network:
      return "Network error occurred."
    case .parsing:
      return "Unable to determine meals."
    case .other:
      return "Error occurred, please try again."
    }
  }
  
  var failureReason: String? {
    switch self {
    case let .network(urlError):
      return urlError.localizedDescription
    case let .parsing(decodingError):
      return decodingError.localizedDescription
    case let .other(error):
      return error.localizedDescription
    }
  }
}
