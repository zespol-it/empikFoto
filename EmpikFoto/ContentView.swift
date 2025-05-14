//
//  ContentView.swift
//  EmpikFoto
//
//  Created by gskotniczny on 14/05/2025.
//

import SwiftUI
import PhotosUI
import Photos

class ImageSavingCoordinator: NSObject {
    var continuation: CheckedContinuation<Void, Error>?
    var onComplete: ((Error?) -> Void)?
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            continuation?.resume(throwing: error)
        } else {
            continuation?.resume()
        }
        onComplete?(error)
    }
}

struct ContentView: View {
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var selectedImages: [UIImage] = []
    @State private var showingImagePicker = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var imageSavingCoordinator = ImageSavingCoordinator()
    
    var body: some View {
        NavigationView {
            VStack {
                // Grid z wybranymi zdjęciami
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 10) {
                        ForEach(0..<selectedImages.count, id: \.self) { index in
                            Image(uiImage: selectedImages[index])
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        
                        // Przycisk dodawania zdjęć
                        if selectedImages.count < 6 {
                            PhotosPicker(selection: $selectedPhotos,
                                       maxSelectionCount: 6 - selectedImages.count,
                                       matching: .images) {
                                VStack {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 30))
                                    Text("Dodaj zdjęcie")
                                        .font(.caption)
                                }
                                .frame(width: 100, height: 100)
                                .background(Color.gray.opacity(0.2))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                        }
                    }
                    .padding()
                }
                
                // Przycisk tworzenia kolażu
                if !selectedImages.isEmpty {
                    Button(action: {
                        Task {
                            await createCollage()
                        }
                    }) {
                        Text("Utwórz kolaż")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .padding()
                }
            }
            .navigationTitle("Empik Foto")
            .onChange(of: selectedPhotos) { oldValue, newValue in
                Task {
                    for item in newValue {
                        if let data = try? await item.loadTransferable(type: Data.self),
                           let image = UIImage(data: data) {
                            await MainActor.run {
                                selectedImages.append(image)
                            }
                        }
                    }
                    await MainActor.run {
                        selectedPhotos = []
                    }
                }
            }
            .alert("Informacja", isPresented: $showingAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func createCollage() async {
        guard !selectedImages.isEmpty else { return }
        
        // Sprawdź uprawnienia do galerii
        let status = await withCheckedContinuation { continuation in
            PHPhotoLibrary.requestAuthorization { status in
                continuation.resume(returning: status)
            }
        }
        
        await MainActor.run {
            switch status {
            case .authorized, .limited:
                Task {
                    await createAndSaveCollage()
                }
            case .denied, .restricted:
                alertMessage = "Brak uprawnień do zapisu w galerii. Sprawdź ustawienia aplikacji."
                showingAlert = true
            case .notDetermined:
                alertMessage = "Nie określono uprawnień do galerii."
                showingAlert = true
            @unknown default:
                alertMessage = "Nieznany błąd uprawnień."
                showingAlert = true
            }
        }
    }
    
    private func createAndSaveCollage() async {
        let size = CGSize(width: 1200, height: 800)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        do {
            let collage = renderer.image { context in
                // Tło
                UIColor.white.set()
                context.fill(CGRect(origin: .zero, size: size))
                
                // Układ zdjęć w zależności od ich liczby
                let layout = calculateLayout(for: selectedImages.count)
                
                for (index, image) in selectedImages.enumerated() {
                    let rect = layout[index]
                    image.draw(in: rect)
                }
            }
            
            // Zapisz kolaż do galerii
            try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
                imageSavingCoordinator.continuation = continuation
                imageSavingCoordinator.onComplete = { error in
                    Task {
                        await MainActor.run {
                            if let error = error {
                                alertMessage = "Wystąpił błąd podczas zapisywania kolażu: \(error.localizedDescription)"
                            } else {
                                alertMessage = "Kolaż został zapisany do galerii"
                            }
                            showingAlert = true
                        }
                    }
                }
                UIImageWriteToSavedPhotosAlbum(collage, imageSavingCoordinator, #selector(ImageSavingCoordinator.image(_:didFinishSavingWithError:contextInfo:)), nil)
            }
        } catch {
            await MainActor.run {
                alertMessage = "Wystąpił błąd podczas tworzenia kolażu: \(error.localizedDescription)"
                showingAlert = true
            }
        }
    }
    
    private func calculateLayout(for count: Int) -> [CGRect] {
        let size = CGSize(width: 1200, height: 800)
        var layouts: [CGRect] = []
        
        switch count {
        case 1:
            layouts = [CGRect(x: 100, y: 100, width: 1000, height: 600)]
        case 2:
            layouts = [
                CGRect(x: 100, y: 100, width: 500, height: 600),
                CGRect(x: 600, y: 100, width: 500, height: 600)
            ]
        case 3:
            layouts = [
                CGRect(x: 100, y: 100, width: 500, height: 600),
                CGRect(x: 600, y: 100, width: 500, height: 300),
                CGRect(x: 600, y: 400, width: 500, height: 300)
            ]
        case 4:
            layouts = [
                CGRect(x: 100, y: 100, width: 500, height: 300),
                CGRect(x: 600, y: 100, width: 500, height: 300),
                CGRect(x: 100, y: 400, width: 500, height: 300),
                CGRect(x: 600, y: 400, width: 500, height: 300)
            ]
        case 5:
            layouts = [
                CGRect(x: 100, y: 100, width: 500, height: 300),
                CGRect(x: 600, y: 100, width: 500, height: 300),
                CGRect(x: 100, y: 400, width: 400, height: 300),
                CGRect(x: 500, y: 400, width: 400, height: 300),
                CGRect(x: 900, y: 400, width: 200, height: 300)
            ]
        case 6:
            layouts = [
                CGRect(x: 100, y: 100, width: 400, height: 300),
                CGRect(x: 500, y: 100, width: 400, height: 300),
                CGRect(x: 900, y: 100, width: 200, height: 300),
                CGRect(x: 100, y: 400, width: 400, height: 300),
                CGRect(x: 500, y: 400, width: 400, height: 300),
                CGRect(x: 900, y: 400, width: 200, height: 300)
            ]
        default:
            break
        }
        
        return layouts
    }
}

#Preview {
    ContentView()
}
