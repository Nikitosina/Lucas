import Foundation

// MARK: - String Extensions

extension String {
    /// Returns true if this string contains any digits or the special
    /// characters ':', '/', '\', '&', '#'.
    var containsNumbersOrSpecials: Bool {
        let disallowedChars = CharacterSet(charactersIn: "0123456789:/\\&#")
        // rangeOfCharacter(from:) returns nil if no disallowed characters are found
        return self.rangeOfCharacter(from: disallowedChars) != nil
    }

    /// Convert this string to a lower_snake_case version suitable for keys.
    /// Naive approach:
    ///  • Replace any non-alphanumeric run with underscores.
    ///  • Lowercase the result.
    ///  • Convert multiple underscores to a single underscore.
    ///  • Trim leading/trailing underscores.
    var toSnakeCase: String {
        // 1) Replace runs of non-alphanumeric with underscores
        let pattern = "[^a-zA-Z0-9]+"
        let regex = try? NSRegularExpression(pattern: pattern)
        let range = NSRange(location: 0, length: self.utf16.count)
        let intermediate =
            regex?.stringByReplacingMatches(
                in: self,
                options: [],
                range: range,
                withTemplate: "_"
            ) ?? self

        // 2) Convert to lowercase
        let lower = intermediate.lowercased()

        // 3) Collapse multiple underscores into one
        let pattern2 = "_+"
        let regex2 = try? NSRegularExpression(pattern: pattern2)
        let range2 = NSRange(location: 0, length: lower.utf16.count)
        let collapsed =
            regex2?.stringByReplacingMatches(
                in: lower,
                options: [],
                range: range2,
                withTemplate: "_"
            ) ?? lower

        // 4) Trim leading/trailing underscores
        return collapsed.trimmingCharacters(in: CharacterSet(charactersIn: "_"))
    }
}

// MARK: - Helpers

func allSwiftFiles(in directory: URL) -> [URL] {
    var result: [URL] = []
    if let enumerator = FileManager.default.enumerator(
        at: directory,
        includingPropertiesForKeys: nil,
        options: [.skipsHiddenFiles],
        errorHandler: nil)
    {
        for case let fileURL as URL in enumerator {
            if fileURL.pathExtension == "swift" {
                result.append(fileURL)
            }
        }
    }
    return result
}

func extractQuotedStrings(from content: String) -> [String] {
    // Matches any sequence of characters between two double quotes
    // (including escaped characters like \" if needed). This is a basic pattern
    // and may not handle advanced corner cases like multiline or interpolated strings.
    let pattern = #""((?:[^"\\]|\\.)*)""#

    guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
        return []
    }

    let nsString = content as NSString
    let results = regex.matches(
        in: content, options: [], range: NSRange(location: 0, length: nsString.length))

    return results.map { match -> String in
        // Capture group 1 is the substring within the quotes
        let range = match.range(at: 1)
        return nsString.substring(with: range)
    }
}

// MARK: - Main

// 1) Check Command-Line Arguments
let arguments = CommandLine.arguments
guard arguments.count >= 2 else {
    print("Usage: \(arguments.first ?? "extract_strings.swift") <directory_to_scan>")
    exit(1)
}

// 2) Get the Target Directory
let targetDirectory = URL(fileURLWithPath: arguments[1], isDirectory: true)

// 3) Collect All .swift Files Recursively
print("Scanning \(targetDirectory.path) for .swift files...")
let swiftFiles = allSwiftFiles(in: targetDirectory)

// 4) Extract and Collect Strings, skipping those with digits or disallowed chars
var uniqueStrings = Set<String>()

for fileURL in swiftFiles {
    guard let content = try? String(contentsOf: fileURL, encoding: .utf8) else { continue }
    let foundStrings = extractQuotedStrings(from: content)

    // Filter out strings that contain digits or : / \ & #
    let filtered = foundStrings.filter { !$0.containsNumbersOrSpecials }
    filtered.forEach { uniqueStrings.insert($0) }
}

// 5) Build the .strings file content
//    • The “keys” become lower_snake_case versions of the string
//    • The “values” remain the original string
let stringsContent =
    uniqueStrings
    .sorted()
    .map { original -> String in
        let key = original.toSnakeCase
        // "key" = "original";
        return "\"\(key)\" = \"\(original)\";"
    }
    .joined(separator: "\n")

// 6) Write Out to Localizable.strings in the current folder
let outputURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    .appendingPathComponent("Localizable.strings")

do {
    try stringsContent.write(to: outputURL, atomically: true, encoding: .utf8)
    print(
        """
        Done! Strings extracted and written to:
        \(outputURL.path)
        - Skipped strings containing digits or :/\\&#
        - Keys are now in lower_snake_case
        """)
} catch {
    print("Error writing .strings file: \(error.localizedDescription)")
    exit(1)
}

