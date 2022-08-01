import SwiftUI

struct ContentView: View {
    var body: some View {

        // example
        HapticsWebView(url: "https://yours.com", clearCache: true)
            .edgesIgnoringSafeArea([.top, .bottom])
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
