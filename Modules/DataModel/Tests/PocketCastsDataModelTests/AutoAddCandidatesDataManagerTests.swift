import XCTest
import FMDB
@testable import PocketCastsUtils
import SQLite3
@testable import PocketCastsDataModel

final class AutoAddCandidatesDataManagerTests: XCTestCase {

    private let featureFlagMock = FeatureFlagMock()

    private func setupDatabase() throws -> DataManager {
        let dbPath = (DataManager.pathToDbFolder() as NSString).appendingPathComponent("podcast_testDB.sqlite3")
        if FileManager.default.fileExists(atPath: dbPath) {
            try FileManager.default.removeItem(atPath: dbPath)
        }
        let flags = SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE | SQLITE_OPEN_FILEPROTECTION_NONE
        let dbQueue = try XCTUnwrap(FMDatabaseQueue(path: dbPath, flags: flags))
        return DataManager(dbQueue: dbQueue)
    }

    /// Tests new query and autoAddToUpNext property for UpNext candidates
    func testSyncableUpNextSetting() throws {
        featureFlagMock.set(.settingsSync, value: true)

        let dataManager = try setupDatabase()
        let newUpNextSetting = AutoAddToUpNextSetting.addFirst

        let podcast = Podcast()
        podcast.uuid = "1234"
        podcast.addedDate = Date()
        podcast.setAutoAddToUpNext(setting: newUpNextSetting)

        let episode = Episode()
        episode.uuid = "1234"
        episode.addedDate = Date()
        episode.podcastUuid = podcast.uuid

        dataManager.save(podcast: podcast)
        dataManager.save(episode: episode)
        dataManager.autoAddCandidates.add(podcastUUID: podcast.uuid, episodeUUID: episode.uuid)

        let candidates = dataManager.autoAddCandidates.candidates()

        let matchingCandidate = candidates.first(where: { $0.episodeUuid == episode.uuid })
        XCTAssertNotNil(matchingCandidate, "Episode should appear in Up Next candidates")
        XCTAssertEqual(matchingCandidate?.autoAddToUpNextSetting, newUpNextSetting)

        featureFlagMock.reset()
    }

    /// Tests old query and autoAddToUpNext property for UpNext candidates
    func testOldUpNextSetting() throws {
        featureFlagMock.set(.settingsSync, value: false)

        let dataManager = try setupDatabase()
        let newUpNextSetting = AutoAddToUpNextSetting.addFirst

        let podcast = Podcast()
        podcast.uuid = "1234"
        podcast.addedDate = Date()
        podcast.setAutoAddToUpNext(setting: newUpNextSetting)

        let episode = Episode()
        episode.uuid = "1234"
        episode.addedDate = Date()
        episode.podcastUuid = podcast.uuid

        dataManager.save(podcast: podcast)
        dataManager.save(episode: episode)
        dataManager.autoAddCandidates.add(podcastUUID: podcast.uuid, episodeUUID: episode.uuid)

        let candidates = dataManager.autoAddCandidates.candidates()

        let matchingCandidate = candidates.first(where: { $0.episodeUuid == episode.uuid })
        XCTAssertNotNil(matchingCandidate, "Episode should appear in Up Next candidates")
        XCTAssertEqual(matchingCandidate?.autoAddToUpNextSetting, newUpNextSetting)

        featureFlagMock.reset()
    }


}
