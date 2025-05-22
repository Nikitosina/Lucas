import Hummingbird
import Foundation

func buildApplication(configuration: ApplicationConfiguration) -> some ApplicationProtocol {
    let router = Router()

    router.get("/") { _, _ in
        return "Lucas API - Localization Keyset Manager"
    }

    router.get("/keysets/:keysetId", use: getKeysetHandler)
//    router.post("/keysets/:path/objects", use: addObjectHandler)
//    router.delete("/keysets/:path/objects/:key", use: removeObjectHandler)
//    router.put("/keysets/:path/objects/:key", use: editObjectHandler)

    let app = Application(
        router: router,
        configuration: configuration
    )
    return app
}

func keyset(by id: String) throws -> Keyset {
    let keysetURL = URL(filePath: #filePath)
        .deletingLastPathComponent()
        .appending(component: "keysets")
        .appending(component: "\(id).json")
    let keysetData = try Data(contentsOf: keysetURL)

    let keyset = try JSONDecoder().decode(Keyset.self, from: keysetData)
    return keyset
}

struct JSONResponse: Codable, ResponseEncodable {
    let json: [String: String]
}

// Add object handler
//func addObjectHandler(_ request: Request, context: any RequestContext) async throws -> Response {
//    struct AddObjectRequest: Codable {
//        let key: String
//        let defaultString: String
//        let translations: [LanguageCode: String]?
//    }
//
//    // Parse request body
//    let requestBody = try await request.decode(as: AddObjectRequest.self, context: context)
//
//    // Get path parameter
//    guard let keysetPath = request.uri.queryParameters.get("path") else {
//        throw HTTPError(.badRequest, message: "Missing keyset path")
//    }
//
//    // Load keyset
//    let keysetURL = URL(fileURLWithPath: keysetPath)
//    let keysetData = try Data(contentsOf: keysetURL)
//    var keyset = try JSONDecoder().decode(Keyset.self, from: keysetData)
//
//    // Check if object with this key already exists
//    guard !keyset.objects.contains(where: { $0.key == requestBody.key }) else {
//        throw HTTPError(.conflict, message: "Object with key '\(requestBody.key)' already exists")
//    }
//
//    // Create and add new object
//    let newObject = Keyset.Object(
//        key: requestBody.key,
//        defaultString: requestBody.defaultString,
//        translations: requestBody.translations ?? [:]
//    )
//
//    keyset.objects.append(newObject)
//
//    // Save updated keyset
//    let encoder = JSONEncoder()
//    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
//    let updatedData = try encoder.encode(keyset)
//    try updatedData.write(to: keysetURL)
//
//    return Response(status: .created)
//}

//// Remove object handler
//func removeObjectHandler(_ request: Request, context: any RequestContext) async throws -> Response {
//    // Get path parameters
//    guard let keysetPath = request.parameters.get("path") else {
//        throw HTTPError(.badRequest, message: "Missing keyset path")
//    }
//
//    guard let key = request.parameters.get("key") else {
//        throw HTTPError(.badRequest, message: "Missing object key")
//    }
//
//    // Load keyset
//    let keysetURL = URL(fileURLWithPath: keysetPath)
//    let keysetData = try Data(contentsOf: keysetURL)
//    var keyset = try JSONDecoder().decode(Keyset.self, from: keysetData)
//
//    // Find and remove object
//    let initialCount = keyset.objects.count
//    keyset.objects.removeAll(where: { $0.key == key })
//
//    guard initialCount != keyset.objects.count else {
//        throw HTTPError(.notFound, message: "Object with key '\(key)' not found")
//    }
//
//    // Save updated keyset
//    let encoder = JSONEncoder()
//    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
//    let updatedData = try encoder.encode(keyset)
//    try updatedData.write(to: keysetURL)
//
//    return Response(status: .ok, body: .init(string: "Object removed successfully"))
//}
//
//// Edit object handler
//func editObjectHandler(_ request: Request, context: any RequestContext) async throws -> Response {
//    struct EditObjectRequest: Codable {
//        let defaultString: String?
//        let translations: [Language: String]?
//    }
//
//    // Parse request body
//    let requestBody = try await request.decode(as: EditObjectRequest.self)
//
//    // Get path parameters
//    guard let keysetPath = request.parameters.get("path") else {
//        throw HTTPError(.badRequest, message: "Missing keyset path")
//    }
//
//    guard let key = request.parameters.get("key") else {
//        throw HTTPError(.badRequest, message: "Missing object key")
//    }
//
//    // Load keyset
//    let keysetURL = URL(fileURLWithPath: keysetPath)
//    let keysetData = try Data(contentsOf: keysetURL)
//    var keyset = try JSONDecoder().decode(Keyset.self, from: keysetData)
//
//    // Find object to edit
//    guard let objectIndex = keyset.objects.firstIndex(where: { $0.key == key }) else {
//        throw HTTPError(.notFound, message: "Object with key '\(key)' not found")
//    }
//
//    // Update object
//    if let newDefaultString = requestBody.defaultString {
//        keyset.objects[objectIndex].defaultString = newDefaultString
//    }
//
//    // Merge translations
//    if let newTranslations = requestBody.translations {
//        for (language, translation) in newTranslations {
//            keyset.objects[objectIndex].translations[language] = translation
//        }
//    }
//
//    // Save updated keyset
//    let encoder = JSONEncoder()
//    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
//    let updatedData = try encoder.encode(keyset)
//    try updatedData.write(to: keysetURL)
//
//    return Response(status: .ok, body: .init(string: "Object updated successfully"))
//}
