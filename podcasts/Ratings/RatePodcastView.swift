import SwiftUI
import PocketCastsDataModel

struct RatePodcastView: View {
    @ObservedObject var viewModel: RatePodcastViewModel

    @EnvironmentObject var theme: Theme

    // Avoid the rate view from flickering
    @State private var rateRendered = false

    init(viewModel: RatePodcastViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            VStack {
                Spacer()
                content
                Spacer()
                button
            }

            Image("close")
                .renderingMode(.template)
                .foregroundStyle(theme.primaryText01)
                .buttonize {
                    viewModel.dismiss()
                }
        }
        .alert(isPresented: $viewModel.anErrorOccurred) {
            errorAlert
        }
        .frame(maxWidth: .infinity)
        .padding()
        .applyDefaultThemeOptions()
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.userCanRate {
        case .checking:
            ProgressView()
                .tint(theme.primaryText01)
                .controlSize(.large)
        case .allowed:
            rate
                .opacity(rateRendered ? 1 : 0)
        case .disallowed:
            cannotRate
        }
    }

    @ViewBuilder
    private var cannotRate: some View {
        cover
        Text(L10n.ratingListenToThisPodcastTitle)
            .font(size: 20, style: .title3, weight: .bold)
            .padding(.bottom, 16)
        Text(L10n.ratingListenToThisPodcastMessage)
            .font(style: .body)
            .multilineTextAlignment(.center)
    }

    @ViewBuilder
    private var rate: some View {
        cover
        Text(L10n.ratingTitle(viewModel.podcast.title ?? ""))
            .font(size: 20, style: .title3, weight: .bold)
            .padding(.bottom, 16)
            .multilineTextAlignment(.center)
        ContentSizeGeometryReader(content: { reader in
            HStack {
                ForEach(0..<Constants.maxStars, id: \.self) { index in
                    let currentStar = viewModel.stars - Double(index)

                    Group {
                        if currentStar > 0 {
                            Image("star-full")
                                .resizable()
                                .renderingMode(.template)
                        } else {
                            Image("star")
                                .resizable()
                                .renderingMode(.template)
                        }
                    }
                    .foregroundStyle(theme.primaryText01)
                    .frame(width: 36, height: 36)
                    .padding(4)
                    .onTapGesture {
                        viewModel.stars = Double(index) + 1
                    }
                }
            }
            .highPriorityGesture(
                DragGesture()
                    .onChanged { gesture in
                        var starValue = (gesture.location.x * 5) / reader.size.width
                        starValue = (starValue * 2).rounded() / 2
                        viewModel.stars = max(1, min(5, starValue.rounded()))
                    }
            )
        }, contentSizeUpdated: { _ in
            rateRendered = true
        })
    }

    private var button: some View {
        Button(action: {
            viewModel.buttonAction()
        }, label: {
            if viewModel.isSubmitting {
                ProgressView()
                    .tint(theme.primaryInteractive02)
            } else {
                Text(viewModel.buttonLabel)
            }
        })
        .buttonStyle(BasicButtonStyle(textColor: theme.primaryInteractive02, backgroundColor: theme.primaryText01))
        .disabled(!viewModel.isButtonEnabled)
        .opacity(viewModel.buttonOpacity)
    }

    private var errorAlert: Alert {
        Alert(
            title: Text(L10n.ratingError),
            message: Text(L10n.pleaseTryAgain),
            dismissButton: .default(Text(L10n.ok))
        )
    }

    private var cover: some View {
        PodcastCover(podcastUuid: viewModel.podcast.uuid, big: true)
            .frame(width: 164, height: 164)
            .padding(.bottom, 40)
    }

    enum Constants {
        static let maxStars = 5
    }
}

#Preview {
    RatePodcastView(viewModel: RatePodcastViewModel(presented: .constant(true), dismissAction: .constant(.default), podcast: Podcast.previewPodcast()))
        .environmentObject(Theme.sharedTheme)
}
