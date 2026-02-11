//
//  PhotoInspectionView.swift
//  Lynk
//
//  Created by gülçin çetin on 10.02.2026.
//

import SwiftUI
import SwiftData
import PhotosUI

struct PhotoInspectionView: View {
    @Bindable var service: Service
    @Environment(\.modelContext) var modelContext
    
    @State private var selectedItem: PhotosPickerItem?
    @State private var showCamera = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // --- HEADER ---
                VStack {
                    Image(systemName: "camera.shutter.button.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(Color.lynkMint)
                        .padding()
                    
                    Text("Visual Evidence")
                        .font(.title2)
                        .bold()
                    Text("Take photos of scratches or pre-existing damage to protect yourself from liability.")
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)
                }
                .padding(.top)

                // --- ACTION BUTTONS ---
                HStack(spacing: 20) {
                    // 1. Take Photo (Real Camera)
                    Button(action: {
                        // In a real app, use UIViewControllerRepresentable for Camera
                        // For MVP, we'll use the Photo Picker
                        print("Camera tapped")
                    }) {
                        Label("Take Photo", systemImage: "camera")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundStyle(.white)
                            .cornerRadius(12)
                    }
                    
                    // 2. Upload from Gallery
                    PhotosPicker(selection: $selectedItem, matching: .images) {
                        Label("Upload", systemImage: "photo.on.rectangle")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .foregroundStyle(.primary)
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal)

                Divider()

                // --- EVIDENCE GRID ---
                if let photos = service.inspectionPhotos, !photos.isEmpty {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 15) {
                        ForEach(photos) { photo in
                            if let data = photo.photoData, let uiImage = UIImage(data: data) {
                                ZStack(alignment: .topTrailing) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 150, height: 150)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                    
                                    // Delete Button
                                    Button(action: {
                                        modelContext.delete(photo)
                                    }) {
                                        Image(systemName: "trash.circle.fill")
                                            .foregroundStyle(.red)
                                            .font(.title)
                                            .background(Circle().fill(.white))
                                    }
                                    .padding(5)
                                }
                            }
                        }
                    }
                    .padding()
                } else {
                    ContentUnavailableView("No Evidence Yet", systemImage: "photo.badge.plus", description: Text("Upload photos of the vehicle's condition."))
                }
            }
        }
        .navigationTitle("Inspection Photos")
        .onChange(of: selectedItem) { oldValue, newValue in
            Task {
                if let data = try? await newValue?.loadTransferable(type: Data.self) {
                    let newPhoto = InspectionPhoto(photoData: data, note: "Damage")
                    newPhoto.service = service
                    modelContext.insert(newPhoto)
                    selectedItem = nil // Reset
                }
            }
        }
    }
}
