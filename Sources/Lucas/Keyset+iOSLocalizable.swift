//
//  Keyset+iOSLocalizable.swift
//  Lucas
//
//  Created by Nikita Ratashnyuk on 22.05.2025.
//

extension Keyset {
    func toiOSLocalizable() -> [String: String] {
        var localizableFiles: [String: String] = [:]

        // Add default language
        var defaultLanguageStrings = "/* \(name) - Default Language: \(defaultLanguage) */\n\n"
        for object in objects {
            defaultLanguageStrings += "/* \(object.key) */\n"
            defaultLanguageStrings += "\"\(object.key)\" = \"\(object.defaultString)\";\n\n"
        }
        localizableFiles[defaultLanguage] = defaultLanguageStrings

        // Add translations for each language
        for language in languages {
            if language == defaultLanguage { continue }

            var languageStrings = "/* \(name) - Language: \(language) */\n\n"
            for object in objects {
                let translation = object.translations[language] ?? object.defaultString
                languageStrings += "/* \(object.key) */\n"
                languageStrings += "\"\(object.key)\" = \"\(translation)\";\n\n"
            }
            localizableFiles[language] = languageStrings
        }

        return localizableFiles
    }
}
