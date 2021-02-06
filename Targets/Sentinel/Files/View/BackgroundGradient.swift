//
// Copyright (c) N/A
//

import SwiftUIX

struct BackgroundGradient: View {
    var body: some View {
        AngularGradient(
            gradient: Gradient(
                colors: [
                    Color(hexadecimal: "272E36"),
                    Color(hexadecimal: "272E36").opacity(0.5),
                    Color(hexadecimal: "272E36"),
                    Color(hexadecimal: "272E36").opacity(0.5),
                    Color(hexadecimal: "272E36"),
                ]
            ),
            center: .topLeading
        )
        .saturation(2.0)
        .aspectRatio(contentMode: .fill)
        .edgesIgnoringSafeArea(.all)
    }
}

struct BackgroundGradient_Previews: PreviewProvider {
    static var previews: some View {
        BackgroundGradient()
    }
}
