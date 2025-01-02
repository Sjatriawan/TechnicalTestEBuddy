//
//  ProfileCard.swift
//  TechnicalTestEbuddy
//
//  Created by M Yogi Satriawan on 28/12/24.
//
import SwiftUI

// Profile Card View
struct ProfileCard: View {
    let viewModel: CardViewModel
    
    init(
        username: String,
        rating: Double,
        ratingCount: Int,
        hourlyRate: Double,
        isOnline: Bool = false,
        isVerified: Bool = false,
        games: [GameIcon] = []
    ) {
        self.viewModel = CardViewModel(
            username: username,
            rating: rating,
            ratingCount: ratingCount,
            hourlyRate: hourlyRate,
            isOnline: isOnline,
            isVerified: isVerified,
            games: games
        )
    }
    
    var body: some View {
        VStack {
            CardHeader(
                username: viewModel.username,
                isOnline: viewModel.isOnline,
                isVerified: viewModel.isVerified
            )
            Spacer().frame(height: 12)
            ProfileImage(games: viewModel.games, viewModel: viewModel)
            Spacer().frame(height: 24)
            RatingView(rating: viewModel.rating, ratingCount: viewModel.ratingCount)
            HourlyRateView(rate: viewModel.hourlyRate)
        }
        .frame(width: 166, height: 300)
        .background(Color(.secondary))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.2), radius: 3, x: 0, y: 2)
    }
}

// Card Header
struct CardHeader: View {
    private enum Constants {
        static let fontSize: CGFloat = 16
        static let iconSize: CGFloat = 20
        static let dotSize: CGFloat = 8
        static let padding: CGFloat = 8
    }
    
    let username: String
    let isOnline: Bool
    let isVerified: Bool
    
    var body: some View {
        HStack {
            Text(username)
                .font(.system(size: Constants.fontSize, weight: .bold))
            
            if isOnline {
                Circle()
                    .fill(Color.green)
                    .frame(width: Constants.dotSize, height: Constants.dotSize)
            }
            
            Spacer()
            
            if isVerified {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundColor(.blue)
                    .font(.system(size: Constants.fontSize + 2))
            }
            
            Image("icon_insta")
                .resizable()
                .frame(width: Constants.iconSize, height: Constants.iconSize)
                .foregroundStyle(.onPrimary)
        }
        .padding(.horizontal, Constants.padding)
    }
}

// Profile Image with Game Icons
struct ProfileImage: View {
    let games: [GameIcon]
    let viewModel: CardViewModel
    
    var body: some View {
        ZStack {
            Image("profile_img")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 150, height: 180)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(alignment: .bottomLeading) {
                    GameIconsRow(games: games)
                        .offset(y: 20)
                }
                .overlay(alignment: .top) {
                    if viewModel.isOnline {
                        AvailableTodayView(text: "Available today") { }
                            .padding(.top, 6)
                    }
                }
                .overlay(alignment: .bottomTrailing) {
                    if viewModel.isOnline {
                        VoiceView()
                            .padding(.trailing, 10)
                            .offset(y: 20)
                    }
                }
        }
    }
}

// Game Icons Row
struct GameIconsRow: View {
    private enum Constants {
        static let iconSize: CGFloat = 40
        static let spacing: CGFloat = -15
        static let blurRadius: CGFloat = 1
        static let overlayOpacity: Double = 0.3
        static let fontSize: CGFloat = 12
    }
    
    let games: [GameIcon]
    
    var body: some View {
        HStack(spacing: Constants.spacing) {
            ForEach(games.prefix(2).indices, id: \.self) { index in
                gameIcon(at: index)
            }
        }
        .padding(.horizontal, 8)
    }
    
    @ViewBuilder
    private func gameIcon(at index: Int) -> some View {
        ZStack {
            Circle()
                .fill(Color.white)
                .frame(width: Constants.iconSize, height: Constants.iconSize)
            
            if let image = UIImage(named: games[index].icon) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: Constants.iconSize, height: Constants.iconSize)
                    .clipShape(Circle())
                    .blur(radius: shouldBlur(at: index) ? Constants.blurRadius : 0)
                    .overlay {
                        if shouldShowOverlay(at: index) {
                            overlayView
                        }
                    }
            } else {
                Image("default_game_icon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: Constants.iconSize, height: Constants.iconSize)
                    .clipShape(Circle())
            }
        }
    }
    
    private var overlayView: some View {
        ZStack {
            Circle()
                .fill(Color.black.opacity(Constants.overlayOpacity))
            Text("+\(games.count - 2)")
                .font(.system(size: Constants.fontSize, weight: .bold))
                .foregroundColor(.white)
        }
    }
    
    private func shouldBlur(at index: Int) -> Bool {
        index == 1 && games.count > 2
    }
    
    private func shouldShowOverlay(at index: Int) -> Bool {
        index == 1 && games.count > 2
    }
}

// Available Today Button
struct AvailableTodayView: View {
    let text: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: "bolt.fill")
                Text(text)
            }
            .font(.system(size: 12, weight: .regular))
            .frame(width: 128, height: 28)
            .background(.ultraThinMaterial)
            .cornerRadius(100)
            .foregroundColor(.white)
        }
    }
}

import SwiftUI

struct VoiceView: View {
    var body: some View {
        Circle()
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(.color1),
                        Color(.color2),
                        Color(.color3)
                        
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: 40, height: 40)
            .overlay {
                Image("icon_voice")
            }
    }
}




// Rating View
struct RatingView: View {
    private enum Constants {
        static let iconSize: CGFloat = 14
        static let ratingFontSize: CGFloat = 14
        static let countFontSize: CGFloat = 12
    }
    
    let rating: Double
    let ratingCount: Int
    
    var body: some View {
        HStack {
            Image("icon_star")
                .resizable()
                .frame(width: Constants.iconSize, height: Constants.iconSize)
            Text(String(format: "%.1f", rating))
                .font(.system(size: Constants.ratingFontSize, weight: .bold))
            Text("(\(ratingCount))")
                .font(.system(size: Constants.countFontSize))
                .foregroundColor(.gray)
            Spacer()
        }
        .padding(.horizontal)
    }
}

// Hourly Rate View
struct HourlyRateView: View {
    private enum Constants {
        static let iconSize: CGFloat = 14
        static let fontSize: CGFloat = 14
    }
    
    let rate: Double
    
    var body: some View {
        HStack {
            Image("icon_flame")
                .resizable()
                .frame(width: Constants.iconSize, height: Constants.iconSize)
            HStack(spacing: 0) {
                Text("\(Int(rate))")
                    .font(.system(size: Constants.fontSize, weight: .bold))
                Text(".00/1Hr")
                    .font(.system(size: Constants.fontSize, weight: .regular))
            }
            Spacer()
        }
        .padding(.horizontal)
    }
}

// Preview
struct ProfileCard_Previews: PreviewProvider {
    static var previews: some View {
        ProfileCard(
            username: "PlayerOne",
            rating: 4.8,
            ratingCount: 245,
            hourlyRate: 25.0,
            isOnline: true,
            isVerified: true,
            games: [
                GameIcon(gameName: "call_of_duty"),
                GameIcon(gameName: "mobile_legends"),
                GameIcon(gameName: "valorant")
            ]
        )
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
