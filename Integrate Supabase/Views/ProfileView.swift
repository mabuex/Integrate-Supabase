//
//  ProfileView.swift
//  Integrate Supabase
//
//  Created by Marcus Buexenstein on 2023/12/12.
//

import SwiftUI
import PhotosUI
import Supabase

struct ProfileView: View {
    let database = Database()
    let storage = Supabase.shared.client.storage
    
    @Environment(Auth.self) private var auth: Auth
    
    @State private var result: Result<Void, Error>?
    @State private var username: String = ""
    @State private var avatarImage: AvatarImage?
    @State private var imageSelection: PhotosPickerItem?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                if let result {
                    switch result {
                    case .success:
                        MessageBox("Profile has been updated", icon: "info.circle", type: .information) {
                            withAnimation {
                                self.result = nil
                            }
                        }
                    case .failure(let failure):
                        MessageBox(failure.localizedDescription) {
                            withAnimation {
                                self.result = nil
                            }
                        }
                    }
                }
                
                VStack(alignment: .leading, spacing: 15) {
                    profilePicture()
                    
                    CustomTextField(title: "Username", text: $username, contentType: .username)
                    
                    Spacer()
                    
                    CustomButton(title: "Save Profile") {
                        save()
                    }
                    .opacity(username.isEmpty ? 0.5 : 1.0)
                    .disabled(username.isEmpty)
                }
                .padding()
            }
            .background(Color.brandBackground)
            .navigationTitle("Profile")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Sign Out") {
                        signOut()
                    }
                    .tint(Color.brandPrimary)
                }
            }
            .onAppear {
                username = auth.profile?.username ?? ""
                avatarImage = auth.profile?.avatarImage
                
                if let avatarURL = auth.profile?.avatarURL, !avatarURL.isEmpty, auth.profile?.avatarImage == nil {
                    Task {
                        try await downloadImage(path: avatarURL)
                    }
                }
            }
            .onChange(of: imageSelection) { _, newValue in
                guard let newValue else { return }
                loadTransferable(from: newValue)
            }
        }
    }
}

#Preview {
    NavigationStack {
        ProfileView()
            .environment(Auth())
    }
}

extension ProfileView {
    func signOut() {
        Task {
            do {
                try await auth.signOut()
            } catch {
                withAnimation {
                    result = .failure(error)
                }
            }
        }
    }
    
    func save() {
        guard !username.isEmpty, let profile = auth.profile else { return }
        
        Task {
            profile.username = username
            profile.avatarURL = try await uploadImage()
        
            do {
                let resultProfile = try await database.update(.profiles, values: profile)
                
                auth.profile?.username = resultProfile.username
                auth.profile?.avatarURL = resultProfile.avatarURL
                
                withAnimation {
                    result = .success(())
                }
            } catch {
                withAnimation {
                    result = .failure(error)
                }
            }
        }
    }
    
    // Copied from Guilherme Souza Supabase Example
    // https://github.com/supabase-community/supabase-swift/blob/main/Examples/UserManagement/ProfileView.swift
    private func loadTransferable(from imageSelection: PhotosPickerItem) {
        Task {
            do {
                avatarImage = try await imageSelection.loadTransferable(type: AvatarImage.self)
            } catch {
                debugPrint(error)
            }
        }
    }
    
    private func downloadImage(path: String) async throws {
        let data = try await storage.from("avatars").download(path: path)
        avatarImage = AvatarImage(data: data)
        auth.profile?.avatarImage = avatarImage
    }
    
    private func uploadImage() async throws -> String? {
        guard let data = avatarImage?.data else { return nil }
        
        let filePath = "\(UUID().uuidString).jpeg"
        
        try await storage
            .from("avatars")
            .upload(
                path: filePath,
                file: data,
                options: FileOptions(contentType: "image/jpeg")
            )
        
        return filePath
    }
}

extension ProfileView {
    @ViewBuilder
    func profilePicture() -> some View {
        ZStack(alignment: .bottomTrailing) {
            if let avatarImage {
                avatarImage.image
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
            } else {
                PlaceholderAvatar(size: 100)
            }
            
            PhotosPicker(
                selection: $imageSelection,
                matching: .images,
                photoLibrary: .shared()) {
                    Circle()
                        .frame(width: 40, height: 40)
                        .foregroundColor(Color.brandPrimary)
                        .overlay {
                            Image(systemName: "camera.fill")
                                .resizable()
                                .frame(width: 15, height: 12)
                                .foregroundColor(.white)
                        }
                        .offset(x: 5, y: 5)
                }
        }
        .padding(.bottom)
        .frame(maxWidth: .infinity, alignment: .center)
    }
}
