//
//  Message.swift
//  Integrate Supabase
//
//  Created by Marcus Buexenstein on 2023/12/13.
//

import Foundation

struct Message: Identifiable {
    let id: UUID
    let profileID: UUID
    var content: String
    let createdAt: Date
    
    init(id: UUID = UUID(), content: String) {
        self.id = id
        self.profileID = UUID()
        self.content = content
        self.createdAt = Date()
    }
}

extension Message: Codable {
    enum CodingKeys: String, CodingKey {
        case id, profileID = "profile_id", content, createdAt = "created_at"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(self.content, forKey: .content)
    }
}

extension Message {
    init(dictionary: [String: Any]) throws {
        let decoder = JSONDecoder.postgrest
        
        self = try decoder.decode(Message.self, from: JSONSerialization.data(withJSONObject: dictionary))
    }
}

extension JSONDecoder {
  static let postgrest = { () -> JSONDecoder in
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .custom { decoder in
      let container = try decoder.singleValueContainer()
      let string = try container.decode(String.self)

      for formatter in supportedDateFormatters {
        if let date = formatter.date(from: string) {
          return date
        }
      }

      throw DecodingError.dataCorruptedError(
        in: container, debugDescription: "Invalid date format: \(string)"
      )
    }
    return decoder
  }()
}
