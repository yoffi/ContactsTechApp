# iOS Technical test

## Subject

Build an app taht fetches data from this service : randomuser.me

### Goal of the app

- Use https://randomuser.me/api/?results=10 to get 10 contacts for eachapi call
- Like most lists, implement infinite scroll
- Reload of the list of users should be possible
- The app must handles connectivity issues and displays the complete last results received if it can't retrieve one at launch.
- Touching an item on the list should make appear a detail page listing every attribute.

### Technical implementation constraint:

- The app must be in Swift.
- Any third-party libraries are allowed but the choice must be justified.
- Controllers should be made without storyboard or any xib.
- SwiftUI is not allowed.


## Implementation


### Architecture

For this project I have used a clean architecture style with in mind separation of concern and testability. With three main layer describe like so :

- Core Layer (Tools, Helper, Design System)
- Domain Layer (Business logic, app services, repository, etc..)
- Feature Layer (Each feature have is own folder, with a presentation part for UI, and ViewModel for feature / presentation own logic)
  - Feature A
    - Presentation A
        - FeatureAViewController
        - FeatureAViews
        - ...
    - FeatureAViewModel
  - Coordinator / Factory
  
Where the dependency can be read top to bottom. In other world Core Layer don't depends to anything. Domain Layer depends to Core Layer, and Feature Layer depends to Domain Layer.

I've made this choice based on my understanding of the vertical team arrangement at your company. From what I understand, some teams work on core/fundamental code bases, others focus on domain-specific areas, and the rest implement features. While I've made some assumptions here, I believe this provides a good foundation to start a project that can evolve and scale as multiple developers maintain the codebase.

An other important point, for testability and a true separation of concern, I use dependency injection, factory. This allow to avoid regression, prevent any unwanted changes.

Also to go further, we could eventually put each Layer into a SPM (local or remote) and even each feature could have is own SPM. It would definilty even more accentuate clear separation. But also could improve build time.

For the UI part in the Presentation Layer, I'm using MVVM UI Pattern since is what you seems to use yourself.

An another benefit of this architecture is that the UI part is independent of the rest. So it could be build with UIKit or SWiftUI. And follow any Pattern UI that the team choose to go with. Even a mix or progressive adoption to SwiftUI could be considered.

