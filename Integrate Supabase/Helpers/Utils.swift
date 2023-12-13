//
//  Utils.swift
//  Integrate Supabase
//
//  Created by Marcus Buexenstein on 2023/12/13.
//

import Foundation

import Foundation

let supportedDateFormatters: [ISO8601DateFormatter] = [
  { () -> ISO8601DateFormatter in
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    return formatter
  }(),
  { () -> ISO8601DateFormatter in
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime]
    return formatter
  }(),
]
