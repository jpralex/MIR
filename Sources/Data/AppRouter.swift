import Foundation

/// Permite volver a la pantalla de inicio desde cualquier punto profundo de
/// la navegación (por ejemplo, tras terminar un examen) sin reestructurar
/// toda la app a NavigationPath. Al incrementar `resetToken`, `HomeView`
/// vuelve a crear su `NavigationStack` desde cero, lo que la devuelve a la raíz.
@MainActor
final class AppRouter: ObservableObject {
    @Published private(set) var resetToken = 0

    func returnToHome() {
        resetToken += 1
    }
}
