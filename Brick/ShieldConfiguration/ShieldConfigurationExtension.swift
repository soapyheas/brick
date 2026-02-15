import ManagedSettingsUI
import ManagedSettings
import UIKit

class ShieldConfigurationExtension: ShieldConfigurationDataSource {

    private var pink: UIColor {
        UIColor(red: 0.85, green: 0.45, blue: 0.55, alpha: 1.0)
    }

    private var lavender: UIColor {
        UIColor(red: 0.62, green: 0.52, blue: 0.82, alpha: 1.0)
    }

    private var cream: UIColor {
        UIColor(red: 0.97, green: 0.95, blue: 0.92, alpha: 1.0)
    }

    override func configuration(shielding application: Application) -> ShieldConfiguration {
        ShieldConfiguration(
            backgroundBlurStyle: .systemUltraThinMaterial,
            backgroundColor: cream,
            icon: UIImage(systemName: "lock.fill"),
            title: ShieldConfiguration.Label(text: "nope not this app", color: pink),
            subtitle: ShieldConfiguration.Label(text: "go touch grass to unlock", color: lavender),
            primaryButtonLabel: ShieldConfiguration.Label(text: "ok fine", color: .white),
            primaryButtonBackgroundColor: pink
        )
    }

    override func configuration(shielding application: Application, in category: ActivityCategory) -> ShieldConfiguration {
        configuration(shielding: application)
    }

    override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
        ShieldConfiguration(
            backgroundBlurStyle: .systemUltraThinMaterial,
            backgroundColor: cream,
            icon: UIImage(systemName: "lock.fill"),
            title: ShieldConfiguration.Label(text: "this site is blocked", color: pink),
            subtitle: ShieldConfiguration.Label(text: "go touch grass to unlock", color: lavender),
            primaryButtonLabel: ShieldConfiguration.Label(text: "ok fine", color: .white),
            primaryButtonBackgroundColor: pink
        )
    }

    override func configuration(shielding webDomain: WebDomain, in category: ActivityCategory) -> ShieldConfiguration {
        configuration(shielding: webDomain)
    }
}
