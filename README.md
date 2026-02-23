# DocUpdate Take-Home

A SwiftUI app that lets clinicians browse engagement messages, view physician info, and run compliance checks against a set of keyword rules.

## Setup

Xcode with an iOS 17+ simulator. Clone the repo, open `DocUpdate.xcodeproj`, pick a simulator, and press Command + R. All the data files (`messages.csv`, `physicians.csv`, `compliance_policies.json`) are bundled in the app so nothing extra is needed.

To run the tests, press Command + U.

## Architecture

I went with MVVM and kept the layers pretty clean. `DataLoader` handles all the CSV and JSON parsing and just returns plain Swift structs. `ComplianceEngine` is a simple struct that takes a message and returns which rules it triggered. The ViewModels sit in between and hold state, and the views just read from them.

For state management I used `@Observable` since we're on iOS 17. It's less boilerplate than `ObservableObject` and only re-renders the parts of the view that actually changed.

Data flows one way: the bundle files get parsed at launch, `MessageListViewModel` filters and sorts them based on whatever the user has selected, and when you tap into a message `MessageDetailViewModel` takes over and runs the compliance check when asked.

## Key Decisions

Compliance check runs on-device. The rules are just keyword matching so there's no reason to involve a network call. It works offline, nothing leaves the device, and it's easy to test since `ComplianceEngine` has no side effects. I added a short simulated delay so the loading state actually gets exercised in the UI.

In-memory filtering. The dataset is around 200 rows so filtering a Swift array is nearly instant. Core Data would only make sense if the data got much larger or if I needed to persist user-generated state.

No third-party dependencies. The CSV format is simple enough that a small hand-rolled parser in `DataLoader` covers it.

Explicit passing over environment injection. The `ComplianceEngine` and physician data get passed directly when navigating to the detail screen. For this scope that's clearer than putting everything in an environment object.

## What I'd Improve With More Time

- Cache the parsed data so it doesn't re-parse on every launch (matters more when backed by a real API)
- Move data loading off the main thread with async/await
- Better accessibility support: Dynamic Type, VoiceOver labels, proper tap target sizes
- More filter options: by sentiment, compliance tag, or channel
- Persist the last used filter across sessions
