# TimeTracker - Unidirectional Data Flow test project

This is a sandbox project to come up with an entry level unidirectional data flow app, __without__ using any frameworks. The end goal is to come up with a very simple architecture that both communicates the core principles behind unidirectional data flow, and is safe to publish as a tutorial (ie in case developers drop it into their own projects as is). 

The app uses Realm for state storage, and only attempts to show a unidirectional flow relating to a single view. Navigation/Routing is a whole other bag of hurt.

## Core Components

1. `Store`: This is a wrapper around the realm instance, manages state updates & change notifications. A global instance is declared with the name `store`.
2. `StoreSubscriber`: A protocol enabling subscription to state changes.
3. `Action`: An enum with a case for each state change action that can be performed on the store
4. `Project` & `Activity`: The models, Realm Object subclasses.
5. `ViewController`: A UITableViewController that handles displaying and editing the projects items.

## Smells/alternatives/stuff not done that maybe should be

* Global `store` variable - most Cocoa devs would maybe be more comfortable with a singleton?
* The weak hashset subscriber implementation - this was the simplest implementation I could think of, but it doesn’t necessarily mean it’s the simplest to understand. Maybe an NSNotification or a single delegate would be sufficient to illustrate the concepts.
* The reducer functions are defined as private functions in the `Store` class. This isn’t how it’s normally done, but it seems to make more sense to me to do it this way given its a DB update rather than a transform over a value type.
* Materialising the Realm `allObjects` as an array. Again, this seems to make the most sense in the context of this app, but most apps will have a more complex app state, and the db may be large enough that 
* (related) If I were doing a real app in this style, I’d most likely just publish value types in the App State and keep the Realm Objects private, although in this instance it would add a fair bit of code for little value.
* No thread-handling, although under this design it’s relatively straightforward to confine the realm updates to a specific queue and it might be good to add this at the end of the tutorial.

I’ll obviously want to point people to the frameworks at the end (esp reactive frameworks rather than writing your own multicast events). This is still a work in progress so I’m open to suggestions & improvements.