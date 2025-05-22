//
//  Keyset+Get.swift
//  Lucas
//
//  Created by Nikita Ratashnyuk on 22.05.2025.
//

import Foundation
import Hummingbird

// Get keyset handler
func getKeysetHandler(_ request: Request, context: any RequestContext) async throws -> Response {
    guard let keysetId = context.parameters.get("keysetId") else {
        throw HTTPError(.badRequest, message: "Missing keyset path")
    }

    var format: KeysetFormat?
    if let formatRaw = request.uri.queryParameters.get("format") {
        format = KeysetFormat(rawValue: formatRaw)
    }

    let encoder = JSONEncoder()
    do {
        let keyset = try keyset(by: keysetId)
        let responseData: Data
        if format == .iOS {
            responseData = try encoder.encode(keyset.toiOSLocalizable())
        } else {
            responseData = try encoder.encode(keyset)
        }
        return Response(status: .ok, body: ResponseBody(byteBuffer: ByteBuffer(data: responseData)))
    } catch {
        print(error)
        throw HTTPError(.internalServerError, message: "Failed to decode keyset data")
    }
}
