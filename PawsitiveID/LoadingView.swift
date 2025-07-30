//
//  LoadingView.swift
//  PawsitiveID
//
//  Created by David Bradshaw on 7/28/25.
//

import SwiftUI

struct LoadingView: View {
    @State private var animate: Bool = false
    
    var body: some View {
        HStack {
            Spacer()
            Circle()
                .trim(from: 0, to: 0.7)
                .stroke(.primary, lineWidth: 5)
                .frame(width: 50, height: 50)
                .padding(.vertical)
                .rotationEffect(Angle(degrees: animate ? 360 : 0))
                .foregroundStyle(Color("Accent"))
                .animation(
                    .linear(duration: 0.8).repeatForever(autoreverses: false),
                    value: animate
                )
                .onAppear {
                    self.animate.toggle()
                }
            Spacer()
        }
    }
}

#Preview {
    LoadingView()
}
