import SwiftUI

struct AddGameView: View {
  @Environment(\.dismiss) private var dismiss
  var library: GameLibrary
  @FocusState private var isTitleFocused: Bool
  @State private var title = ""
  @State private var platform = GamingPlatform.switch2
  @State private var status = GameStatus.wantToPlay

  private var trimmedTitle: String {
    title.trimmingCharacters(in: .whitespacesAndNewlines)
  }

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(alignment: .leading, spacing: 32) {
          AddGameIntroduction()
          GameTitleField(title: $title, isFocused: $isTitleFocused)
          PlatformSelectionSection(selection: $platform)
          StartingStatusSection(selection: $status)
          ShelfPlacementPreview(
            title: trimmedTitle.isEmpty ? "Your game" : trimmedTitle,
            platform: platform,
            status: status
          )
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 110)
        .frame(maxWidth: 640)
        .frame(maxWidth: .infinity, alignment: .leading)
      }
      .background(Color.galleryBackground)
      .navigationTitle("Add Game")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Cancel") { dismiss() }
        }
      }
      .safeAreaInset(edge: .bottom) {
        AddToShelfAction(isEnabled: !trimmedTitle.isEmpty) {
          library.addGame(title: trimmedTitle, platform: platform, status: status)
          dismiss()
        }
      }
      .sensoryFeedback(.selection, trigger: platform)
      .sensoryFeedback(.selection, trigger: status)
      .task {
        isTitleFocused = true
      }
    }
  }
}

private struct AddGameIntroduction: View {
  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("Place a game on your shelf")
        .font(.title2.bold())
      Text("Start with the essentials. You can add notes and memories whenever they happen.")
        .font(.body)
        .foregroundStyle(.secondary)
    }
  }
}

private struct GameTitleField: View {
  @Binding var title: String
  var isFocused: FocusState<Bool>.Binding

  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      Label("What are you playing?", systemImage: "text.cursor")
        .font(.headline)
      TextField("Game title", text: $title)
        .font(.title3.weight(.semibold))
        .textFieldStyle(.plain)
        .focused(isFocused)
        .submitLabel(.done)
        .padding(16)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
        .accessibilityHint("Required to add the game")
    }
  }
}

private struct PlatformSelectionSection: View {
  @Binding var selection: GamingPlatform

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      VStack(alignment: .leading, spacing: 3) {
        Text("Choose its shape").font(.headline)
        Text("Platform gives each game its place on the shelf.")
          .font(.subheadline)
          .foregroundStyle(.secondary)
      }
      ScrollView(.horizontal) {
        HStack(spacing: 14) {
          ForEach(GamingPlatform.allCases, id: \.self) { platform in
            PlatformSelectionCard(
              platform: platform,
              isSelected: selection == platform
            ) {
              withAnimation(.snappy) {
                selection = platform
              }
            }
          }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 2)
      }
      .scrollIndicators(.hidden)
    }
  }
}

private struct PlatformSelectionCard: View {
  var platform: GamingPlatform
  var isSelected: Bool
  var select: () -> Void

  var body: some View {
    Button(action: select) {
      VStack(spacing: 10) {
        ZStack(alignment: .topTrailing) {
          PlatformObjectView(platform: platform)
            .frame(width: 84, height: 104)
            .padding(.top, 6)
          Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
            .font(.title3)
            .foregroundStyle(isSelected ? AnyShapeStyle(.tint) : AnyShapeStyle(.tertiary))
            .background(.regularMaterial, in: Circle())
        }
        Text(platform.shortName)
          .font(.subheadline.weight(.semibold))
          .foregroundStyle(.primary)
          .lineLimit(1)
      }
      .padding(12)
      .frame(width: 126, height: 158)
      .background(
        isSelected ? AnyShapeStyle(.tint.opacity(0.12)) : AnyShapeStyle(.regularMaterial),
        in: RoundedRectangle(cornerRadius: 20)
      )
      .overlay {
        RoundedRectangle(cornerRadius: 20)
          .stroke(isSelected ? AnyShapeStyle(.tint) : AnyShapeStyle(.white.opacity(0.18)), lineWidth: isSelected ? 2 : 1)
      }
      .scaleEffect(isSelected ? 1.03 : 1)
    }
    .buttonStyle(.plain)
    .accessibilityLabel(platform.rawValue)
    .accessibilityValue(isSelected ? "Selected" : "Not selected")
    .accessibilityAddTraits(isSelected ? .isSelected : [])
  }
}

private struct StartingStatusSection: View {
  @Binding var selection: GameStatus

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("Where does it belong?").font(.headline)
      ScrollView(.horizontal) {
        HStack(spacing: 10) {
          ForEach(GameStatus.allCases, id: \.self) { status in
            Button {
              withAnimation(.snappy) { selection = status }
            } label: {
              Label(status.rawValue, systemImage: status.symbol)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(selection == status ? AnyShapeStyle(.white) : AnyShapeStyle(.primary))
                .padding(.horizontal, 15)
                .frame(minHeight: 44)
                .background(selection == status ? AnyShapeStyle(.tint) : AnyShapeStyle(.regularMaterial), in: Capsule())
            }
            .buttonStyle(.plain)
            .accessibilityAddTraits(selection == status ? .isSelected : [])
          }
        }
        .padding(.vertical, 2)
      }
      .scrollIndicators(.hidden)
    }
  }
}

private struct ShelfPlacementPreview: View {
  var title: String
  var platform: GamingPlatform
  var status: GameStatus

  var body: some View {
    HStack(spacing: 16) {
      PlatformObjectView(platform: platform)
        .frame(width: 58, height: 76)
        .accessibilityHidden(true)
      VStack(alignment: .leading, spacing: 5) {
        Text("READY FOR YOUR SHELF")
          .font(.caption2.weight(.bold))
          .tracking(1)
          .foregroundStyle(.secondary)
        Text(title).font(.headline).lineLimit(2)
        Label(status.rawValue, systemImage: status.symbol)
          .font(.caption)
          .foregroundStyle(.secondary)
      }
      Spacer()
    }
    .padding(18)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
    .accessibilityElement(children: .combine)
  }
}

private struct AddToShelfAction: View {
  var isEnabled: Bool
  var action: () -> Void

  var body: some View {
    Button(action: action) {
      Label("Add to Shelf", systemImage: "books.vertical.fill")
        .font(.headline)
        .frame(maxWidth: .infinity, minHeight: 50)
    }
    .buttonStyle(.borderedProminent)
    .disabled(!isEnabled)
    .padding(.horizontal, 20)
    .padding(.vertical, 10)
    .background(.bar)
  }
}
