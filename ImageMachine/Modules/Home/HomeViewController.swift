//
//  HomeViewController.swift
//  ImageMachine
//
//  Created by Elang Putra Sartika on 03/08/21.
//

import UIKit

class HomeViewController: UIViewController {
    @IBOutlet weak var machineButton: UIButton!
    @IBOutlet weak var scannerButton: UIButton!
    
    var router: IHomeRouter?
    var viewModel: HomeViewModel?
    
    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupComponent()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUI()
    }
    
    private func setupComponent() {
        //
    }
    
    private func setUI() {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    @IBAction func machineButtonTapped(_ sender: Any) {
        router?.pushToListMachine()
    }
    
    @IBAction func scannerButtonTapped(_ sender: Any) {
        router?.pushToScanner()
    }
}
