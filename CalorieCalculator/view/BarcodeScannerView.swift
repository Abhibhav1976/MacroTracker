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
    @State private var scanLineOffset: CGFloat = 0 // For scanning animation
    @State private var forceRefresh = false // New state to force UI update

    @State private var fetchedFoodItem: BarcodeScannedFood? {
        didSet {
            print("Fetched food item updated: \(String(describing: fetchedFoodItem))")
        }
    }

    let userId = UserDefaults.standard.integer(forKey: "UserId")

    var body: some View {
        ZStack {
            Color(hex: "#1C2526")
                .ignoresSafeArea()

            ScannerViewController(
                scannedCode: $scannedBarcode,
                isScanning: $scannerModel.isScanning
            )
            .ignoresSafeArea()

            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "#1C2526").opacity(0.85),
                    Color.clear,
                    Color(hex: "#1C2526").opacity(0.85)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            if !isProcessing {
                GeometryReader { geometry in
                    let frameWidth = geometry.size.width * 0.7
                    let frameHeight = geometry.size.height * 0.5
                    
                    RoundedRectangle(cornerRadius: 16)
                        .frame(width: frameWidth, height: frameHeight)
                        .foregroundColor(.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color(hex: "#00D4FF"), lineWidth: 2)
                                .shadow(color: Color(hex: "#00D4FF").opacity(0.5), radius: 4)
                        )
                        .overlay(
                            Rectangle()
                                .frame(height: 4)
                                .foregroundColor(Color(hex: "#00D4FF"))
                                .shadow(color: Color(hex: "#00D4FF").opacity(0.7), radius: 8)
                                .offset(y: scanLineOffset)
                                .animation(
                                    scannerModel.isScanning ?
                                        Animation.easeInOut(duration: 1.5)
                                            .repeatForever(autoreverses: true) :
                                        nil,
                                    value: scanLineOffset
                                )
                                .opacity(scannerModel.isScanning ? 1 : 0)
                        )
                        .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                        .onChange(of: scannerModel.isScanning) { isScanning in
                            scanLineOffset = isScanning ? -frameHeight / 2 : 0
                        }
                }
            }

            if isProcessing {
                ZStack {
                    Circle()
                        .frame(width: 60, height: 60)
                        .foregroundColor(.clear)
                        .overlay(
                            Circle()
                                .trim(from: 0, to: 0.8)
                                .stroke(Color(hex: "#00D4FF"), style: StrokeStyle(lineWidth: 4, lineCap: .round))
                                .rotationEffect(Angle(degrees: isProcessing ? 360 : 0))
                                .animation(
                                    Animation.linear(duration: 1)
                                        .repeatForever(autoreverses: false),
                                    value: isProcessing
                                )
                        )
                        .scaleEffect(isProcessing ? 1.2 : 1.0)
                        .animation(
                            Animation.easeInOut(duration: 0.8)
                                .repeatForever(autoreverses: true),
                            value: isProcessing
                        )
                }
            }

            Text("Scan Barcode")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color(hex: "#E8ECEF"))
                .opacity(scannerModel.isScanning ? 1 : 0.5)
                .shadow(color: Color(hex: "#00D4FF").opacity(0.3), radius: 2)
                .position(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height * 0.08)

            Button(action: {
                isShowingScanner = false
            }) {
                Text("Cancel")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color(hex: "#00D4FF"))
                    .shadow(color: Color(hex: "#00D4FF").opacity(0.4), radius: 4)
            }
            .position(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height * 0.85)

            if showError {
                ZStack {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                    VStack {
                        Text("Error")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Color(hex: "#E8ECEF"))
                        Text(errorMessage)
                            .font(.system(size: 16))
                            .foregroundColor(Color(hex: "#FF6B6B"))
                            .multilineTextAlignment(.center)
                            .padding(.top, 4)
                        Button("OK") {
                            showError = false
                            scannerModel.isScanning = true
                        }
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(hex: "#00D4FF"))
                        .padding(.top, 12)
                    }
                    .padding(20)
                    .background(Color(hex: "#E8ECEF").opacity(0.95))
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.2), radius: 10)
                }
            }
        }
        .id(forceRefresh) // Force refresh when this changes
        .onChange(of: scannedBarcode) { newBarcode in
            guard !newBarcode.isEmpty, !isProcessing else { return }
            handleScannedBarcode(newBarcode)
        }
        .onAppear {
            scannerModel.isScanning = true
            scannedBarcode = ""
        }
        .onDisappear {
            scannerModel.isScanning = false
        }
    }

    private func handleScannedBarcode(_ barcode: String) {
        print("Processing barcode: \(barcode)")
        isProcessing = true
        scannerModel.isScanning = false

        fetchFoodByBarcode(barcode: barcode, userId: userId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let food):
                    if let food = food {
                        print("Barcode \(barcode) exists. Transitioning to BarcodeScannedFoodLoggingView.")
                        fetchedFoodItem = food
                        print("Fetched food item is ready: \(food)")

                        // Delay view state update to avoid grey screen
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                            print("Triggering transition with loader still active...")
                            isProcessing = true
                            isShowingBarcodeFoodLogging = true
                            isShowingScanner = false
                            forceRefresh.toggle()
                        }
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
                    }
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    isProcessing = false
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                    scannedBarcode = ""
                }
                if isShowingScanner && !showError {
                    scannerModel.isScanning = true
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
