import PhotosUI
import SwiftUI
import UIKit

// MARK: - Photo Source Controller

/// App-wide controller for the photo source chooser. Hoisted to the root view
/// so the backdrop dims the whole screen (including the tab bar); anywhere in
/// the tree can call `present(onImagePicked:)` to open the sheet.
@Observable
final class PhotoSourceController {
    var isPresented: Bool = false
    var onImagePicked: ((Data) -> Void)?

    func present(onImagePicked: @escaping (Data) -> Void) {
        self.onImagePicked = onImagePicked
        isPresented = true
    }

    func imagePicked(_ data: Data) {
        onImagePicked?(data)
    }
}

// MARK: - Root modifier

/// Attaches the photo source chooser to a root view. The backdrop fills the
/// hosting view's bounds — apply this at the app root so the dim covers the
/// whole screen.
struct PhotoSourcePickerRootModifier: ViewModifier {
    @Bindable var controller: PhotoSourceController

    @State private var selectedPhoto: PhotosPickerItem?
    @State private var showPhotoPicker = false
    @State private var showCamera = false

    func body(content: Content) -> some View {
        content
            .photosPicker(isPresented: $showPhotoPicker, selection: $selectedPhoto, matching: .images)
            .task(id: selectedPhoto) {
                guard let selectedPhoto else { return }
                defer { self.selectedPhoto = nil }
                if let data = try? await selectedPhoto.loadTransferable(type: Data.self) {
                    controller.imagePicked(data)
                }
            }
            .fullScreenCover(isPresented: $showCamera) {
                CameraPicker { data in
                    showCamera = false
                    if let data {
                        controller.imagePicked(data)
                    }
                }
                .ignoresSafeArea()
            }
            .overlay {
                PhotoSourceBottomSheet(
                    isPresented: $controller.isPresented,
                    onSelectGallery: { showPhotoPicker = true },
                    onSelectCamera: { showCamera = true }
                )
            }
    }
}

extension View {
    /// Installs the photo-source chooser (gallery / camera) at the app root
    /// driven by a shared `PhotoSourceController`.
    func photoSourcePickerRoot(_ controller: PhotoSourceController) -> some View {
        modifier(PhotoSourcePickerRootModifier(controller: controller))
    }
}

// MARK: - Camera Picker (UIImagePickerController wrapper)

/// SwiftUI wrapper around `UIImagePickerController` configured for the device
/// camera. Returns JPEG `Data` on capture, or `nil` when cancelled / when the
/// camera is unavailable (e.g. simulator — falls back to the photo library).
struct CameraPicker: UIViewControllerRepresentable {
    let onPicked: (Data?) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onPicked: onPicked)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.sourceType = .camera
            picker.cameraCaptureMode = .photo
        } else {
            picker.sourceType = .photoLibrary
        }
        picker.allowsEditing = false
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let onPicked: (Data?) -> Void

        init(onPicked: @escaping (Data?) -> Void) {
            self.onPicked = onPicked
        }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            let image = info[.originalImage] as? UIImage
            onPicked(image?.jpegData(compressionQuality: 0.9))
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            onPicked(nil)
        }
    }
}
