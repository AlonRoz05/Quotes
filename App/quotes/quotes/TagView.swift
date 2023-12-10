import SwiftUI

struct TagView: View {
    @ObservedObject private var viewModel: TagsFunctionsViewModel
    
    @State var isPro: Bool

    @State var showProAlertForTags = false
    @State var TagName = ""
    @State var blueTheTag = false
    @State var blueTheTagForFree = false

    var isSelected: Bool
    
    @State var lastUsedTag = UserDefaults.standard.string(forKey: "usedTagForFree") ?? " "

    init(TagName: String, viewModel: TagsFunctionsViewModel, isSelected: Bool, isPro: Bool) {
        self.TagName = TagName
        self.viewModel = viewModel
        self.isSelected = isSelected
        self.isPro = isPro
    }

    var body: some View {
        ZStack {
            VStack {
                if isPro {
                    Button {
                        viewModel.addTagForPro(tagToSelect: TagName)
                        blueTheTag.toggle()
                    } label: {
                        Text(TagName)
                            .font(.custom("InstagramSans-Bold", size: 18))
                            .foregroundColor(Color("TextColor"))
                            .frame(width: 155, height: 85)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color("ButtonColor"))
                    .buttonBorderShape(.roundedRectangle(radius: 12))
                    .overlay(blueTheTag ? RoundedRectangle(cornerRadius: 12).stroke(Color.mint, lineWidth: 2) : nil)
                    .animation(.easeInOut, value: blueTheTag)
                    
                } else {
                    if TagName == "Ambition 🌟" || TagName ==  "Inspiration 💡" || TagName == "Positivity 😄" || TagName == "Motivation 🚀" {
                        Button {
                            viewModel.selectTagForFree(tagToSelect: TagName)
                        } label: {
                            Text(TagName)
                                .font(.custom("InstagramSans-Bold", size: 18))
                                .foregroundColor(Color("TextColor"))
                                .frame(width: 155, height: 85)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(Color("ButtonColor"))
                        .buttonBorderShape(.roundedRectangle(radius: 12))
                        .overlay(TagName == lastUsedTag ? RoundedRectangle(cornerRadius: 12).stroke(Color.gray, lineWidth: 2) : nil)
                        .overlay(isSelected ? RoundedRectangle(cornerRadius: 12).stroke(Color.mint, lineWidth: 2) : nil)
                        .animation(.easeInOut, value: TagName == lastUsedTag)
                        .animation(.easeInOut, value: isSelected)
                        
                    }
                    else {
                        Button {
                            showProAlertForTags.toggle()
                        } label: {
                            Text(TagName)
                                .font(.custom("InstagramSans-Bold", size: 18))
                                .foregroundColor(.gray)
                                .frame(width: 155, height: 85)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(Color("ButtonColor")).opacity(0.5)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(.black, lineWidth: 2))
                    }
                }
            }
        }
        .onAppear {
            if checkContains(stringToCheck: TagName) {
                blueTheTag.toggle()
            }
        }
        .alert(isPresented: $showProAlertForTags, content: {
            Alert(title: Text("This tag is for Pro users only."), message: Text("Upgrade to Pro to access it."), dismissButton: .default(Text("Ok")))
        })
    }
    
    func checkContains(stringToCheck: String) -> Bool {
        let savedUsedTags = UserDefaults.standard.array(forKey: "usedTagForPro") as? [String] ?? []
        if savedUsedTags.contains(stringToCheck) {
            return true
        } else {
            return false
        }
    }
}

struct TagData: Codable {
    var tags: [String]
}

class TagsFunctionsViewModel: ObservableObject {
    @Published var selectedTag: String?

    func selectTagForFree(tagToSelect: String) {
        if selectedTag == tagToSelect {
            selectedTag = nil
            UserDefaults.standard.set(selectedTag, forKey: "usedTagForFree")
        } else {
            selectedTag = tagToSelect
            UserDefaults.standard.set(selectedTag, forKey: "usedTagForFree")
        }
    }

    func addTagForPro(tagToSelect: String) {
        var savedUsedTags = UserDefaults.standard.array(forKey: "usedTagForPro") as? [String] ?? []

        if savedUsedTags.contains(tagToSelect) {
            if let index = savedUsedTags.firstIndex(of: tagToSelect) {
                savedUsedTags.remove(at: index)
            }
        } else {
            savedUsedTags.append(tagToSelect)
        }

        UserDefaults.standard.set(savedUsedTags, forKey: "usedTagForPro")
    }

}
