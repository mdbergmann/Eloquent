import AppIntents
import Foundation
import AppKit


// MARK: - App Shortcuts Provider
struct EloquentSearchShortcuts: AppShortcutsProvider {
    static var shortcutTileColor: ShortcutTileColor = .yellow
    @AppShortcutsBuilder
    static var appShortcuts: [AppShortcut] {
            AppShortcut(
                intent: SearchPassageIntent(),
                phrases: [
                    "\(.applicationName) return passage"
                ],
                shortTitle: "Search",
                systemImageName: "text.magnifyingglass"
            )
    }
}

// MARK: - App Shortcuts Provider
/*struct EloquentOpenShortcuts: AppShortcutsProvider {
    static var shortcutTileColor: ShortcutTileColor = .yellow
    @AppShortcutsBuilder
    static var appShortcuts: [AppShortcut] {
            AppShortcut(
                intent: OpenPassageIntent(),
                phrases: [
                    "Open passage in \(.applicationName)"
                ],
                shortTitle: "Open Passage",
                systemImageName: "book"
            )
    }
}*/
// MARK: - Search Intent
struct SearchPassageIntent: AppIntent {
    
    static var title: LocalizedStringResource = "Search for Passage"
    static var description = IntentDescription(
        "Searches Eloquent for a scripture referenece in an optional translation, returning a text result."
    )

    @Parameter(title: "Reference", requestValueDialog: "What passage would you like to search for?")
    var reference: String

    @Parameter(title: "Translation", requestValueDialog: "Which translation would you like to use?")
    var translation: String?

    static var parameterSummary: some ParameterSummary {
        Summary("Search \(\.$reference)") {
            \.$translation
        }
    }

    static var openAppWhenRun: Bool = false

    func perform() async throws -> some IntentResult & ReturnsValue<String> {
        let resolvedVersion = translation?.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        let usedVersion: String? = (resolvedVersion?.isEmpty == false) ? resolvedVersion! : nil

        // Bridge to Objective-C search manager (synchronous stub for now).
        do {
            let text = try SearchManager.shared().search(
                for: reference,
                inVersion: usedVersion
            )
            return .result(value: text)
        } catch {
            // Return a friendly error string instead of throwing to the caller.
            let versionSuffix = usedVersion.map { " in \($0)" } ?? ""
            let message = "Sorry, I couldn’t complete the search for ‘\(reference)’\(versionSuffix): \(error.localizedDescription)"
            return .result(value: message)
        }
    }
}

// MARK: - Open Passage Intent
struct OpenPassageIntent: AppIntent {
    static var title: LocalizedStringResource = "Open Passage"
    static var description = IntentDescription("Opens a passage in the app and returns a short confirmation string.")

    @Parameter(title: "Reference", requestValueDialog: "Which passage?")
    var reference: String

    @Parameter(title: "Version")
    var translation: String?

    static var openAppWhenRun: Bool = true

    static var parameterSummary: some ParameterSummary {
        Summary("Open \(\.$reference)") {
            \.$translation
        }
    }

    func perform() async throws -> some IntentResult & ReturnsValue<String> {
        SearchManager.shared().openPassage(reference, version: translation)
        let suffix = (translation?.isEmpty == false) ? " in \(translation!)" : ""
        return .result(value: "Opened \(reference)\(suffix)")
    }
}

