//
//  MachineViewController.swift
//  ImageMachine
//
//  Created by Elang Putra Sartika on 04/08/21.
//

import UIKit

class MachineViewController: UIViewController {
	var viewModel: MachineViewModel?
	var router: IMachineRouter?
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var qrCodeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    init(viewModel: MachineViewModel) {
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
        getMachine()
    }
    
    private func getMachine() {
        viewModel?.getMachine()
    }

    private func setupComponent() {
        collectionView.register(UINib(nibName: "PhotoCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PhotoCollectionViewCell")
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.title = "DETAILS"
    }

    private func setUI() {
        nameLabel.text = viewModel?.data?.name
        typeLabel.text = viewModel?.data?.type
        qrCodeLabel.text = viewModel?.data?.codeNumber
        dateLabel.text = viewModel?.data?.updatedAt?.yyyyMMdd
    }
    
    @IBAction func deleteButtonTapped(_ sender: Any) {
        let refreshAlert = UIAlertController(title: "Refresh", message: "All data will be lost.", preferredStyle: UIAlertController.Style.alert)

        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            self.viewModel?.deleteMachine()
        }))

        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
              print("Handle Cancel Logic here")
        }))

        present(refreshAlert, animated: true, completion: nil)
    }
    
    @IBAction func editButtonTapped(_ sender: Any) {
        router?.pushToEdit(code: viewModel?.code ?? "")
    }
}

extension MachineViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel?.images.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionViewCell", for: indexPath) as! PhotoCollectionViewCell
        guard let item = viewModel?.images[indexPath.row] else {
            return PhotoCollectionViewCell()
        }
        cell.setupView(item: item)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = viewModel?.images[indexPath.row]
        router?.pushToImageView(image: UIImage(data: item?.img ?? Data()) ?? UIImage())
    }
}

extension MachineViewController: IMachineDelegate {
    func didSuccessDeleteImages() {
        Toast.share.show(message: "Delete success")
        router?.pop()
    }
    
    func didFailDeleteImages() {
        Toast.share.show(message: "Something went wrong")
    }
    
    func didSuccessGetImages() {
        collectionView.reloadData()
    }
    
    func didFailGetImages() {
        Toast.share.show(message: "Something went wrong")
    }
    
    func didSuccessDeleteMachine() {
        viewModel?.deleteImages()
    }
    
    func didFailDeleteMachine() {
        Toast.share.show(message: "Something went wrong")
    }
    
    func didSuccessGetMachine() {
        setUI()
        viewModel?.getImages()
    }
}
