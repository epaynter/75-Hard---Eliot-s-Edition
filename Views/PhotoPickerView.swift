import SwiftUI
import PhotosUI
import SwiftData

struct PhotoPickerView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var checklists: [DailyChecklist]
    
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var showingError = false
    @State private var errorMessage = ""
    
    var body: some View {
        VStack {
            if let selectedImage {
                Image(uiImage: selectedImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 300)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            
            PhotosPicker(selection: $selectedItem,
                        matching: .images,
                        photoLibrary: .shared()) {
                Label("Select Photo", systemImage: "photo")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .onChange(of: selectedItem) { _, newValue in
                Task {
                    if let data = try? await newValue?.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        selectedImage = image
                        await savePhoto(image)
                    }
                }
            }
        }
        .padding()
        .alert("Error", isPresented: $showingError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }
    
    private func savePhoto(_ image: UIImage) async {
        do {
            let today = Calendar.current.startOfDay(for: Date())
            try PhotoManager.shared.savePhoto(image, for: today)
            
            // Update the checklist
            if let checklist = checklists.first(where: { Calendar.current.isDate($0.date, inSameDayAs: today) }) {
                checklist.photoTaken = true
            } else {
                let newChecklist = DailyChecklist(date: today, photoTaken: true)
                modelContext.insert(newChecklist)
            }
            
            try modelContext.save()
        } catch {
            errorMessage = error.localizedDescription
            showingError = true
        }
    }
} 