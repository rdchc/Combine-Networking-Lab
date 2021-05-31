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
  
  let sampleItemView = ItemView()
  
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
    
    setupItemView(sampleItemView, title: "Sample Item View", info: "A sample view for UI implementations")
  }
  
  private func setupItemView(_ itemView: ItemView, title: String?, info: String? = nil) {
    itemView.title = title
    itemView.infoText = info
    stackView.addArrangedSubview(itemView)
    itemView.showInfoPublisher
      .sink { [weak self] info in
        let alert = UIAlertController(title: "Info", message: info, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self?.present(alert, animated: true, completion: nil)
      }
      .store(in: &subscriptions)
  }

}
