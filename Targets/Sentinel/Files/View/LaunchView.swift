//
// Copyright (c) N/A
//

import SwiftUIX

struct ViewDebugInspection: ViewModifier {
    @State var size: CGSize = .zero
    
    func body(content: Content) -> some View {
        content
            .captureSize(in: $size)
            .overlay(
                XStack(alignment: .topTrailing) {
                    Text(String(format: "%.2f", size.width) + ", " + String(format: "%.2f", size.height))
                        .font(.caption)
                        .background(Color.black.opacity(0.5))
                }
            )
    }
}

struct LaunchView: View {
    @EnvironmentObject var appModel: AppModel
    
    @Namespace var namespace
    
    @State var pageIndex = Int.random(in: 0..<5)
    @State var slide: Int = 0
    
    var body: some View {
        XStack {
            VStack {
                if slide <= 1 {
                    VStack {
                        Image("logo")
                            .resizable()
                            .matchedGeometryEffect(id: "logo", in: namespace)
                            .aspectRatio(contentMode: .fit)
                            .squareFrame(sideLength: 144)
                            .opacity(slide == 1 ? 1.0 : 0.0)
                            .offset(y: slide == 1 ? 0.0 : -16)
                        
                        VStack {
                            Text("SENTINEL")
                                .font(.title)
                                .foregroundColor(.white)
                                .padding(.bottom)
                            
                            Text("A decentralized VPN\nyou can trust.")
                                .font(.body)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                        }
                        .opacity(slide == 1 ? 1.0 : 0.0)
                        .offset(y: slide == 1 ? 0.0 : 16)
                    }
                    .animation(.easeInOut(duration: 1))
                    .transition(.asymmetric(insertion: .opacity, removal: .opacity))
                    .padding(.bottom)
                    .padding(.bottom)
                } else if slide > 1 {
                    VStack(fill: .proportionally) {
                        Image("logo")
                            .resizable()
                            .matchedGeometryEffect(id: "logo", in: namespace)
                            .aspectRatio(contentMode: .fit)
                            .squareFrame(sideLength: 92)
                            .padding(.top)
                        
                        Spacer()
                        
                        OnboardingPage(index: pageIndex)
                            .padding(.horizontal)
                            .frame(height: Screen.main.height * 0.4)
                            .opacity(slide > 2 ? 1.0 : 0.0)
                            .padding(.bottom)
                        
                        Spacer()
                        
                        Button(toggle: $appModel.isMainViewActive) {
                            ZStack {
                                LinearGradient(gradient: .init(colors: [Color.green.opacity(0.2), Color.green]), startPoint: .leading, endPoint: .trailing)
                                
                                Text("Secure Connect")
                                    .font(.body)
                                    .foregroundColor(.white)
                            }
                            .height(44)
                        }
                        .opacity(slide > 2 ? 1.0 : 0.0)
                        
                        Spacer()
                    }
                    .padding(.vertical)
                    .animation(.easeInOut(duration: 0.5))
                }
            }
            
            VStack {
                Spacer()
                
                if UIScreen.main.nativeBounds.height >= 2532 || slide == 1 {
                    if UIScreen.main.nativeBounds.height >= 2532 {
                        BuiltByDisclaimer(isVersionVisible: slide == 1)
                            .scaleEffect(slide > 1 ? 0.75 : 1.0)
                            .opacity(slide >= 1 ? 1.0 : 0.0)
                            .padding(slide == 1 ? .bottom : [])
                            .animation(.default)
                    } else {
                        BuiltByDisclaimer(isVersionVisible: slide == 1)
                            .scaleEffect(slide > 1 ? 0.75 : 1.0)
                            .opacity(slide >= 1 ? 1.0 : 0.0)
                            .padding(slide == 1 ? .bottom : [])
                            .animation(.easeInOut(duration: 1))
                            .transition(.asymmetric(insertion: .opacity, removal: .opacity))
                    }
                }
            }
        }
        .backgroundFill(BackgroundGradient())
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(750)) {
                slide = 1
                
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2.2)) {
                    slide = 2
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(400)) {
                        slide = 3
                    }
                }
            }
        }
    }
}

extension LaunchView {
    struct OnboardingPage: View {
        let index: Int
        
        static let descriptions: [String] = [
            "Sentinel is not just a VPN, it's a 'decentralized'\nopen-source, provable VPN, or a 'dVPN'.",
            "The Sentinel dVPN can prove that your\nconnection is being end-to-end encrypted with\nno exceptions.",
            "The Sentinel dVPN can prove that your\nbrowsing history and information is not being stored.",
            "The Sentinel dVPN leverages the first\nencrypted P2P bandwidth network.",
            "We hope you enjoy your ad-free dVPN\nexperience!",
        ]
        
        var body: some View {
            VStack(spacing: 0) {
                Image("info\(index + 1)")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                
                Text(Self.descriptions[index])
                    .font(.callout)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
    }
}

struct LaunchView_Previews: PreviewProvider {
    static var previews: some View {
        LaunchView()
            .environmentObject(AppModel.shared)
    }
}
