# Curbify

Curbify is a modern valet management application built with Flutter. It streamlines the process of vehicle check-in, tracking, and retrieval, providing a seamless experience for both valet attendants and customers.

## Features

- **Digital Ticketing:** Quickly create and manage digital tickets for parked vehicles.
- **Real-time Requests:** Customers can request their vehicles via SMS, and requests appear in the app in real-time.
- **SMS Notifications:** Integrated with Twilio for sending confirmations and notifications to customers.
- **Secure Payments:** Utilizes Stripe for handling payments for valet services.
- **Damage Logging:** Attendants can capture images of vehicles from multiple angles to log any pre-existing damages.
- **Theme Support:** Includes both light and dark themes for user comfort.
- **Firebase Integration:** Uses Firebase Realtime Database for data storage and Firebase Authentication for user management.

## Getting Started

Follow these instructions to get a copy of the project up and running on your local machine for development and testing purposes.

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- A code editor like [VS Code](https://code.visualstudio.com/) or [Android Studio](https://developer.android.com/studio).
- A Firebase project.
- Accounts for Stripe and Twilio.

### Installation

1.  **Clone the repository:**
    ```sh
    git clone https://github.com/Jashzander/Curbify.git
    cd Curbify
    ```

2.  **Install dependencies:**
    ```sh
    flutter pub get
    ```

3.  **Setup Environment Variables:**
    Create a `.env` file in the root of the project and add the following keys. This file is included in `.gitignore` and should not be committed to version control.

    ```
    STRIPE_API_KEY=your_stripe_secret_key
    TWILIO_ACCOUNT_SID=your_twilio_account_sid
    TWILIO_AUTH_TOKEN=your_twilio_auth_token
    TWILIO_NUMBER=your_twilio_phone_number
    ```

4. **Setup Firebase:**
   - Follow the instructions to add Firebase to your Flutter app for [iOS](https://firebase.google.com/docs/flutter/setup?platform=ios) and [Android](https://firebase.google.com/docs/flutter/setup?platform=android).
   - Place your `GoogleService-Info.plist` in `ios/Runner/` and `google-services.json` in `android/app/`.


### Running the Application

To run the application, use the following command:
```sh
flutter run
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
