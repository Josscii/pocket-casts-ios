import SwiftUI

struct UpgradeLandingView: View {
    let tiers: [UpgradeTier] = [.plus, .patron]
    var body: some View {
        ZStack {

            LinearGradient(gradient: Gradient(colors: [Color(hex: "121212"), Color(hex: "121212"), Color(hex: "D4B43A"), Color(hex: "FFDE64")]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()

            ScrollViewIfNeeded {
                VStack(spacing: 0) {
                    PlusLabel(L10n.plusMarketingTitle, for: .title2)
                        .padding(.bottom, 16)
                        .padding(.horizontal, 32)

                    UpgradeRoundedSegmentedControl()
                        .padding(.bottom, 24)

                    HorizontalCarousel(items: tiers) {
                        UpgradeCard(tier: $0)
                    }
                    .carouselPeekAmount(.constant(20))
                    .carouselItemSpacing(30)
                }
            }
        }
    }
}

struct UpgradeTier: Identifiable {
    let tier: Tier
    let iconName: String
    let title: String
    let price: String
    let description: String
    let features: [TierFeature]

    var id: String {
        tier.rawValue
    }

    enum Tier: String {
        case plus, patron
    }

    struct TierFeature: Hashable {
        let iconName: String
        let title: String
    }
}

extension UpgradeTier {
    static var plus: UpgradeTier {
        UpgradeTier(tier: .plus, iconName: "plusGold", title: "Plus", price: "$39.99", description: L10n.accountDetailsPlusTitle, features: [
            TierFeature(iconName: "plus-feature-desktop", title: L10n.plusMarketingDesktopAppsTitle),
            TierFeature(iconName: "plus-feature-folders", title: L10n.folders),
            TierFeature(iconName: "plus-feature-cloud", title: L10n.plusCloudStorageLimitFormat(10)),
            TierFeature(iconName: "plus-feature-watch", title: L10n.plusMarketingWatchPlaybackTitle),
            TierFeature(iconName: "plus-feature-extra", title: L10n.plusFeatureThemesIcons),
            TierFeature(iconName: "plus-feature-love", title: L10n.plusFeatureGratitude)
        ])
    }

    static var patron: UpgradeTier {
        UpgradeTier(tier: .patron, iconName: "patron-heart", title: "Patron", price: "$99.99", description: "Become a Pocket Casts Patron and help us continue to deliver the best podcasting experience available.", features: [
            TierFeature(iconName: "patron-everything", title: "Everything in Plus"),
            TierFeature(iconName: "patron-early-access", title: "Early access to features"),
            TierFeature(iconName: "plus-feature-cloud", title: L10n.plusCloudStorageLimitFormat(50)),
            TierFeature(iconName: "patron-badge", title: "Supporters profile badge"),
            TierFeature(iconName: "patron-icons", title: "Special Pocket Casts app icons"),
            TierFeature(iconName: "plus-feature-love", title: L10n.plusFeatureGratitude)

        ])
    }
}

struct UpgradeRoundedSegmentedControl: View {
    var body: some View {
        HStack(spacing: 0) {
            ZStack {
                Text(L10n.yearly)
                    .font(style: .subheadline, weight: .medium)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
            }
            .background(.white)
            .cornerRadius(24)
            .padding(.all, 4)

            ZStack {
                Text(L10n.monthly)
                    .font(style: .subheadline, weight: .medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
            }
            .cornerRadius(24)
            .padding(.all, 4)
        }
        .background(.white.opacity(0.16))
        .cornerRadius(24)
    }
}

struct UpgradeCard: View {
    let tier: UpgradeTier

    var body: some View {
        VStack() {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 4) {
                    Image(tier.iconName)
                        .padding(.leading, 8)
                    Text(tier.title)
                        .foregroundColor(.white)
                        .font(style: .subheadline, weight: .medium)
                        .padding(.trailing, 8)
                        .padding(.top, 2)
                        .padding(.bottom, 2)
                }
                .background(.black)
                .cornerRadius(800)
                .padding(.bottom, 10)

                HStack() {
                    Text(tier.price)
                        .font(style: .largeTitle, weight: .bold)
                    Text("/\(L10n.year)")
                        .font(style: .headline, weight: .bold)
                        .opacity(0.6)
                        .padding(.top, 6)
                }
                .padding(.bottom, 8)

                Text(tier.description)
                    .font(style: .caption2, weight: .semibold)
                    .opacity(0.64)
                    .padding(.bottom, 16)

                VStack(alignment: .leading, spacing: 12) {
                    ForEach(tier.features, id: \.self) { feature in
                        HStack(spacing: 16) {
                            Image(feature.iconName)
                                .renderingMode(.template)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundColor(.black)
                                .frame(width: 16, height: 16)
                            Text(feature.title)
                                .font(size: 14, style: .subheadline, weight: .medium)
                        }
                    }
                }
                .padding(.bottom, 24)

                Button("Subscribe to Plus") {

                }
                .buttonStyle(PlusGradientFilledButtonStyle(isLoading: false, background: Color(hex: "FFD846")))
            }
            .padding(.all, 24)

        }
        .background(.white)
        .cornerRadius(24)
        .shadow(color: .black.opacity(0.01), radius: 10, x: 0, y: 24)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 14)
        .shadow(color: .black.opacity(0.09), radius: 6, x: 0, y: 6)
        .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2)
        .shadow(color: .black.opacity(0.1), radius: 0, x: 0, y: 0)
    }
}

struct UpgradeLandingView_Previews: PreviewProvider {
    static var previews: some View {
        UpgradeLandingView()
    }
}
