# Experiment 10: User Authentication using Firestore

## Aim
To design and develop a Flutter application that implements a secure User Login System using email and password credentials stored in Google Cloud Firestore with proper validation and a professional user interface.

## Security & Architecture Highlights
- **Secure Password Hashing**:
  - Implements salted cryptographic hashing (`SHA-256`) using the `crypto` library to ensure plaintext passwords are never saved into Firestore.
- **Form Validation**:
  - Email format validation with standard RFC regex patterns.
  - Password minimum length and strength criteria.
  - Password and Confirm Password equality matching during Sign Up.
- **Firestore Authentication Flow**:
  - **Sign Up**: Checks if user already exists in Firestore `users` collection. If not, persists document with `fullName`, `email`, `passwordHash`, and server timestamp.
  - **Sign In**: Queries Firestore matching normalized email and computed password hash. On verification, generates active session and loads user model.
- **Professional UI Experience**:
  - Sleek gradient background with elevated material card.
  - Tabbed segment toggle for switching between Sign In and Sign Up.
  - Obscure password toggles for privacy.
  - Authenticated user dashboard with user details and logout functionality.

## How to Run
```bash
cd exp10
flutter pub get
flutter run
```
