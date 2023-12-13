//
//  Profile.swift
//  Integrate Supabase
//
//  Created by Marcus Buexenstein on 2023/12/12.
//

import SwiftUI

final class Profile: Identifiable {
    let id: UUID
    var username: String
    var avatarURL: String?
    let createdAt: Date
    var avatarImage: AvatarImage? = nil
    
    init(id: UUID, username: String, avatarURL: String? = nil) {
        self.id = id
        self.username = username
        self.avatarURL = avatarURL
        self.createdAt = .now
    }
}

extension Profile: Codable {
    enum CodingKeys: String, CodingKey {
        case id, username, avatarURL = "avatar_url", createdAt = "created_at"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(self.username, forKey: .username)
        try container.encodeIfPresent(self.avatarURL, forKey: .avatarURL)
    }
}

extension Profile {
    static func instance(with profileID: UUID) async -> Self? {
        let database = Supabase.shared.client.database
        let table = DatabaseTable.profiles.rawValue
        
        do {
            let request: Self = try await database
                .from(table)
                .select()
                .eq("id", value: profileID)
                .single()
                .execute()
                .value
            
            return request
        } catch {
            return nil
        }
    }
}
