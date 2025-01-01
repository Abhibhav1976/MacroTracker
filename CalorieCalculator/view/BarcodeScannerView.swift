import SwiftUI
import AVFoundation

struct BarcodeScannerView: View {
    @Binding var scannedBarcode: String
    @Binding var isShowingScanner: Bool
    @Binding var isShowingFoodInput: Bool
    @Binding var isShowingFoodLogging: Bool
    @Binding var isShowingBarcodeFoodLogging: Bool

    @StateObject private var scannerModel = BarcodeScannerViewModel()
    @State private var isProcessing = false
    @State private var showError = false
    @State private var errorMessage = ""

    @State private var fetchedFoodItem: BarcodeScannedFood? {
        didSet {
            print("Fetched food item updated: \(String(describing: fetchedFoodItem))")
        }
    }

    let userId = UserDefaults.standard.integer(forKey: "UserId")

    var body: some View {
        ZStack {
            ColorPalette.background.ignoresSafeArea()

            if isProcessing {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
            } else {
                ScannerViewController(
                    scannedCode: $scannedBarcode,
                    isScanning: $scannerModel.isScanning
                )
                .ignoresSafeArea()
            }
        }
        .onChange(of: scannedBarcode) { newBarcode in
            guard !newBarcode.isEmpty else { return }
            handleScannedBarcode(newBarcode)
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }

    private func handleScannedBarcode(_ barcode: String) {
        print("Scanned barcode: \(barcode)")
        isProcessing = true
        scannerModel.isScanning = false

        fetchFoodByBarcode(barcode: barcode, userId: userId) { result in
            DispatchQueue.main.async {
                isProcessing = false

                switch result {
                case .success(let food):
                    if let food = food {
                        print("Barcode \(barcode) exists. Transitioning to FoodLoggingView.")
                        fetchedFoodItem = food
                        isShowingFoodLogging = true
                        isShowingScanner = false
                    } else {
                        print("Barcode \(barcode) does not exist. Transitioning to FoodInputView.")
                        isShowingFoodInput = true
                        isShowingScanner = false
                    }
                case .failure(let error):
                    print("Error fetching food by barcode: \(error.localizedDescription)")
                    if error.localizedDescription == "Barcode does not exist. Full food details required." {
                        isShowingFoodInput = true
                        isShowingScanner = false
                    } else {
                        errorMessage = error.localizedDescription
                        showError = true
                        scannerModel.isScanning = true
                    }
                }
            }
        }
    }
}

class BarcodeScannerViewModel: ObservableObject {
    @Published var isScanning = true
}

struct ScannerViewController: UIViewControllerRepresentable {
    @Binding var scannedCode: String
    @Binding var isScanning: Bool

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        let captureSession = AVCaptureSession()

        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            return viewController
        }

        let videoInput: AVCaptureDeviceInput

        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return viewController
        }

        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            return viewController
        }

        let metadataOutput = AVCaptureMetadataOutput()

        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)

            metadataOutput.setMetadataObjectsDelegate(context.coordinator, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.ean8, .ean13, .pdf417]
        } else {
            return viewController
        }

        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = viewController.view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        viewController.view.layer.addSublayer(previewLayer)

        context.coordinator.captureSession = captureSession

        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if isScanning {
            context.coordinator.startScanning()
        } else {
            context.coordinator.stopScanning()
        }
    }

    class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
        var parent: ScannerViewController
        var captureSession: AVCaptureSession?

        init(_ parent: ScannerViewController) {
            self.parent = parent
        }

        func startScanning() {
            if let session = captureSession, !session.isRunning {
                DispatchQueue.global(qos: .background).async {
                    session.startRunning()
                }
            }
        }

        func stopScanning() {
            if let session = captureSession, session.isRunning {
                DispatchQueue.global(qos: .background).async {
                    session.stopRunning()
                }
            }
        }

        func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
            if let metadataObject = metadataObjects.first,
               let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
               let stringValue = readableObject.stringValue {
                parent.scannedCode = stringValue
            }
        }
    }
}
