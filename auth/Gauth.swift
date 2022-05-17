import SwiftUI
import GoogleSignIn
import Firebase
import FirebaseAuth

class Gauth: ObservableObject {
    @Published var gstate = false
    @Published var err: Color = Color.white
    
    func change() {
        withAnimation{ gstate.toggle() }
        UserDefaults.standard.set("", forKey: "Guser")
    }
    
    func signIn() {
    withAnimation{ self.err = .green }
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        withAnimation{ self.err = .white }
    }
      if GIDSignIn.sharedInstance.hasPreviousSignIn() {
        GIDSignIn.sharedInstance.restorePreviousSignIn { [unowned self] user, error in
            if error != nil {
                print("Error with Previous Sign in Discovery.")
                return
            }
            print("Found previous Sign In. User: \(user?.userID ?? ""). Authenticating... ")
            authenticateUser(for: user, with: error)
        }
      } else {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        let configuration = GIDConfiguration(clientID: clientID)
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        guard let rootViewController = windowScene.windows.first?.rootViewController else { return }
        GIDSignIn.sharedInstance.signIn(with: configuration, presenting: rootViewController) { [unowned self] user, error in
          authenticateUser(for: user, with: error)
        }
      }
    }
    
    private func authenticateUser(for user: GIDGoogleUser?, with error: Error?) {
      if let error = error {
          print("Authenticate User Error Block")
        print(error.localizedDescription)
        return
      }
      guard let authentication = user?.authentication, let idToken = authentication.idToken else {
          print("ID Authentication Token Error")
          return
      }
      let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: authentication.accessToken)
      Auth.auth().signIn(with: credential) { [unowned self] (users, error) in
        if let error = error {
            print("Actual Sign in Error")
          print(error.localizedDescription)
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { withAnimation{
                self.gstate = true
                self.err = .white
            }}
            let ue = Auth.auth().currentUser?.uid ?? ""
            print("Setting user defaults for Guser: \(ue)")
            UserDefaults.standard.set(ue, forKey: "Guser")
        }
      }
    }
    
    func signOut() {
      GIDSignIn.sharedInstance.signOut()
      do {
        try Auth.auth().signOut()
          print("Signing out")
        self.change()
      } catch {
          print("Signing out error")
        print(error.localizedDescription)
      }
    }
}
