//
//  ViewController.swift
//  Combine Networking Lab
//
//  Created by CCH on 31/5/2021.
//

import UIKit
import Combine
import Then
import TinyConstraints

class ViewController: UIViewController {
  
  private let scrollView = UIScrollView()
  private let scrollContentView = UIView()
  private let stackView = UIStackView()
  
  var itemViewModel0 = ItemViewModel()
  
  private var subscriptions = Set<AnyCancellable>()
  
  
  // MARK: - Methods

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    setupViews()
  }
  
  private func setupViews() {
    scrollView.do {
      view.addSubview($0)
      $0.edgesToSuperview(usingSafeArea: true)
    }
    scrollContentView.do {
      scrollView.addSubview($0)
      $0.edgesToSuperview()
      $0.widthToSuperview()
      $0.heightToSuperview(priority: .defaultLow)
    }
    
    stackView.do {
      $0.axis = .vertical
      scrollContentView.addSubview($0)
      $0.edgesToSuperview()
    }
    
    // Sample item view
    itemViewModel0.do {
      $0.title = "Sample Item View"
      $0.infoText = "A sample view for UI implementations"
      $0.showInfoPublisher
        .sink { [weak self] info in
          let alert = UIAlertController(title: "Info", message: info, preferredStyle: .alert)
          alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
          self?.present(alert, animated: true, completion: nil)
        }
        .store(in: &subscriptions)
      ItemView(viewModel: $0).do { v in
        stackView.addArrangedSubview(v)
      }
    }
  }

}
