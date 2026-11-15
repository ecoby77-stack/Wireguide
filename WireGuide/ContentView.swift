import SwiftUI

/// Density steps for the ampacity block. The largest step that fits the
/// simulator height is used so the title and every table row stay on screen.
private struct Density {
    var titleSize: CGFloat
    var rowPadding: CGFloat
    var headerPadding: CGFloat
    var spacing: CGFloat
    var dataFont: Font
    var headerFont: Font

    static let comfortable = Density(
        titleSize: 28,
        rowPadding: 8,
        headerPadding: 8,
        spacing: 12,
        dataFont: .subheadline,
        headerFont: .caption.weight(.semibold)
    )

    static let compact = Density(
        titleSize: 24,
        rowPadding: 5,
        headerPadding: 5,
        spacing: 8,
        dataFont: .footnote,
        headerFont: .caption2.weight(.semibold)
    )

    static let tight = Density(
        titleSize: 20,
        rowPadding: 3,
        headerPadding: 3,
        spacing: 6,
        dataFont: .caption,
        headerFont: .caption2.weight(.semibold)
    )
}

struct ContentView: View {
    var body: some View {
        GeometryReader { geo in
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    ViewThatFits(in: .vertical) {
                        ReferenceBlock(density: .comfortable)
                        ReferenceBlock(density: .compact)
                        ReferenceBlock(density: .tight)
                    }
                    .frame(width: geo.size.width, height: geo.size.height, alignment: .top)

                    QuickMatchSection()
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                    DisclaimerSection()
                        .padding(.horizontal, 16)
                }
            }
            .scrollIndicators(.hidden)
            .scrollBounceBehavior(.basedOnSize, axes: .horizontal)
        }
        .background(Color.black.ignoresSafeArea())
        .preferredColorScheme(.dark)
        .dynamicTypeSize(.large)
    }
}

/// Title, copper THHN table, and small-conductor footnote.
/// Laid out at its natural height and pinned to the top of the first screen.
private struct ReferenceBlock: View {
    let density: Density

    var body: some View {
        VStack(alignment: .leading, spacing: density.spacing) {
            Text("Wire Size and Ampacity")
                .font(.system(size: density.titleSize, weight: .bold))
                .foregroundStyle(.primary)
                .lineLimit(2)
                .minimumScaleFactor(0.7)
                .allowsTightening(true)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityAddTraits(.isHeader)

            ampacitySection

            Text(WireData.smallConductorFootnote)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 8)
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }

    private var ampacitySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Copper THHN — NEC Table 310.16")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
                .fixedSize(horizontal: false, vertical: true)

            VStack(spacing: 0) {
                tableHeader
                ForEach(Array(WireData.copperTHHN.enumerated()), id: \.element.id) { index, row in
                    ampacityRow(row, isAlternate: index.isMultiple(of: 2) == false)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
            )
        }
    }

    private var tableHeader: some View {
        HStack(spacing: 0) {
            headerCell("Size", alignment: .leading)
            headerCell("60°C", alignment: .trailing)
            headerCell("75°C", alignment: .trailing)
            headerCell("90°C", alignment: .trailing)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, density.headerPadding)
        .background(Color(white: 0.18))
    }

    private func headerCell(_ title: String, alignment: Alignment) -> some View {
        Text(title)
            .font(density.headerFont)
            .foregroundStyle(.secondary)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            .allowsTightening(true)
            .frame(maxWidth: .infinity, alignment: alignment)
    }

    private func ampacityRow(_ row: WireAmpacity, isAlternate: Bool) -> some View {
        HStack(spacing: 0) {
            dataCell(row.size, alignment: .leading, weight: .semibold)
            dataCell("\(row.ampacity60C)", alignment: .trailing)
            dataCell("\(row.ampacity75C)", alignment: .trailing)
            dataCell("\(row.ampacity90C)", alignment: .trailing)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, density.rowPadding)
        .background(isAlternate ? Color(white: 0.12) : Color(white: 0.08))
    }

    private func dataCell(
        _ text: String,
        alignment: Alignment,
        weight: Font.Weight = .regular
    ) -> some View {
        Text(text)
            .font(density.dataFont)
            .fontWeight(weight)
            .monospacedDigit()
            .foregroundStyle(.primary)
            .lineLimit(1)
            .minimumScaleFactor(0.65)
            .allowsTightening(true)
            .frame(maxWidth: .infinity, alignment: alignment)
    }
}

private struct QuickMatchSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Quick Match")
                .font(.title3)
                .fontWeight(.bold)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            Text("Circuit → wire → breaker")
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            VStack(spacing: 0) {
                ForEach(Array(WireData.quickMatches.enumerated()), id: \.element.id) { index, item in
                    quickMatchRow(item, isAlternate: index.isMultiple(of: 2) == false)
                    if index < WireData.quickMatches.count - 1 {
                        Divider()
                            .overlay(Color.white.opacity(0.08))
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func quickMatchRow(_ item: QuickMatch, isAlternate: Bool) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Text(item.use)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.primary)
                .multilineTextAlignment(.leading)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(item.wire)
                .font(.subheadline.monospacedDigit())
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
                .layoutPriority(1)

            Text(item.breaker)
                .font(.subheadline.weight(.semibold).monospacedDigit())
                .foregroundStyle(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
                .layoutPriority(1)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 11)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(isAlternate ? Color(white: 0.12) : Color(white: 0.08))
    }
}

private struct DisclaimerSection: View {
    var body: some View {
        Text(WireData.disclaimer)
            .font(.caption)
            .foregroundStyle(.tertiary)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity)
            .padding(.top, 4)
            .padding(.bottom, 16)
    }
}

#Preview {
    ContentView()
        .preferredColorScheme(.dark)
}
