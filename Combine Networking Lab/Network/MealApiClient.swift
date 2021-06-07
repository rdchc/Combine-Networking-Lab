//
//  MealApiClient.swift
//  Combine Networking Lab
//
//  Created by CCH on 7/6/2021.
//

import Foundation
import Combine

class MealApiClient {
  enum Error: Swift.Error {
    case network(URLError)
    case parsing(DecodingError)
    case other(Swift.Error)
  }
  
  let baseUrlString = "https://www.themealdb.com/api/json/v1/1"
  let urlSession = URLSession.shared
  
  func fetchCategories() -> AnyPublisher<[MealCategory], MealApiClient.Error> {
    let url = URL(string: "\(baseUrlString)/categories.php")!
    return urlSession.dataTaskPublisher(for: url)
      .map(\.data)
      .decode(type: MealCategoriesResponse.self, decoder: JSONDecoder())
      .map { $0.categories.map { $0.mealCategory } }
      .mapError { error -> MealApiClient.Error in
        switch error {
        case let urlError as URLError: return .network(urlError)
        case let decodingError as DecodingError: return .parsing(decodingError)
        default: return .other(error)
        }
      }
      .eraseToAnyPublisher()
  }
}

private struct MealCategoriesResponse: Decodable {
  let categories: [MealCategoryResponse]
}

private struct MealCategoryResponse: Decodable {
  let idCategory: String
  let strCategory: String
  let strCategoryThumb: String
  let strCategoryDescription: String
  
  var mealCategory: MealCategory {
    MealCategory(id: idCategory, name: strCategory, imageUrlString: strCategoryThumb, longDescription: strCategoryDescription)
  }
}
