import SwiftUI

struct NoInternetView: View {
    var body: some View {
        ZStack {
            Color.black
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Image(systemName: "wifi.slash")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)

                Text("No internet connection. Please check your connection and try again.")
                    .foregroundColor(Color("TextColor"))
                    .font(.custom("InstagramSans-Bold", size: 18))
                    .multilineTextAlignment(.center)
                    .padding()
            }
        }
    }
}

#Preview {
    NoInternetView()
}
