//
//  Combine+Publisher.swift
//  Combine Networking Lab
//
//  Created by CCH on 21/6/2021.
//

import Foundation
import Combine

extension Publisher {
  func observeFetchStatus(with countSubject: CurrentValueSubject<Int, Never>) -> Publishers.HandleEvents<Self> {
    return handleEvents(receiveSubscription: { _ in
      countSubject.value += 1
    }, receiveCompletion: { _ in
      countSubject.value -= 1
    }, receiveCancel: {
      countSubject.value -= 1
    })
  }
  
  func observeFetchStatus<S: Subject>(with booleanSubject: S) -> Publishers.HandleEvents<Self> where S.Output == Bool, S.Failure == Never {
    return handleEvents(receiveSubscription: { _ in
      booleanSubject.send(true)
    }, receiveCompletion: { _ in
      booleanSubject.send(false)
    }, receiveCancel: {
      booleanSubject.send(false)
    })
  }
  
  func observeFetchStatus<S: Subject>(with fetchStatusSubject: S) -> Publishers.HandleEvents<Self> where S.Output == FetchStatus, S.Failure == Never {
    return handleEvents(receiveSubscription: { _ in
      fetchStatusSubject.send(.ongoing)
    }, receiveCompletion: {
      switch $0 {
      case .finished:
        fetchStatusSubject.send(.finished)
      case .failure:
        fetchStatusSubject.send(.ready)
      }
    }, receiveCancel: {
      fetchStatusSubject.send(.ready)
    })
  }
}

extension Publisher {
  func tryDecodeResponse<Item, Coder>(type: Item.Type, decoder: Coder) -> Publishers.Decode<Publishers.TryMap<Self, Data>, Item, Coder> where Item: Decodable, Coder: TopLevelDecoder, Self.Output == (data: Data, response: URLResponse) {
    return self
      .tryMap { output in
        guard let httpResponse = output.response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
          throw URLError(.badServerResponse)
        }
        return output.data
      }
      .decode(type: type, decoder: decoder)
  }
}
