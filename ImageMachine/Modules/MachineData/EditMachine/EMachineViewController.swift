//
//  EMachineViewController.swift
//  ImageMachine
//
//  Created by Elang Putra Sartika on 04/08/21.
//

import UIKit
import DatePicker
import ImagePicker

class EMachineViewController: UIViewController {
	var viewModel: EMachineViewModel?
	var router: IEMachineRouter?
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var typeTextField: UITextField!
    @IBOutlet weak var qrCodeTextField: UITextField!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var photoLabel: UITextField!
    @IBOutlet weak var collectionView: UICollectionView!
    
    init(viewModel: EMachineViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupComponent()
        getMachine()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUI()
    }

    private func setupComponent() {
        self.navigationController?.isNavigationBarHidden = false
        nameTextField.delegate = self
        typeTextField.delegate = self
        qrCodeTextField.delegate = self
        dateTextField.text = Date().yyyyMMdd
        collectionView.register(UINib(nibName: "PhotoCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PhotoCollectionViewCell")
    }
    
    private func getMachine() {
        viewModel?.getMachine()
    }

    private func setUI() {
        guard let data = viewModel?.data else {return}
        
        nameTextField.text = data.name
        typeTextField.text = data.type
        qrCodeTextField.text = data.codeNumber
        dateTextField.text = data.updatedAt?.yyyyMMdd
        photoLabel.text = "\((viewModel?.images?.count ?? viewModel?.displayedImages.count) ?? 0) photos"
    }
    
    
    @IBAction func dateTapped(_ sender: UIButton) {
        view.endEditing(true)
        let minDate = DatePickerHelper.shared.dateFrom(day: 18, month: 08, year: 1990)!
        let maxDate = DatePickerHelper.shared.dateFrom(day: 18, month: 08, year: 2030)!
        let today = Date()
        let datePicker = DatePicker()
        datePicker.setup(beginWith: today, min: minDate, max: maxDate) { (selected, date) in
            if selected, let selectedDate = date {
                self.dateTextField.text = selectedDate.yyyyMMdd
                self.viewModel?.data?.updatedAt = selectedDate
            } else {
                print("Cancelled")
            }
        }
        datePicker.show(in: self, on: sender)
    }
    
    @IBAction func camera(_ sender: UIButton) {
        let imagePickerController = ImagePickerController()
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction func updateButtonTapped(_ sender: UIButton) {
        guard let data = viewModel?.data else {return}
        let name = data.name ?? ""
        let type = data.type ?? ""
        let qrCode = data.codeNumber ?? ""
        
        if name.isEmpty || type.isEmpty || qrCode.isEmpty {
            Toast.share.show(message: "Please fill all required field")
        } else {
            viewModel?.updateMachine()
        }
    }
}

extension EMachineViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.isEqual(nameTextField) {
            viewModel?.data?.name = nameTextField.text ?? ""
        } else if textField.isEqual(typeTextField) {
            viewModel?.data?.type = typeTextField.text ?? ""
        } else if textField.isEqual(qrCodeTextField) {
            viewModel?.data?.codeNumber = qrCodeTextField.text ?? ""
        }
    }
}

extension EMachineViewController: ImagePickerDelegate {
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        //
    }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        if images.count > 10 {
            Toast.share.show(message: "Maximum photos exceed (max. 10 photos)")
        } else {
            viewModel?.images = images
            photoLabel.text = "\(viewModel?.images?.count ?? 0) photos"
            imagePicker.dismiss()
        }
    }
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        imagePicker.dismiss()
    }
    
    
}

extension EMachineViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel?.displayedImages.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionViewCell", for: indexPath) as! PhotoCollectionViewCell
        guard let item = viewModel?.displayedImages[indexPath.row] else {
            return PhotoCollectionViewCell()
        }
        cell.setupView(item: item)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = viewModel?.displayedImages[indexPath.row]
        router?.pushToImageView(image: UIImage(data: item?.img ?? Data()) ?? UIImage())
    }
}

extension EMachineViewController: IEMachineDelegate {
    func didSuccessGetImages() {
        setUI()
        collectionView.reloadData()
    }
    
    func didFailGetImages() {
        Toast.share.show(message: "Something went wrong")
    }
    
    func didSuccessDeleteImages() {
        viewModel?.createPhotos()
    }
    
    func didFailDeleteImages() {
        Toast.share.show(message: "Something went wrong")
    }
    
    func didSuccessUpload() {
        router?.toRoot()
    }
    
    func didFailUpload() {
        Toast.share.show(message: "Something went wrong")
    }
    
    func didSuccessUpdate() {
        viewModel?.deleteImages()
    }
    func didFailUpdate() {
        Toast.share.show(message: "Something went wrong")
    }
    
    func didSuccessGetMachine() {
        viewModel?.getImages()
    }
    
    func didFailGetMachine() {
        Toast.share.show(message: "Something went wrong")
    }
}
