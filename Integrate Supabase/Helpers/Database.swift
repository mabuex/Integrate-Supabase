//
//  Database.swift
//  Integrate Supabase
//
//  Created by Marcus Buexenstein on 2023/12/12.
//

import Foundation

final class Database {
    private let database = Supabase.shared.client.database
    
    // MARK: Insert
    func insert<T: Codable> (_ table: DatabaseTable, values: T) async throws -> T {
        return try await database
            .from(table.rawValue)
            .insert(values, returning: .representation)
            .single()
            .execute()
            .value as T
    }
    
    // MARK: Fetch
    func fetch<T: Decodable>(_ table: DatabaseTable) async throws -> T {
        try await database
            .from(table.rawValue)
            .select()
            .execute()
            .value as T
    }
    
    // MARK: Update
    func update<T: Codable>(_ table: DatabaseTable, values: T) async throws -> T where T: Identifiable {
        guard let id = values.id as? UUID else { throw DatabaseError.missingId }
        
        return try await database
            .from(table.rawValue)
            .update(values, returning: .representation)
            .eq("id", value: id)
            .single()
            .execute()
            .value as T
    }
    
    // MARK: Delete
    func delete<T: Encodable>(_ table: DatabaseTable, values: T) async throws where T: Identifiable {
        guard let id = values.id as? UUID else { throw DatabaseError.missingId }
        
        try await database
            .from(table.rawValue)
            .delete()
            .eq("id", value: id)
            .execute()
    }
}

extension Database {
    enum DatabaseError: Error, LocalizedError {
        case missingId
        
        var errorDescription: String? {
            switch self {
            case .missingId:
                return "UUID is missing"
            }
        }
    }
}


