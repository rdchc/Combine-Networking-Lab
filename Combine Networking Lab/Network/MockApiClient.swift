//
//  MockApiClient.swift
//  Combine Networking Lab
//
//  Created by CCH on 1/6/2021.
//

import Foundation
import Combine

class MockApiClient {
  enum Error: Swift.Error {
    case mockError
  }
  
  let error: Error?
  private let delay: TimeInterval = 2
  
  init(error: Error?) {
    self.error = error
  }
  
  func fetch() -> AnyPublisher<String?, MockApiClient.Error> {
    Future<String?, MockApiClient.Error> { [weak self] resolve in
      if let error = self?.error {
        resolve(.failure(error))
      } else {
        resolve(.success("Success Result"))
      }
    }
    .delay(for: .seconds(delay), scheduler: RunLoop.current)
    .eraseToAnyPublisher()
  }
}
