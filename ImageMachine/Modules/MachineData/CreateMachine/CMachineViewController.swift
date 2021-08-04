//
//  CMachineViewController.swift
//  ImageMachine
//
//  Created by Elang Putra Sartika on 04/08/21.
//

import UIKit
import DatePicker
import ImagePicker

class CMachineViewController: UIViewController {
	var viewModel: CMachineViewModel?
	var router: ICMachineRouter?
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var typeTextField: UITextField!
    @IBOutlet weak var qrCodeTextField: UITextField!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var photoLabel: UITextField!
    
    init(viewModel: CMachineViewModel) {
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
        self.navigationController?.isNavigationBarHidden = false
        dateTextField.text = Date().yyyyMMdd
        photoLabel.text = "\(viewModel?.images.count ?? 0) photos"
    }

    private func setUI() {
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
                self.viewModel?.date = selectedDate
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
    
    @IBAction func createButtonTapped(_ sender: UIButton) {
        if viewModel?.name.isEmpty ?? true || viewModel?.type.isEmpty ?? true || viewModel?.qrCode.isEmpty ?? true {
            Toast.share.show(message: "Please fill all required field")
        } else {
            viewModel?.createMachine()
        }
    }
}

extension CMachineViewController: ImagePickerDelegate {
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        //
    }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        if images.count > 10 {
            Toast.share.show(message: "Maximum photos exceed (max. 10 photos)")
        } else {
            viewModel?.images = images
            photoLabel.text = "\(viewModel?.images.count ?? 0) photos"
            imagePicker.dismiss()
        }
    }
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        imagePicker.dismiss()
    }
    
    
}

extension CMachineViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.isEqual(nameTextField) {
            viewModel?.name = nameTextField.text ?? ""
        } else if textField.isEqual(typeTextField) {
            viewModel?.type = typeTextField.text ?? ""
        } else if textField.isEqual(qrCodeTextField) {
            viewModel?.qrCode = qrCodeTextField.text ?? ""
        }
    }
}

extension CMachineViewController: ICMachineDelegate {
    func didSuccessUpload() {
        Toast.share.show(message: "Machine created")
        router?.pop()
    }
    
    func didFailUpload() {
        Toast.share.show(message: "Failed to upload photos")
    }
    
    func didSuccessCreate() {
        viewModel?.createPhotos()
    }
    
    func didFailCreate() {
        Toast.share.show(message: "Something went wrong")
    }
}
