//
// Copyright (c) N/A
//

import FoundationX
import SwiftUIX

struct BuiltByDisclaimer: View {
    @Namespace var namespace
    
    var isVersionVisible: Bool = true
    
    var body: some View {
        VStack {
            HStack {
                Text("Built by")
                    .font(.body)
                    .foregroundColor(.white)
                
                Image("logo.exidio.horizontal")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 36)
            }
            .matchedGeometryEffect(id: "builtbyexidio", in: namespace)
            
            if let version = Bundle.main.shortVersion, isVersionVisible {
                Text("v" + version.description)
                    .font(.body)
                    .foregroundColor(.gray)
                    .transition(.opacity)
            }
        }
    }
}

struct BuiltByDisclaimer_Previews: PreviewProvider {
    static var previews: some View {
        BuiltByDisclaimer()
            .environmentObject(AppModel.shared)
    }
}
