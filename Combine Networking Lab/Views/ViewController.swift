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
  
  // TODO: Make view model for view controller
  var itemViewModel0 = ItemViewModel()
  var itemViewModel1 = MealItemViewModel()
  
  private let showInfoSubject = PassthroughSubject<String, Never>()
  private var subscriptions = Set<AnyCancellable>()
  
  
  // MARK: - Methods

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    setupViews()
    setupBindings()
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
    itemViewModel0.do { vm in
      vm.title = "Sample Item View"
      
      // Commented for example code.
      // TODO: Remove when other item view use below code
//      let infoBtn = UIButton(type: .system, primaryAction: .init(handler: { [weak self] _ in
//        guard let self = self else { return }
//        self.showInfoSubject.send("A sample view for UI implementations")
//      })).then { btn in
//        btn.setImage(UIImage(systemName: "info.circle"), for: .normal)
//      }
      
      let errorSwitch = UISwitch(frame: .zero, primaryAction: .init(handler: { action in
        guard let sender = action.sender as? UISwitch else { return }
        vm.showError = sender.isOn
      }))
      let errorLabel = UILabel().then {
        $0.text = "Toggle error"
      }
      ItemView(viewModel: vm).do { v in
        [errorSwitch, errorLabel].forEach { subview in
          v.customStackView.addArrangedSubview(subview)
        }
        stackView.addArrangedSubview(v)
      }
    }
    
    itemViewModel1.do { vm in
      vm.title = "Meal Categories"
      
      let infoBtn = UIButton(type: .system, primaryAction: .init(handler: { [weak self] _ in
        guard let self = self else { return }
        self.showInfoSubject.send("This item fetches all meal categories available.")
      })).then { btn in
        btn.setImage(UIImage(systemName: "info.circle"), for: .normal)
      }
      ItemView(viewModel: vm).do { v in
        v.customStackView.addArrangedSubview(infoBtn)
        stackView.addArrangedSubview(v)
      }
    }
  }
  
  private func setupBindings() {
    showInfoSubject
      .sink { [weak self] info in
        let alert = UIAlertController(title: "Info", message: info, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self?.present(alert, animated: true, completion: nil)
      }
      .store(in: &subscriptions)
  }

}
