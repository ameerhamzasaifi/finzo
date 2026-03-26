<div align="center">

<img src="assets/laucher_icon_img/F.png" alt="Finzo logo" width="80"/>

<br/>

<h1>Finzo</h1>

**Offline Personal Finance Manager**

[![GitHub release (latest by date)](https://img.shields.io/github/v/release/ameerhamzasaifi/finzo)](https://github.com/ameerhamzasaifi/finzo/releases)
![Platforms](https://img.shields.io/badge/platform-android%2C%20ios-yellowgreen)
[![License](https://img.shields.io/github/license/ameerhamzasaifi/finzo)](LICENSE)

<br/>

<a href="https://github.com/ameerhamzasaifi/finzo/releases">
  <img src="https://img.shields.io/badge/Download-Latest%20Release-blue?style=for-the-badge&logo=github" alt="Download"/>
</a>

</div>

<br/>

## Finzo

Finzo is a fully offline, open-source personal finance app built with Flutter. It manages your money, tracks budgets, loans, investments, and credit cards — all stored locally on your device in SQLite. No servers, no subscriptions, no data leaves your phone.

### Key Features

- **Dashboard**: Net balance, income vs expense summary, and recent transactions at a glance.
- **Transactions**: Income and expense tracking with categories, search, and date-based grouping.
- **Budgets**: Monthly category-based budgets with spending progress and over-budget alerts.
- **Accounts**: Manage multiple bank accounts and wallets with color-coded icons.
- **Loans & EMI**: Track 8 loan types (home, car, education, gold, etc.) with auto-EMI expense generation.
- **Investments**: Monitor 9 asset types (stocks, mutual funds, crypto, FD, PPF, etc.) with gain/loss tracking.
- **Credit Cards**: Track limits, utilization, billing/due dates with high-utilization warnings.
- **Reports**: Monthly trends and category breakdowns with interactive charts.
- **Multi-Book**: Create separate finance books for different purposes, switch or import anytime.
- **Multi-Currency**: 15+ currencies with proper locale formatting.
- **Works Offline**: Everything runs locally. No internet required, ever.

### Under the Hood

- **Flutter** — Cross-platform UI framework (Android, iOS, Linux, Windows, macOS)
- **SQLite (sqflite)** — Local database, stored as portable `.books.db` files
- **Provider** — Reactive state management
- **fl_chart** — Pie and bar charts for reports
- **Google Fonts (Poppins)** — Clean typography
- **Flutter Animate** — Smooth UI animations

## Setup

### Install

Download the latest build from the [releases page](https://github.com/ameerhamzasaifi/finzo/releases).

### Build from Source

```bash
git clone https://github.com/ameerhamzasaifi/finzo.git
cd finzo
flutter pub get
flutter run
```

Requires Flutter SDK with Dart `^3.11.1`.

## Data & Storage

Finzo stores databases in a user-accessible location:

| Platform | Path |
|----------|------|
| Android | `/storage/emulated/0/Documents/finzo/` |
| iOS / macOS | App Documents/finzo/ |

Each finance book is a standalone `.books.db` SQLite file. Back up, share, or import them freely.

## Contributing

1. [Raise an issue](https://github.com/ameerhamzasaifi/finzo/issues/new) for bugs or feature requests.
2. Fork → branch → make changes → open a PR.

## License

[MIT](LICENSE)
