# GRSF Mobile App

A Flutter-based mobile application for browsing the Global Record of Stocks and Fisheries (GRSF) database. This app provides a user-friendly interface to access and explore data on fisheries, stocks, species, fishing areas, and gear types.

## Key Features

*   **Browse GRSF Data:** Easily navigate through various categories of the GRSF database.
    *   **Stocks:** View detailed information about different fish stocks.
    *   **Fisheries:** Explore data related to various fisheries.
    *   **Species:** Get information on different aquatic species.
    *   **Areas:** Browse geographical areas related to fisheries.
    *   **Fishing Gears:** Learn about different types of fishing gear.
*   **Offline Access:** The app uses a local SQLite database to store the GRSF data, allowing for offline access once the data is synced.
*   **Data Synchronization:** Keep the local database up-to-date by syncing with a remote data source.
*   **Search Functionality:** Search for specific stocks and fisheries.
*   **Sort and Filter:** Sort and filter the data to easily find the information you need.

## Getting Started

### Prerequisites

*   Flutter SDK: [Install Flutter](https://flutter.dev/docs/get-started/install)
*   An editor like VS Code or Android Studio.

### Installation

1.  **Clone the repository:**
    git clone https://github.com/your-username/grsfApp.git
    cd grsfApp

2.  **Install dependencies:**
    flutter pub get

3.  **Run the app:**
    flutter run

## Dependencies

The app uses the following key packages:

*   `flutter`: The UI toolkit.
*   `sqflite`: For local database storage.
*   `path_provider`: To find the correct path for the local database.
*   `csv`: To parse data from CSV files.
*   `http`: For making HTTP requests to sync data.
*   `dropdown_button2`: For advanced dropdown widget.
*   `url_launcher`: To launch URLs.

## Project Structure

The project is organized as follows:

```
lib/
├── models/       # Data models for the database tables
├── pages/        # UI screens for different app sections
├── services/     # Services for database and CSV handling
├── widgets/      # Reusable UI components
└── main.dart     # The main entry point of the app
```
