//
//  OnboardingView.swift
//  Quotes
//
//  Created by Alon Rozmarin on 13/10/2023.
//

import SwiftUI

enum CircleState: Int {
    case empty = 0
    case first
    case second
    case third
    case forth
    case fift
    case last
}

struct OnboardingView: View {
    let notify = NotificationHandler()

    @Binding var shouldShowOnBoarding: Bool

    @State var circleState: CircleState = .empty

    @State var onboardingview: Int = 0
    @State var widthi: CGFloat = 0

    @State var buttonText: String = "Let's Start!"

    let transetion: AnyTransition = .asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading))

    var body: some View {
        ZStack {
            Color("BackgroundColor")
                .ignoresSafeArea()

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
                case 3:
                    ForthView()
                        .transition(transetion)
                case 4:
                    FiftView()
                        .transition(transetion)
                case 5:
                    SixtView()
                        .transition(transetion)
                default:
                    FinishedView()
                }
            }
            VStack {
                Spacer()
                Button {
                    withAnimation(.spring()) {
                        onboardingview += 1
                        switch circleState {
                        case .empty:
                            buttonText = "Next"
                            circleState = .first
                            widthi += 60
                        case .first:
                            circleState = .second
                            widthi += 60
                            buttonText = "Sure"
                        case .second:
                            notify.askPremmision()
                            circleState = .third
                            buttonText = "Continue"
                            widthi += 60
                        case .third:
                            buttonText = "Next"
                            circleState = .forth
                            widthi += 60
                        case .forth:
                            buttonText = "Got it"
                            circleState = .fift
                            widthi += 60
                        case .fift:
                            // need to put here the paywall
                            circleState = .last
                            widthi += 55
                            buttonText = "Done!"
                        case .last:
                            shouldShowOnBoarding.toggle()
                        }
                    }
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .frame(width: 140, height: 52.5)
                            .foregroundColor(Color("TextColor"))

                        Text(buttonText).bold()
                            .foregroundColor(.black)
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
        VStack {
            Text("Hey👋").bold()
                .font(.largeTitle)
                .foregroundColor(Color("TextColor"))
            Text("Let's get you going.").fontWeight(.semibold)
                .foregroundColor(Color("TextColor"))
        }
        .frame(maxWidth: .infinity)
    }
}

struct SecondView: View {
    var body: some View {
        VStack {
            Text("Your goning to stay motivated and achieve goals!").bold()
                .foregroundColor(Color("TextColor"))
                .multilineTextAlignment(.center)
                .font(.largeTitle)

            Text("An we are willing help you do it.")
                .bold()
                .foregroundColor(Color("TextColor"))
        }
        .frame(maxWidth: .infinity)
    }
}

struct ThirdView: View {
    var body: some View {
        VStack {
            Text("Enable notifications").bold()
                .font(.largeTitle)
                .foregroundColor(Color("TextColor"))
            Text("")
                .foregroundColor(Color("TextColor"))
        }
        .frame(maxWidth: .infinity)
    }
}

struct ForthView: View {
    var body: some View {
        VStack {
            Text("Need to fix this view").bold()
                .font(.largeTitle)
                .foregroundColor(Color("TextColor"))
        }
        .frame(maxWidth: .infinity)
    }
}

struct FiftView: View {
    var body: some View {
        VStack {
            Text("Almost there!").bold()
                .font(.largeTitle)
                .foregroundColor(Color("TextColor"))
            Text("")
                .foregroundColor(Color("TextColor"))
        }
        .frame(maxWidth: .infinity)
    }
}

struct SixtView: View {
    var body: some View {
        VStack {
            Text("With pro you can do alot more!").bold()
                .font(.largeTitle)
                .foregroundColor(Color("TextColor"))
            Text("")
                .foregroundColor(Color("TextColor"))
        }
        .frame(maxWidth: .infinity)
    }
}

struct FinishedView: View {
    var body: some View {
        VStack {
            Text("Your all set!").bold()
                .font(.largeTitle)
                .foregroundColor(Color("TextColor"))
            Text("")
                .foregroundColor(Color("TextColor"))
        }
    }
}

#Preview {
    OnboardingView(shouldShowOnBoarding: .constant(true))
}
