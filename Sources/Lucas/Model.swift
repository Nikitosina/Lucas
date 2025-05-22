import Hummingbird

typealias LanguageCode = String

struct Keyset: Codable, ResponseEncodable {
    struct Object: Codable, ResponseEncodable {
        var key: String
        var defaultString: String
        var translations: [LanguageCode: String]
    }

    var name: String
    var defaultLanguage: LanguageCode
    var languages: [LanguageCode]
    var objects: [Object]
}

enum KeysetFormat: String {
    case iOS = "ios"
}
