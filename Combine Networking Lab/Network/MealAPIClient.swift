//
//  MealAPIClient.swift
//  Combine Networking Lab
//
//  Created by CCH on 7/6/2021.
//

import Foundation
import Combine

protocol MealAPIClientProtocol {
  func fetchCategories() -> AnyPublisher<[MealCategory], APIError>
  func fetchMeals(category: String) -> AnyPublisher<[Meal], APIError>
}

class MealAPIClient: MealAPIClientProtocol {
  let baseUrlString = "https://www.themealdb.com/api/json/v1/1"
  let urlSession = URLSession.shared
  
  func fetchCategories() -> AnyPublisher<[MealCategory], APIError> {
    let url = URL(string: "\(baseUrlString)/categories.php")!
    return urlSession.dataTaskPublisher(for: url)
      .map(\.data)
      .decode(type: MealCategoriesResponse.self, decoder: JSONDecoder())
      .map { $0.categories.map { $0.toMealCategory() } }
      .mapError { error -> APIError in
        switch error {
        case let urlError as URLError: return .network(urlError)
        case let decodingError as DecodingError: return .parsing(decodingError)
        default: return .other(error)
        }
      }
      .eraseToAnyPublisher()
  }
  
  func fetchMeals(category: String) -> AnyPublisher<[Meal], APIError> {
    let url = URL(string: "\(baseUrlString)/filter.php?c=\(category)")!
    return urlSession.dataTaskPublisher(for: url)
      .map(\.data)
      .decode(type: MealsResponse.self, decoder: JSONDecoder())
      .map { $0.meals.map { $0.toMeal() } }
      .mapError { error -> APIError in // TODO: Make common `.mapError` specialized for `MealApiClient`
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
  
  func toMealCategory() -> MealCategory {
    MealCategory(id: idCategory, name: strCategory, imageUrlString: strCategoryThumb, longDescription: strCategoryDescription)
  }
}

private struct MealsResponse: Decodable {
  let meals: [MealResponse]
}

private struct MealResponse: Decodable {
  let idMeal: String
  let strMeal: String
  let strMealThumb: String?
  
  func toMeal() -> Meal {
    Meal(id: idMeal, name: strMeal, imageUrlString: strMealThumb)
  }
}
