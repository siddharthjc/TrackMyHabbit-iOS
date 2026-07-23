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
    private(set) var activeSessionID: UUID?
    private var onImagePicked: ((Data) -> Void)?

    @discardableResult
    func present(onImagePicked: @escaping (Data) -> Void) -> UUID {
        let sessionID = UUID()
        activeSessionID = sessionID
        self.onImagePicked = onImagePicked
        isPresented = true
        return sessionID
    }

    func imagePicked(_ data: Data, for sessionID: UUID) {
        guard sessionID == activeSessionID else { return }
        let callback = onImagePicked
        activeSessionID = nil
        onImagePicked = nil
        callback?(data)
    }

    func cancelSession(_ sessionID: UUID) {
        guard sessionID == activeSessionID else { return }
        activeSessionID = nil
        onImagePicked = nil
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
    @State private var gallerySessionID: UUID?
    @State private var cameraSessionID: UUID?

    func body(content: Content) -> some View {
        content
            .photosPicker(isPresented: $showPhotoPicker, selection: $selectedPhoto, matching: .images)
            .task(id: selectedPhoto) {
                guard let selectedPhoto, let sessionID = gallerySessionID else { return }
                defer {
                    if gallerySessionID == sessionID {
                        self.selectedPhoto = nil
                        gallerySessionID = nil
                    }
                }
                if let data = try? await selectedPhoto.loadTransferable(type: Data.self) {
                    controller.imagePicked(data, for: sessionID)
                } else {
                    controller.cancelSession(sessionID)
                }
            }
            .fullScreenCover(isPresented: $showCamera) {
                let sessionID = cameraSessionID
                CameraPicker { data in
                    showCamera = false
                    cameraSessionID = nil
                    guard let sessionID else { return }
                    if let data {
                        controller.imagePicked(data, for: sessionID)
                    } else {
                        controller.cancelSession(sessionID)
                    }
                }
                .ignoresSafeArea()
            }
            .overlay {
                PhotoSourceBottomSheet(
                    isPresented: $controller.isPresented,
                    onSelectGallery: {
                        guard let sessionID = controller.activeSessionID else { return }
                        gallerySessionID = sessionID
                        showPhotoPicker = true
                    },
                    onSelectCamera: {
                        guard let sessionID = controller.activeSessionID else { return }
                        cameraSessionID = sessionID
                        showCamera = true
                    }
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
