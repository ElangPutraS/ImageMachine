//
//  ListMachineViewController.swift
//  ImageMachine
//
//  Created by Elang Putra Sartika on 03/08/21.
//

import UIKit

class ListMachineViewController: UIViewController {
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var homeTableView: UITableView!
    @IBOutlet weak var AddButton: UIButton!
    
    var viewModel: ListMachineViewModel?
    var router: IListMachineRouter?
    var loadingView: LoadingView!
    
    lazy var refreshControl: UIRefreshControl = {
        let rc = UIRefreshControl()
        rc.addTarget(self, action: #selector(refreshList), for: .valueChanged)
        return rc
    }()
    
    init(viewModel: ListMachineViewModel) {
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
        getList()
        setUI()
    }
    
    private func setupComponent() {
        homeTableView.refreshControl = refreshControl
        self.navigationController?.isNavigationBarHidden = false
        self.title = "MACHINE DATA"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "ADD", style: .done, target: self, action: #selector(addButtonPressed))
        homeTableView.registerCellType(MachineTableViewCell.self)
        
        loadingView = LoadingView()
        loadingView.setup(in: contentView)
        loadingView.reloadButton.touchUpInside(self, action: #selector(getList))
    }
    
    private func setUI() {
        //
    }
    
    @objc private func getList() {
        loadingView.start { [weak self] in
            guard let self = self else { return }
            self.viewModel?.fetchMachines()
        }
    }
    
    @objc private func refreshList() {
        viewModel?.fetchMachines()
    }
    
    @objc func addButtonPressed() {
        router?.createMachine()
    }
}

extension ListMachineViewController: ListMachineViewModelDelegate {
    func didSuccessGetList() {
        if refreshControl.isRefreshing {
            refreshControl.endRefreshing()
        }

        homeTableView.reloadData()
        loadingView.stop()
    }
    
    func didFailGetList(errorMsg: String) {
        if refreshControl.isRefreshing {
            refreshControl.endRefreshing()
            Toast.share.show(message: errorMsg)
        } else {
            loadingView.stop(isFailed: true, message: errorMsg)
        }
    }
}

extension ListMachineViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.list.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(MachineTableViewCell.self, for: indexPath)
        guard let item = viewModel?.list[indexPath.row] else { return MachineTableViewCell() }
        cell.setupView(item: item)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = viewModel?.list[indexPath.row]
        router?.showMachine(code: item?.codeNumber ?? "")
    }
}
