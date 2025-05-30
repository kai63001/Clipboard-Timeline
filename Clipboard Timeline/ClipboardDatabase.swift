import Foundation
import SQLite3

class ClipboardDatabase: ObservableObject {
    static let shared = ClipboardDatabase()
    @Published var clipboardItems: [ClipboardItem] = []

    private let dbPath: String = {
        let urls = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        )
        let dbURL = urls[0].appendingPathComponent(
            "ClipboardManager/clipboard.sqlite3"
        )
        return dbURL.path
    }()

    private var db: OpaquePointer?

    private init() {
        openDatabase()
        createTable()
    }

    private func createDirectoryIfNeeded(at url: URL) {
        let directory = url.deletingLastPathComponent()
        if !FileManager.default.fileExists(atPath: directory.path) {
            do {
                try FileManager.default.createDirectory(
                    at: directory,
                    withIntermediateDirectories: true,
                    attributes: nil
                )
                print("Created directory at \(directory.path)")
            } catch {
                print("Failed to create directory: \(error)")
            }
        }
    }

    private func openDatabase() {
        let dbURL = URL(fileURLWithPath: dbPath)
        createDirectoryIfNeeded(at: dbURL)
        if sqlite3_open(dbPath, &db) != SQLITE_OK {
            print("Failed to open database at \(dbPath)")
        } else {
            print("Database opened at \(dbPath)")
        }
    }

    private func createTable() {
        let createTableString = """
            CREATE TABLE IF NOT EXISTS clipboard_history (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                content TEXT,
                timestamp TEXT,
                app_name TEXT
            );
            """
        var createTableStatement: OpaquePointer?
        if sqlite3_prepare_v2(
            db,
            createTableString,
            -1,
            &createTableStatement,
            nil
        ) == SQLITE_OK {
            if sqlite3_step(createTableStatement) == SQLITE_DONE {
                print("Table created.")
            } else {
                print("Table not created.")
            }
        } else {
            print("CREATE TABLE statement could not be prepared.")
        }
        sqlite3_finalize(createTableStatement)
    }

    func addClipboardItem(content: String, appName: String?) {
        let insertStatementString =
            "INSERT INTO clipboard_history (content, timestamp, app_name) VALUES (?, datetime('now'), ?);"
        var insertStatement: OpaquePointer?
        if sqlite3_prepare_v2(
            db,
            insertStatementString,
            -1,
            &insertStatement,
            nil
        ) == SQLITE_OK {
            sqlite3_bind_text(
                insertStatement,
                1,
                (content as NSString).utf8String,
                -1,
                nil
            )
            if let appName = appName {
                sqlite3_bind_text(
                    insertStatement,
                    2,
                    (appName as NSString).utf8String,
                    -1,
                    nil
                )
            } else {
                sqlite3_bind_null(insertStatement, 2)
            }
            if sqlite3_step(insertStatement) == SQLITE_DONE {
                print("Successfully inserted row.")
                DispatchQueue.main.async {
                    self.clipboardItems = self.fetchClipboardItems()
                }
            } else {
                print("Could not insert row.")
            }
        } else {
            print("INSERT statement could not be prepared.")
        }
        sqlite3_finalize(insertStatement)
    }

    func fetchClipboardItems() -> [ClipboardItem] {
        let queryStatementString =
            "SELECT id, content, timestamp, app_name FROM clipboard_history ORDER BY timestamp DESC;"
        var queryStatement: OpaquePointer?
        var items: [ClipboardItem] = []
        if sqlite3_prepare_v2(
            db,
            queryStatementString,
            -1,
            &queryStatement,
            nil
        ) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                let id = sqlite3_column_int64(queryStatement, 0)
                let content = String(
                    cString: sqlite3_column_text(queryStatement, 1)
                )
                let timestamp = String(
                    cString: sqlite3_column_text(queryStatement, 2)
                )
                let appName = sqlite3_column_text(queryStatement, 3)
                let appNameString =
                    appName != nil ? String(cString: appName!) : nil

                let item = ClipboardItem(
                    id: id,
                    content: content,
                    timestamp: timestamp,
                    appName: appNameString
                )
                items.append(item)
            }
        } else {
            print("SELECT statement could not be prepared.")
        }
        sqlite3_finalize(queryStatement)
        return items
    }
}

struct ClipboardItem: Identifiable {
    let id: Int64
    let content: String
    let timestamp: String
    let appName: String?
}
