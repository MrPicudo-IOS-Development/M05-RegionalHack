/* ImageView.swift --> RegionalHack. Created by Miguel Torres on 23/04/23. */

import SwiftUI

struct ImageView: View {
    @Binding var image: UIImage?
    
    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            } else {
                Text("No Image")
                    .font(.largeTitle)
                    .foregroundColor(.gray)
            }
        }
    }
}

struct ImageView_Previews: PreviewProvider {
    static var previews: some View {
        ImageView(image: .constant(UIImage(systemName: "photo")))
    }
}
