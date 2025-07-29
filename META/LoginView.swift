import SwiftUI

struct BackgroundView: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.white

                // Blue trapezoid
                Path { path in
                    let w = geometry.size.width
                    let h = geometry.size.height
                    path.move(to: CGPoint(x: w * 0.6, y: 0))
                    path.addLine(to: CGPoint(x: w, y: 0))
                    path.addLine(to: CGPoint(x: w, y: h))
                    path.addLine(to: CGPoint(x: w * 0.4, y: h))
                    path.closeSubpath()
                }
                .fill(Color(red: 0.0, green: 0.33, blue: 0.61))

                // Red stripe
                Path { path in
                    let w = geometry.size.width
                    let h = geometry.size.height
                    path.move(to: CGPoint(x: w * 0.57, y: 0))
                    path.addLine(to: CGPoint(x: w * 0.63, y: 0))
                    path.addLine(to: CGPoint(x: w * 0.43, y: h))
                    path.addLine(to: CGPoint(x: w * 0.37, y: h))
                    path.closeSubpath()
                }
                .fill(Color(red: 1.0, green: 0.27, blue: 0.27))
            }
            .ignoresSafeArea(.all)
        }
    }
}



struct LoginView: View {
    @State private var username = ""
    @State private var password = ""
    @State private var navigate = false

    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundView()

                HStack {
//                    
                    VStack {
                        Image("LoginIcon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 800, height: 800)
                            .padding(.bottom, 10)
                            .offset(x:-200)

                    }
                    .padding(.leading, 60)
                    .frame(maxWidth: .infinity, alignment: .center)
//
                    // Login Form
                    VStack(spacing: 20) {
                        Text("Login")
                            .padding(.top, 100)
                            .font(.largeTitle)
                            .bold()
                            .foregroundColor(Color(red: 0.0, green: 0.33, blue: 0.61))
                            .frame(maxWidth: .infinity, alignment: .center)
//                            .padding(.bottom, 30)
                        
                        

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Username")
                                .font(.headline)
                                .foregroundColor(Color(red: 0.0, green: 0.33, blue: 0.61))
                            TextField("", text: $username)
                                .padding()
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                .shadow(radius: 1)
                                .foregroundColor(Color.black)
                        }
//
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Password")
                                .font(.headline)
                                .foregroundColor(Color(red: 0.0, green: 0.33, blue: 0.61))
                            SecureField("", text: $password)
                                .padding()
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                .shadow(radius: 1)
                                .foregroundColor(Color.black)
                        }
//
//                        
                        NavigationLink(destination: ContentView(), isActive: $navigate) {
                            EmptyView()
                        }.hidden()
//
//
                        
                        HStack {
                            Button(action: {
                                navigate = true
                            }) {
                                Text("Login")
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color(red: 0.0, green: 0.33, blue: 0.61))
                                    .padding(.horizontal, 30)
                                    .padding(.vertical, 10)
                            }
                            .background(Color.white)
                            .clipShape(Capsule())
                            .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
                        }
                        .padding(.top, 70)
                        .frame(maxWidth: .infinity, alignment: .center)
                        
                        Spacer()
                        
                    }
                    .padding(30)
                    .frame(width: 500, height: 600)
                    .background(Color(.white).opacity(0.7))
                    .cornerRadius(20)
                    
                    .padding(.trailing, 100)
                }
            }
        }
    }
}

#Preview {
    LoginView()
        .frame(width: 1800,height: 1200)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
}
