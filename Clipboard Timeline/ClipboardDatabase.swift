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
            "ClipboardTimeline/clipboard.sqlite3"
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
                app_name TEXT,
                app_bundle_id TEXT,
                record_id TEXT UNIQUE,
                synced INTEGER DEFAULT 0
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

    func checkDuplicate(content: String, appBundleId: String?)
        -> [ClipboardItem]
    {
        let checkDuplicate =
            "SELECT id, content, timestamp, app_name, app_bundle_id FROM clipboard_history WHERE content = ? AND app_bundle_id = ? ORDER BY id DESC LIMIT 10"
        var queryStatement: OpaquePointer?
        var items: [ClipboardItem] = []
        if sqlite3_prepare_v2(
            db,
            checkDuplicate,
            -1,
            &queryStatement,
            nil
        ) == SQLITE_OK {
            sqlite3_bind_text(
                queryStatement,
                1,
                (content as NSString).utf8String,
                -1,
                nil
            )
            if let appBundleId = appBundleId {
                sqlite3_bind_text(
                    queryStatement,
                    2,
                    (appBundleId as NSString).utf8String,
                    -1,
                    nil
                )
            } else {
                sqlite3_bind_null(queryStatement, 2)
            }
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
                let appBundleId = sqlite3_column_text(queryStatement, 4)
                let appBundleIdString =
                    appBundleId != nil ? String(cString: appBundleId!) : nil

                let item = ClipboardItem(
                    id: id,
                    content: content,
                    timestamp: timestamp,
                    appName: appNameString,
                    appBundleId: appBundleIdString
                )
                items.append(item)
            }
        } else {
            print("SELECT statement could not be prepared.")
        }
        sqlite3_finalize(queryStatement)

        return items
    }

    func deleteSelectedIDs(_ selectedIDs: [Int64]) {
        for id in selectedIDs {
            deleteClipboardItem(id: id)
        }
    }

    func deleteClipboardItem(id: Int64) {
        let deleteStatementString =
            "DELETE FROM clipboard_history WHERE id = ?;"
        var deleteStatement: OpaquePointer?
        if sqlite3_prepare_v2(
            db,
            deleteStatementString,
            -1,
            &deleteStatement,
            nil
        ) == SQLITE_OK {
            sqlite3_bind_int64(
                deleteStatement,
                1,
                id
            )
            if sqlite3_step(deleteStatement) == SQLITE_DONE {
                print("deleted duplicate row. succesfull \(id)")
                DispatchQueue.main.async {
                    self.clipboardItems = self.fetchClipboardItems()
                }
            } else {
                print("Could not delete row.")
            }
        } else {
            print("INSERT statement could not be prepared.")
        }
        sqlite3_finalize(deleteStatement)
    }

    func addClipboardItem(
        content: String,
        appName: String?,
        appBundleId: String?
    ) {
        // check duplicate last 10 if it duplicate remove and insert new
        let listDuplicate = checkDuplicate(
            content: content,
            appBundleId: appBundleId
        )
        print("List Duplicate: \(listDuplicate)")
        let listDuplicateID = listDuplicate.map({
            $0.id
        })
        deleteSelectedIDs(listDuplicateID)

        let insertStatementString =
            "INSERT INTO clipboard_history (content, timestamp, app_name, app_bundle_id, record_id) VALUES (?, datetime('now'), ?, ?, ?);"
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
            if let appBundleId = appBundleId {
                sqlite3_bind_text(
                    insertStatement,
                    3,
                    (appBundleId as NSString).utf8String,
                    -1,
                    nil
                )
            } else {
                sqlite3_bind_null(insertStatement, 3)
            }
            let recordId = UUID().uuidString
            sqlite3_bind_text(
                insertStatement,
                4,
                (recordId as NSString).utf8String,
                -1,
                nil
            )
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

    func fetchClipboardItems(type: String = "all") -> [ClipboardItem] {
        var query = ""
        if type == "today" {
            query =
                "SELECT id, content, timestamp, app_name, app_bundle_id FROM clipboard_history WHERE date(timestamp) = date('now', 'localtime') ORDER BY timestamp DESC;"
        } else if type == "yesterday" {
            query =
                "SELECT id, content, timestamp, app_name, app_bundle_id FROM clipboard_history WHERE date(timestamp) = date('now', '-1 day', 'localtime') ORDER BY timestamp DESC;"
        } else {
            query =
                "SELECT id, content, timestamp, app_name, app_bundle_id FROM clipboard_history ORDER BY timestamp DESC;"
        }

        var queryStatement: OpaquePointer?
        var items: [ClipboardItem] = []
        if sqlite3_prepare_v2(
            db,
            query,
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
                let appBundleId = sqlite3_column_text(queryStatement, 4)
                let appBundleIdString =
                    appBundleId != nil ? String(cString: appBundleId!) : nil

                let item = ClipboardItem(
                    id: id,
                    content: content,
                    timestamp: timestamp,
                    appName: appNameString,
                    appBundleId: appBundleIdString
                )
                items.append(item)
            }
        } else {
            print("SELECT statement could not be prepared.")
        }
        sqlite3_finalize(queryStatement)
        return items
    }

    func searchClipboardItems(content: String) -> [ClipboardItem] {
        let query =
            "SELECT id, content, timestamp, app_name, app_bundle_id FROM clipboard_history WHERE content LIKE ? ORDER BY timestamp DESC;"
        var searchStatement: OpaquePointer?
        var searchResults: [ClipboardItem] = []
        if sqlite3_prepare_v2(
            db,
            query,
            -1,
            &searchStatement,
            nil
        ) == SQLITE_OK {
            sqlite3_bind_text(
                searchStatement,
                1,
                (content as NSString).utf8String,
                -1,
                nil
            )
            while sqlite3_step(searchStatement) == SQLITE_ROW {
                let id = sqlite3_column_int64(searchStatement, 0)
                let content = String(
                    cString: sqlite3_column_text(searchStatement, 1)
                )
                let timestamp = String(
                    cString: sqlite3_column_text(searchStatement, 2)
                )
                let appName = sqlite3_column_text(searchStatement, 3)
                let appNameString =
                    appName != nil ? String(cString: appName!) : nil
                let appBundleId = sqlite3_column_text(searchStatement, 4)
                let appBundleIdString =
                    appBundleId != nil ? String(cString: appBundleId!) : nil

                let item = ClipboardItem(
                    id: id,
                    content: content,
                    timestamp: timestamp,
                    appName: appNameString,
                    appBundleId: appBundleIdString
                )
                
                searchResults.append(item)
            }
        } else {
            print("SELECT statement could not be prepared.")
        }
        sqlite3_finalize(searchStatement)
        
        return searchResults
    }
}

struct ClipboardItem: Identifiable {
    let id: Int64
    let content: String
    let timestamp: String
    let appName: String?
    let appBundleId: String?
}
