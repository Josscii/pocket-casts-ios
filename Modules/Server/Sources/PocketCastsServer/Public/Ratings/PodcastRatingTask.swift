import Foundation
import PocketCastsDataModel

public struct PodcastRating: Codable {
    public let total: Int
    public let average: Double
}

public struct PodcastRatingTask {
    private let session: URLSession

    public init(session: URLSession = .shared) {
        self.session = session
    }

    /// Retrieves the star rating and total for a single podcast
    public func retrieve(for podcastUuid: String) async throws -> PodcastRating? {
        let urlString = "\(ServerConstants.Urls.cache())podcast/rating/\(podcastUuid)"
        let task = JSONDecodableURLTask<PodcastRating>(session: session)

        return try await task.get(urlString: urlString)
    }
}
