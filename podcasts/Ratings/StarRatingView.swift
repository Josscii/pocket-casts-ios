import SwiftUI
import PocketCastsUtils
import PocketCastsServer

struct StarRatingView: View {
    @EnvironmentObject var theme: Theme
    @ObservedObject var viewModel: PodcastRatingViewModel

    @State private var dismissAction: RatePodcastViewModel.DismissAction = .default

    /// Keeps track of when we appear to determine if we should animate
    private var startDate: Date = .now

    /// Only animate in if there's a rating and enough time has passed since appearing
    /// If the value is being loaded from cache it will display async but faster than
    /// if it was loaded fro the server, so this avoids a weird fade that could happen
    private var shouldAnimate: Bool {
        viewModel.rating != nil && Date().timeIntervalSince(startDate) > Constants.minTimeBeforeAnimating
    }

    init(viewModel: PodcastRatingViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        if FeatureFlag.giveRatings.enabled {
            starsAndRate
        } else {
            onlyStars
        }
    }

    /// A view that returns stars and the "Rate" button
    var starsAndRate: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center) {
                ratingView(rating: viewModel.rating)
                    .frame(height: 16)
                    .animation(.easeIn(duration: Constants.animationDuration), value: shouldAnimate)

                Spacer()

                Text(L10n.rate)
                    .font(.system(.callout))
                    .foregroundStyle(theme.primaryText01)
                    .buttonize {
                        viewModel.didTapRating()
                    }
            }
            .sheet(isPresented: $viewModel.presentingGiveRatings, onDismiss: {
                switch dismissAction {
                case .dismissAndTracking(let event):
                    Analytics.shared.track(event)
                default:
                    break
                }
                dismissAction = .default
            }, content: {
                if let podcast = viewModel.podcast {
                    RatePodcastView(viewModel: RatePodcastViewModel(presented: $viewModel.presentingGiveRatings, dismissAction: $dismissAction, podcast: podcast))
                }
            })

            Rectangle()
                .foregroundStyle(theme.primaryUi05)
                .frame(height: 1)
                .padding(.top, 12)
                .padding(.bottom, 0)
        }
    }

    // A view that returns only the stars
    var onlyStars: some View {
        HStack(alignment: .center) {
            ratingView(rating: viewModel.rating)
                .animation(.easeIn(duration: Constants.animationDuration), value: shouldAnimate)

            Spacer()
        }
        .frame(height: 15)
    }

    @ViewBuilder
    private func ratingView(rating: PodcastRating?) -> some View {
        starsView(rating: rating?.average ?? 0)
        labelView(rating: rating)
    }

    @ViewBuilder
    private func labelView(rating: PodcastRating?) -> some View {
        let defaultColor = AppTheme.color(for: .primaryText01, theme: theme)
        Group {
            if !FeatureFlag.giveRatings.enabled {
                Text("(\(rating?.total.abbreviated ?? ""))")
                    .font(size: 14, style: .footnote)
            } else {
                if let rating, viewModel.hasRatings {
                    Text("\(rating.average, specifier: "%.1f")")
                        .font(size: 14, style: .footnote, weight: .semibold)
                        .padding([.leading], -2)
                    Text("(\(rating.total.abbreviated))")
                        .font(size: 14, style: .footnote)
                        .padding([.leading], -2)
                } else {
                    Text(L10n.ratingNoRatings)
                        .font(size: 14, style: .footnote)
                }
            }
        }
        .foregroundColor(defaultColor)
        .padding(.top, 1)
        .monospacedDigit()
    }

    @ViewBuilder
    private func starsView(rating: Double) -> some View {
        // truncate the floating points off without rounding
        let stars = Int(rating)
        // Get the float value
        let half = rating.truncatingRemainder(dividingBy: 1)
        let themeStyle = FeatureFlag.giveRatings.enabled ? ThemeStyle.primaryUi05Selected : ThemeStyle.filter03
        let color = AppTheme.color(for: themeStyle, theme: theme)

        HStack(spacing: 3) {
            ForEach(0..<Constants.maxStars, id: \.self) { index in
                image(for: index, stars: stars, half: half)
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(color)
            }
        }.foregroundColor(color)
    }

    private func image(for index: Int, stars: Int, half: Double) -> Image {
        if index < stars {
            return Constants.filled
        }

        if index > stars || half < 0.5 {
            return Constants.empty
        }

        return Constants.half
    }

    private enum Constants {
        /// How many total stars we want to show
        static let maxStars = 5

        // Star Images
        static let filled = Image("star-full")
        static let empty = Image("star")
        static let half = Image("star-half")

        static let minTimeBeforeAnimating: TimeInterval = 0.2
        static let animationDuration: TimeInterval = 0.1
    }
}
