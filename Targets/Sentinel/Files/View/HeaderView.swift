//
// Copyright (c) N/A
//

import SwiftUIX

struct HeaderView: View {
    let isCompact: Bool
    
    init(isCompact: Bool = false) {
        self.isCompact = isCompact
    }
    
    var body: some View {
        if isCompact {
            HStack {
                Image("logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .squareFrame(sideLength: 24)
                
                Text("Sentinel")
                    .font(.custom("Overpass-Regular", size: 16))
            }
        } else {
            VStack {
                HStack {
                    Image("logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .squareFrame(sideLength: 48)
                    Text("SENTINEL")
                        .font(.system(size: 32))
                }
                
                Text("Secure & Open-source Wallet")
                    .font(.callout)
            }
        }
    }
}
