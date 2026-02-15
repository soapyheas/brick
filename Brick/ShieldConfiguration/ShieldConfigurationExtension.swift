import ManagedSettingsUI
import ManagedSettings
import UIKit

class ShieldConfigurationExtension: ShieldConfigurationDataSource {

    override func configuration(shielding application: Application) -> ShieldConfiguration {
        ShieldConfiguration(
            backgroundBlurStyle: .systemThickMaterial,
            backgroundColor: .black,
            icon: UIImage(systemName: "lock.fill"),
            title: ShieldConfiguration.Label(text: "App Blocked", color: .white),
            subtitle: ShieldConfiguration.Label(text: "Tap your Brick to unlock this app", color: .lightGray),
            primaryButtonLabel: ShieldConfiguration.Label(text: "OK", color: .white),
            primaryButtonBackgroundColor: .darkGray
        )
    }

    override func configuration(shielding application: Application, in category: ActivityCategory) -> ShieldConfiguration {
        configuration(shielding: application)
    }

    override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
        ShieldConfiguration(
            backgroundBlurStyle: .systemThickMaterial,
            backgroundColor: .black,
            icon: UIImage(systemName: "lock.fill"),
            title: ShieldConfiguration.Label(text: "Website Blocked", color: .white),
            subtitle: ShieldConfiguration.Label(text: "Tap your Brick to unlock", color: .lightGray),
            primaryButtonLabel: ShieldConfiguration.Label(text: "OK", color: .white),
            primaryButtonBackgroundColor: .darkGray
        )
    }

    override func configuration(shielding webDomain: WebDomain, in category: ActivityCategory) -> ShieldConfiguration {
        configuration(shielding: webDomain)
    }
}
