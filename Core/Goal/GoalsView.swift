

import SwiftUI

struct Goals {
    let name: String
    var isDone: Bool
}

struct GoalsView: View {
    
    @State var items: [Goals] = []
    @State var inputText: String = ""
    
    var body: some View {
        VStack {
            List {
                ForEach(0..<items.count, id: \.self) { i in
                    Button {
                        items[i].isDone.toggle()
                    } label: {
                        HStack{
                            if items[i].isDone {
                                Image(systemName: "checkmark.square")
                                    .resizable()
                                    .frame(width: 24, height: 24)
                            }
                            else {
                                Image(systemName: "square")
                                    .resizable()
                                    .frame(width: 24, height: 24)
                            }
                            Text("\(items[i].name)")
                        }
                    }
                }
                
            }
        }
        
        HStack{
            TextField("Add a new goal", text: $inputText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Button {
                items.append(Goals(name: inputText, isDone: false))
                inputText = ""
            } label: {
                Text("Add")
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 20)
    }
}

#Preview {
  GoalsView()
}


