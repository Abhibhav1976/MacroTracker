//
//  ScanFoodCameraView.swift
//  CalorieCalculator
//
//  Created by Abhibhav RajSingh on 08/04/25.
//

import SwiftUI
import PhotosUI

struct ScanFoodCameraView: View {
    @State private var selectedImage: UIImage?
    @State private var isPickerPresented = false
    @State private var navigateToMealPicker = false
    @State private var selectedMealType: String = ""
    @State private var showMealTypeSelection = false
    @State var queryResult: ImageQueryResult?
    @State private var showLimitAlert = false

    var body: some View {
        NavigationStack {
            VStack {
                Text("Scan Your Food")
                    .font(.largeTitle)
                    .padding(.top)

                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 300, maxHeight: 300)
                        .cornerRadius(12)
                        .padding()
                }

                if let result = queryResult {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Estimated Calories").font(.headline)
                        Text("Dish: \(result.label)")
                        Text("Calories: \(result.calories) kcal")
                        Text("Protein: \(result.protein)g")
                        Text("Carbs: \(result.carbs)g")
                        Text("Fat: \(result.fat)g")
                            .padding(.bottom)
                        /*Text("Details: \(result.message)")
                            .font(.footnote)
                            .foregroundColor(.gray)
                         */
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }

                Button(action: {
                    isPickerPresented = true
                }) {
                    Text("Open Camera")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .padding(.horizontal)
                }

                NavigationLink(destination: MealSelectionView(selectedMealType: $selectedMealType), isActive: $navigateToMealPicker) {
                    EmptyView()
                }

                VStack(spacing: 16) {
                    Text("Select Meal Type")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    MealSelectionView(selectedMealType: $selectedMealType)
                }
                .padding(.horizontal)
                .opacity(showMealTypeSelection ? 1 : 0)
                .offset(y: showMealTypeSelection ? 0 : 15)
                .animation(.easeInOut(duration: 0.4), value: showMealTypeSelection)

                Spacer()
            }
            .sheet(isPresented: $isPickerPresented) {
                ImagePicker(selectedImage: $selectedImage, onImagePicked: {
                    navigateToMealPicker = true
                })
            }
            .onAppear {
                withAnimation(.easeIn(duration: 0.5)) {
                    showMealTypeSelection = true
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: Notification.Name("ImageQueryResultNotification"))) { notification in
                if let result = notification.object as? ImageQueryResult {
                    self.queryResult = result
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: Notification.Name("ImageQueryLimitReachedNotification"))) { _ in
                self.showLimitAlert = true
            }
            .alert("Daily Limit Reached", isPresented: $showLimitAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("You've used all your food scans for today. Please come back tomorrow.")
            }
        }
    }
}

// This is a basic ImagePicker wrapper using UIImagePickerController
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    var onImagePicked: () -> Void

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        picker.allowsEditing = false
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage,
               let scaledImage = image.scaledTo720p(),
               let imageData = scaledImage.jpegData(compressionQuality: 0.8) {
                let base64String = imageData.base64EncodedString()
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                let today = formatter.string(from: Date())
                image.sendToServer(entryDate: today) { result in
                    switch result {
                    case .success(let response):
                        DispatchQueue.main.async {
                            self.parent.selectedImage = scaledImage
                            NotificationCenter.default.post(name: Notification.Name("ImageQueryResultNotification"), object: response)
                        }
                    case .failure(let error):
                        if let nsError = error as NSError?, nsError.code == 403 {
                            DispatchQueue.main.async {
                                NotificationCenter.default.post(name: Notification.Name("ImageQueryLimitReachedNotification"), object: nil)
                            }
                        } else {
                            print("Image query failed: \(error.localizedDescription)")
                        }
                    }
                }
            }
            picker.dismiss(animated: true)
        }
    }
}

// Temporary MealSelectionView
struct MealSelectionView: View {
    @Binding var selectedMealType: String
    let mealTypes = ["Breakfast", "Lunch", "Dinner", "Snack"]

    var body: some View {
        HStack(spacing: 12) {
            ForEach(mealTypes, id: \.self) { meal in
                Text(meal)
                    .padding()
                    .background(selectedMealType == meal ? Color.blue : Color.gray.opacity(0.2))
                    .foregroundColor(selectedMealType == meal ? .white : .black)
                    .cornerRadius(10)
                    .onTapGesture {
                        selectedMealType = meal
                    }
            }
        }
    }
}
