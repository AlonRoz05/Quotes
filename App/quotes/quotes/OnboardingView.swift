import SwiftUI

enum BoardingState: Int {
    case empty = 0
    case first
    case second
    case last
}

struct OnboardingView: View {
    @Binding var shouldShowOnBoarding: Bool

    @State var boardingState: BoardingState = .empty

    @State var onboardingview: Int = 0

    @State var buttonText: String = "Get Started!"

    let transetion: AnyTransition = .asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading))

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            VStack {
                ZStack {
                    switch onboardingview {
                    case 0:
                        FirstView()
                            .transition(transetion)
                    case 1:
                        SecondView()
                            .transition(transetion)
                    case 2:
                        ThirdView()
                            .transition(transetion)
                    default:
                        FinishedView()
                    }
                }
                Button {
                    withAnimation(.spring()) {
                        onboardingview += 1
                        switch boardingState {
                        case .empty:
                            buttonText = "Next"
                            boardingState = .first
                        case .first:
                            buttonText = "Sure"
                            boardingState = .second
                        case .second:
                            buttonText = "Done!"
                            boardingState = .last
                        case .last:
                            shouldShowOnBoarding.toggle()
                        }
                    }
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .frame(width: 140, height: 52.5)
                            .foregroundColor(Color("TextColor"))
                        
                        Text(buttonText)
                            .foregroundColor(.black)
                            .font(.custom("InstagramSans-Bold", size: 18))
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
            }
        }
    }
}

struct FirstView: View {
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                Text("Welcome to Quotes!")
                    .font(.custom("InstagramSans-Bold", size: 30))
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color("TextColor"))
                    .padding()
                    .padding(.top)
                
                Text("Our world of inspiration! Quotes will empower you to discover your full potential. Get ready for a transformative journey towards your best self.")
                    .font(.custom("InstagramSans-Bold", size: 18))

                    .multilineTextAlignment(.center)
                    .foregroundColor(Color("TextColor"))
                    .padding(.bottom)
                    .frame(width: 350)

                Spacer()
                
                Text("👋")
                    .font(.system(size: 72, weight: .semibold))
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color("TextColor"))
                    .padding(.bottom)
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
        }
    }
}

struct SecondView: View {
    var body: some View {
        VStack {
            Spacer()
            Text("Daily Motivation Boost!")
                .font(.custom("InstagramSans-Bold", size: 30))
                .multilineTextAlignment(.center)
                .foregroundColor(Color("TextColor"))
                .padding()
                .padding(.top)

            Text("Start each day with a powerful motivation boost. Quotes delivers daily inspiration to keep you moving forward and embrace an extraordinary life!")
                .font(.custom("InstagramSans-Bold", size: 18))
                .multilineTextAlignment(.center)
                .foregroundColor(Color("TextColor"))
                .padding(.bottom)
                .frame(width: 350)
            
            Spacer()
            
            Text("🚀")
                .font(.system(size: 72, weight: .semibold))
                .multilineTextAlignment(.center)
                .foregroundColor(Color("TextColor"))
                .padding(.bottom)
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

struct ThirdView: View {
    var body: some View {
        VStack {
            Spacer()
            Text("Unlock the Full Experience!")
                .font(.custom("InstagramSans-Bold", size: 30))
                .multilineTextAlignment(.center)
                .foregroundColor(Color("TextColor"))
                .padding()

            Text("Experience motivation at its finest with our Pro version! Ready to elevate your motivation journey? Go Pro and take it to the next level!")
                .font(.custom("InstagramSans-Bold", size: 18))
                .multilineTextAlignment(.center)
                .foregroundColor(Color("TextColor"))
                .padding(.bottom)
                .frame(width: 350)
            
            Spacer()
            
            Text("💪")
                .font(.system(size: 72, weight: .semibold))
                .multilineTextAlignment(.center)
                .foregroundColor(Color("TextColor"))
                .padding(.bottom)
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

struct FinishedView: View {
    var body: some View {
        VStack {
            Spacer()
            Text("You're all set!")
                .font(.custom("InstagramSans-Bold", size: 30))
                .multilineTextAlignment(.center)
                .foregroundColor(Color("TextColor"))
                .padding()
            
            Spacer()
            
            Text("🎉")
                .font(.system(size: 72, weight: .semibold))
                .multilineTextAlignment(.center)
                .foregroundColor(Color("TextColor"))
                .padding(.bottom)
            
            Spacer()
        }
    }
}

#Preview {
    OnboardingView(shouldShowOnBoarding: .constant(true))
}
