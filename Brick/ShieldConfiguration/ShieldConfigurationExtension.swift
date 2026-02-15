import ManagedSettingsUI
import ManagedSettings
import UIKit

class ShieldConfigurationExtension: ShieldConfigurationDataSource {

    private var pink: UIColor {
        UIColor(red: 1.0, green: 0.42, blue: 0.62, alpha: 1.0)
    }

    private var lavender: UIColor {
        UIColor(red: 0.72, green: 0.53, blue: 0.98, alpha: 1.0)
    }

    private var cream: UIColor {
        UIColor(red: 1.0, green: 0.97, blue: 0.93, alpha: 1.0)
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
