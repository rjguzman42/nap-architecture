# nap-architecture
iOS architecture for networking, analytics, and persistence 

# Networking
The networking files a facade design that handles networking tasks like persistency, server API, and HTTP connections in one unified class. The Facade design pattern provides a single interface to a complex subsystem that handles all data. Instead of exposing the user to a set of classes and their APIs, you only expose one simple unified API - called the LibraryAPI. Call a function such as 'LibraryAPI.shared.getCourse()' from anywhere in your app and the LIbraryAPI class will handle the data management.

# Analytics
Here are some of the benefits of creating AnalyticsEvent as protocol
 
 Semantically appropriate event definition
    -> Each layer of your app can define its own types (whether an enum, class, or struct) that conform to the AnalyticEvent protocol. Perhaps your Networking layer defines events that capture how often it has to hit the network versus how often it has to hit the cache. It can define those in its own custom NetworkingEvent: AnalyticEvent type.
 
 Minimized callsites
    -> By having each layer define its own type, it can create minimized initializers for its custom AnalyticEvent that would be impractical to do with an enum, and cumbersome with a struct. For example, if I had a UserSessionEvent: AnalyticEvent, I could create an initializer that takes a LoginFailureReason as the parameter, and then the initializer turns it in to the privately-known name and payload.
 
 Type checking events
    -> I could create a whole bunch of extensions on an AnalyticsEvent struct to do the custom initializer for the struct that is contextually appropriate for the callsite, but that explodes the numbers of initializers I have to sort through when creating an AnalyticsEvent. The autocomplete would show me every possible initializer for every possible event type, which is a total pain.
    -> On the other hand, by requiring a custom type that adopts the AnalyticsEvent protocol, I can narrow my focus down to only the autocompletion results that are possible for a UserSessionEvent or a NetworkingEvent or a AwesomeCarouselWidgetInteractionEvent, etc.
    -> With this sort of type-checking in place, refactoring these events also becomes easy. I can search the codebase for just NetworkingEvent to see every place where that type of event is getting generated.
 
 Easy extensibility
    -> Since AnalyticEvent is a protocol, adding a new kind of event is trivial. I don’t have to add a new case to an enum. I don’t have to litter stringly-typed event names throughout my code. I don’t have to add another extension to a struct. The protocol makes it easy to isolate concerns to their respective layers.
    
# Persistence
