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

    @State var buttonText: String = "Get Started!"

    let transetion: AnyTransition = .asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading))

    var body: some View {
        ZStack {
            Image("onBoardingBackgroundImage")
                .resizable()
                .aspectRatio(contentMode: .fill)
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
                    case 3:
                        Spacer()
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
                            _ = notify.askPremmision()
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
            Spacer()
            Text("Welcome to Quotes 👋")
                .font(.system(size: 30, weight: .bold))
                .multilineTextAlignment(.center)
                .foregroundColor(Color("TextColorOnBoarding"))
                .padding()
                .padding(.top)


            Text("Welcome to Quotes, Our world of inspiration! Quotes will empower you to discover your full potential. Get ready for a transformative journey towards your best self.")
                .font(.system(size: 18, weight: .semibold))
                .multilineTextAlignment(.center)
                .foregroundColor(Color("TextColorOnBoarding"))
                .padding(.bottom)
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

struct SecondView: View {
    var body: some View {
        VStack {
            Spacer()
            Text("Daily Motivation Boost 🚀")
                .font(.system(size: 30, weight: .bold))
                .multilineTextAlignment(.center)
                .foregroundColor(Color("TextColorOnBoarding"))
                .padding()
                .padding(.top)

            Text("Start each day with a powerful motivation boost. Quotes delivers daily inspiration to keep you moving forward and embrace an extraordinary life!")
                .font(.system(size: 20, weight: .semibold))
                .multilineTextAlignment(.center)
                .foregroundColor(Color("TextColorOnBoarding"))
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
            Text("Never Miss an Inspiration 🔔")
                .font(.system(size: 30, weight: .bold))
                .multilineTextAlignment(.center)
                .foregroundColor(Color("TextColorOnBoarding"))
                .padding()
                .padding(.top)

            Text("To make the most of your motivational journey, we recommend turning on notifications. This way, you'll never miss a moment of inspiration. We'll send you daily doses of motivation and reminders to keep you on track. Enable notifications and let the magic begin!")
                .font(.system(size: 20, weight: .semibold))
                .multilineTextAlignment(.center)
                .foregroundColor(Color("TextColorOnBoarding"))
                .padding(.bottom)
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

struct ForthView: View {
    var body: some View {
        VStack {
            Spacer()
            Text("Dream Big, Achieve More 🏆")
                .font(.system(size: 30, weight: .bold))
                .multilineTextAlignment(.center)
                .foregroundColor(Color("TextColorOnBoarding"))
                .padding()
            
            Text("Your dreams are within reach. With Quotes, you have the tools to turn your aspirations into reality. Set goals, stay motivated, and conquer obstacles. Your journey to success begins now!")
                .font(.system(size: 20, weight: .semibold))
                .multilineTextAlignment(.center)
                .foregroundColor(Color("TextColorOnBoarding"))
                .padding(.bottom)
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

struct FiftView: View {
    var body: some View {
        VStack {
            Spacer()
            Text("Almost there!")
                .font(.system(size: 30, weight: .bold))
                .multilineTextAlignment(.center)
                .foregroundColor(Color("TextColorOnBoarding"))
                .padding()

            Text("")
                .font(.system(size: 20, weight: .semibold))
                .multilineTextAlignment(.center)
                .foregroundColor(Color("TextColorOnBoarding"))
                .padding(.bottom)
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

struct SixtView: View {
    var body: some View {
        VStack {
            Spacer()
            Text("Unlock the Full Experience! 🚀")
                .font(.system(size: 30, weight: .bold))
                .multilineTextAlignment(.center)
                .foregroundColor(Color("TextColorOnBoarding"))
                .padding()

            Text("Experience motivation at its finest with our Pro version! Ready to elevate your motivation journey? Go Pro and take it to the next level! 🌟")
                .font(.system(size: 20, weight: .semibold))
                .multilineTextAlignment(.center)
                .foregroundColor(Color("TextColorOnBoarding"))
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
                .font(.system(size: 30, weight: .bold))
                .multilineTextAlignment(.center)
                .foregroundColor(Color("TextColorOnBoarding"))
                .padding()

            Text("")
                .font(.system(size: 20, weight: .semibold))
                .multilineTextAlignment(.center)
                .foregroundColor(Color("TextColorOnBoarding"))
                .padding(.bottom)
            
            Spacer()
        }
    }
}

#Preview {
    OnboardingView(shouldShowOnBoarding: .constant(true))
}
