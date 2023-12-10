import SwiftUI

struct TagsHomeViewFree: View {
    @StateObject private var viewModel = TagsFunctionsViewModel()
    private let gridItems = [GridItem(.flexible()), GridItem(.flexible())]
    
    @State private var showNoTagsError = false

    @State private var tagData: TagData? = {
            if let url = Bundle.main.url(forResource: "tags", withExtension: "json"),
               let data = try? Data(contentsOf: url),
               let decodedData = try? JSONDecoder().decode(TagData.self, from: data) {
                return decodedData
            }
            return nil
        }()

    var body: some View {
        ZStack {
            NavigationView {
                ZStack {
                    Color.black
                        .ignoresSafeArea()

                    ScrollView {
                        VStack {
                            HStack {
                                Text("Tags")
                                    .foregroundColor(Color("TextColor"))
                                    .font(.custom("InstagramSans-Bold", size: 52.5))
                                    .padding(.horizontal)
                                    .padding(.vertical, 10)
                                Spacer()
                            }
                        }

                        LazyVGrid(columns: gridItems, spacing: 20) {
                            if let tags = tagData?.tags {
                                ForEach(tags, id: \.self) { tag in
                                    TagView(TagName: tag, viewModel: viewModel, isSelected: tag == viewModel.selectedTag, isPro: false)
                                        .onTapGesture {
                                            viewModel.selectTagForFree(tagToSelect: tag)
                                        }
                                }
                            } else {
                                Text("Apologies, unable to locate any tags.")
                                    .task {
                                        showNoTagsError = true
                                    }
                            }
                        }
                    }
                    .padding(.top, 30)
                }
            }
        }
        .alert(isPresented: $showNoTagsError, content: {
            Alert(title: Text("Uh-oh an error appeared!"), message: Text("It seems an error has occurred. Please try again later."), dismissButton: .default(Text("Ok")))
        })
    }

    func fixDefaultTag(tagName: String) -> String {
        if tagName == "default  " {
            return "default"
        }
        else {
            return tagName
        }
    }
}

#Preview {
    TagsHomeViewFree()
}
