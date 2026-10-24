# TwistChess

Chess with twists — new gamemodes, different bot difficulties, daily puzzles, and deep customization.

Built with Flutter.

## Features (planned / in progress)

- Standard chess + custom variants
- Multiple bot difficulty levels
- Daily puzzles with streaks
- Piece sets, board themes, sounds
- Offline-first

## Getting Started

This is a Flutter project.

1. Make sure you have Flutter installed: https://docs.flutter.dev/get-started/install
2. Clone the repo
3. Run `flutter pub get`
4. Run `flutter run`

For iOS IPA builds we will use cloud builders (Codemagic / GitHub Actions) so no personal Mac is required.

## Project Structure

```
lib/
  main.dart
  src/
    models/     # Game state, variants, puzzles
    screens/    # Home, Game, Puzzles, Settings
    widgets/    # Board, buttons, etc.
    theme/      # Colors, piece themes
    services/   # Storage, bot, puzzles
    utils/
```
