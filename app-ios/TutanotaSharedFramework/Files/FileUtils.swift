import Foundation

public let FILES_ERROR_DOMAIN = "tutanota_files"
let SHARED_CONTENT_DIRNAME = "shared-content"
let ENCRYPTED_DIRNAME = "encrypted"
let DECRYPTED_DIRNAME = "decrypted"

public class FileUtils {

	/// temporary storage for encrypted files after download or before upload
	/// - Returns path to folder with encrypted content
	public static func getEncryptedFolder() throws -> String { try Self.makeTempDir(name: ENCRYPTED_DIRNAME) }

	/// temporary storage for decrypted files before displaying them or encrypting them
	/// - Returns path to folder with decrypted content
	public static func getDecryptedFolder() throws -> String { try Self.makeTempDir(name: DECRYPTED_DIRNAME) }

	public static func deleteFile(path: URL) throws { try FileManager.default.removeItem(at: path) }

	/// deletes the shared-content folder in the shared app group container recursively,
	/// removing any files that were copied there after bering shared by another app
	public static func deleteSharedStorage() throws {
		let sharedDir = try getAppGroupFolder()
		try FileManager.default.removeItem(at: sharedDir.appendingPathComponent(SHARED_CONTENT_DIRNAME))
		TUTSLog("deleted shared storage")
	}

	/// deletes a specific folder in the shared-content folder in the shared app group container recursively,
	/// removing any files that were copied there after bering shared by another app
	public static func deleteSharedStorage(subDir: String) throws {
		let sharedDir = try getAppGroupFolder()
		let dirToDelete = sharedDir.appendingPathComponent(SHARED_CONTENT_DIRNAME).appendingPathComponent(subDir)
		try FileManager.default.removeItem(atPath: dirToDelete.path)
		TUTSLog("deleted shared storage at \(sharedDir)")
	}
	public static func getApplicationSupportFolder() throws -> URL {
		let appSupportDirURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).last
		guard let appSupportDirURL else {
			throw TUTErrorFactory.createError(withDomain: FILES_ERROR_DOMAIN, message: "could not get application support directory URL")
		}
		try FileManager.default.createDirectory(at: appSupportDirURL, withIntermediateDirectories: true, attributes: nil)
		return appSupportDirURL
	}

	/// returns a path to a newly created (if nonexsistent) subdirectory in
	/// the shared storage for the app group, shared with the share extension
	static func ensureSharedStorage(inSubdir subdir: String) throws -> URL {
		let sharedDir = try getAppGroupFolder()
		let sharedSubdir = sharedDir.appendingPathComponent(SHARED_CONTENT_DIRNAME).appendingPathComponent(subdir)
		try FileManager.default.createDirectory(atPath: sharedSubdir.path, withIntermediateDirectories: true, attributes: nil)
		return sharedSubdir
	}

	static func getAppGroupFolder() throws -> URL {
		guard let sharedDir = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: getAppGroupName()) else {
			throw TUTErrorFactory.createError(withDomain: FILES_ERROR_DOMAIN, message: "could not get app group shared storage")
		}
		return sharedDir
	}

	/// check if the given path points to a file on the file system.
	/// the path must be an absolute path, not a file URL with file:// protocol.
	public static func fileExists(atPath path: String) -> Bool { FileManager.default.fileExists(atPath: path) }

	private static func makeTempDir(name: String) throws -> String {
		let encryptedFolderPath = (NSTemporaryDirectory() as NSString).appendingPathComponent(name)
		try FileManager.default.createDirectory(atPath: encryptedFolderPath, withIntermediateDirectories: true, attributes: nil)
		return encryptedFolderPath
	}
}
