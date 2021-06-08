//
//  FetchStatus.swift
//  Combine Networking Lab
//
//  Created by CCH on 8/6/2021.
//

import Foundation

enum FetchStatus<T: Equatable>: Equatable {
  case fetching
  case fetched(T)
  case error(String?)
  case cancelled
  
  static func == (lhs: FetchStatus<T>, rhs: FetchStatus<T>) -> Bool {
    switch (lhs, rhs) {
    case (.fetching, .fetching):
      return true
    case let (.fetched(lValue), .fetched(rValue)):
      return lValue == rValue
    case let (.error(lError), .error(rError)):
      return lError == rError
    case (.cancelled, .cancelled):
      return true
    default:
      return false
    }
  }
}
