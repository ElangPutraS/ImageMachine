//
//  ScannerViewController.swift
//  ImageMachine
//
//  Created by Elang Putra Sartika on 03/08/21.
//

import UIKit

import AVFoundation
import UIKit

class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    @IBOutlet weak var captureView: UIView!
    @IBOutlet weak var scannerView: UIView!
    @IBOutlet fileprivate var toggleFlashButton: UIButton!
    @IBOutlet weak var goToSettingButton: UIButton!
    @IBOutlet weak var noAccessView: UIView!
    
    let viewModel: ScannerViewModel?
    var router: IScannerRouter?
    private var captureSession: AVCaptureSession!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private var camera: AVCaptureDevice!
    private var layer: CAGradientLayer!
    private var isLoaded: Bool = false
    var isFromHomePage: Bool = false
    private var timeoutTimer: Timer?
    private var tempCode: String?
    
    init(viewModel: ScannerViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupComponent()
        setupScanner()
    }
    
    private func setupComponent() {
        view.backgroundColor = UIColor.green
        self.navigationController?.isNavigationBarHidden = false
        self.title = "SCAN QR"
    }
    
    private func setupScanner() {
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            return
        }
        
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        guard captureSession.canAddInput(videoInput) else {
            failed()
            return
        }
        
        captureSession.addInput(videoInput)
        
        let metadataOutput = AVCaptureMetadataOutput()
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.code128, .code39, .code93, .code39Mod43, .dataMatrix, .ean13, .ean8, .qr]
        } else {
            failed()
            return
        }

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        previewLayer.videoGravity = .resizeAspectFill
        
        captureView.layer.addSublayer(previewLayer)
        scannerView.layer.borderWidth = 1
        scannerView.layer.borderColor = UIColor.black.cgColor
        metadataOutput.rectOfInterest = previewLayer.frame
        scannerView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard !isLoaded else { return }
        layer = createScannerGradientLayer(for: scannerView)
        captureView.layer.insertSublayer(layer, at: 10)
        let animation = createAnimation(for: layer)
        layer.add(animation, forKey: nil)
        isLoaded = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        goToSettingButton.layer.cornerRadius = 5
        
        if AVCaptureDevice.authorizationStatus(for: .video) == .authorized {
            if captureSession?.isRunning == false {
                captureSession.startRunning()
            }
        } else {
            AVCaptureDevice.requestAccess(for: .video) { [weak self] response in
                if response {
                    if self?.captureSession?.isRunning == false {
                        self?.captureSession.startRunning()
                    }
                } else {
                    DispatchQueue.main.async {
                        self?.noAccessView.isHidden = false
                    }
                }
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        captureSession = nil
        previewLayer = nil
        camera = nil
        layer = nil
        tempCode = nil
        timeoutTimer?.invalidate()
        timeoutTimer = nil
//        TheInterfaceManager.hideLoading(view: view)
    }
    
    func failed() {
        let title = "Not Supported"
        let message = "Sorry, scanner unsupported"
//        TheAlertManager.show(inViewController: self, title: title, message: message)
        captureSession = nil
    }
    
    func setTimer() {
        timeoutTimer?.invalidate()
        timeoutTimer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(timeout), userInfo: nil, repeats: false)
    }
    
    func createScannerGradientLayer(for view: UIView) -> CAGradientLayer {
        let height: CGFloat = 5
        let opacity: Float = 0.5
        let topColor = UIColor.red
        let bottomColor = topColor.withAlphaComponent(0)
        
        let layer = CAGradientLayer()
        layer.colors = [topColor.cgColor, bottomColor.cgColor]
        layer.opacity = opacity
        layer.frame = CGRect(x: view.frame.origin.x, y: view.frame.origin.y, width: view.frame.width, height: height)
        return layer
    }
    
    func createAnimation(for layer: CAGradientLayer) -> CABasicAnimation {
        guard layer.superlayer != nil else {
            fatalError("Unable to create animation, layer should have superlayer")
        }
        let value = scannerView.frame.height
        let initialYPosition = scannerView.frame.origin.y
        let finalYPosition = initialYPosition + value
        let duration: CFTimeInterval = 3
        
        let animation = CABasicAnimation(keyPath: "position.y")
        animation.fromValue = initialYPosition as NSNumber
        animation.toValue = finalYPosition as NSNumber
        animation.duration = duration
        animation.repeatCount = .infinity
        animation.isRemovedOnCompletion = false
        return animation
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if captureSession != nil {
            captureSession.stopRunning()
        }
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            found(code: stringValue, isManual: false)
        }
    }
    
    func found(code: String, isManual: Bool) {
        tempCode = code
        viewModel?.getMachine(code: code)
    }

    func errorResponseHandler(errorTitle: String, errorMsg: String, errorCode: Int) {
//        TheInterfaceManager.hideLoading(view: view)
        timeoutTimer?.invalidate()

        if captureSession != nil {
            captureSession.stopRunning()
        }
    }
    
    @objc func timeout() {
//        TheInterfaceManager.hideLoading(view: view)
    }
    
    @IBAction func toggleFlash(_ sender: UIButton) {
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back)
        
        guard let device = deviceDiscoverySession.devices.first
        else { return }
        if device.hasTorch {
            do {
                try device.lockForConfiguration()
                let on = device.isTorchActive
                if on != true, device.isTorchModeSupported(.on) {
                    try device.setTorchModeOn(level: 1.0)
                } else if device.isTorchModeSupported(.off) {
                    device.torchMode = .off
                } else {
                    print("Torch mode is not supported")
                }
                device.unlockForConfiguration()
            } catch {
                print("Torch could not be used")
            }
        } else {
            print("Torch is not available")
        }
    }
    
    @IBAction func goToSettingButtonTapped(_ sender: Any) {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}

extension ScannerViewController: IScannerDelegate {
    func didSuccessGetMachine(code: String) {
        router?.pushToMachineDetail(code: code)
    }
    
    func didFailGetMachine(err: String) {
        Toast.share.show(message: err)
        captureSession.startRunning()
    }
}
