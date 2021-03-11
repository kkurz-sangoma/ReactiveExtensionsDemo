# Basic Reactive Extensions Demo in Swift

This demo was created for a Kaizen talk given on 3.11.21 about Reactive Extension basics. It demonstrates how to perform some basic operations on data using RxSwift and RxDataSources. Several tags are included to simplify finding your way around:

## 1_podInstall

This tag is just a basic iOS project with `RxSwift` and `RxDataSources` included. No code is implemented, but it shows how to bring the dependency into your repository.

## 2_contactTableView

This tag implements contact parsing within `AppDelegate.swift` and emits `onNext` on several observables. The main view has been converted to a UITableViewController and it consumes the `contactList` observable as a list of items to populate the cells of the table. 

## 3_sectionsSortingSelection

As an improvement to the previous tag, this commit converts the table view to using an `RxDataSources` sectioned list, which allows the user to scroll to specific indexes and resort the list by first or last name. Also implemented is tap response to each cell, which provides a pop-up detailing what item was tapped.

## 4_contactsUpdate

Building on the last tag, this tag adds an update to the contactDictionary 15s after launching, showing how easy it is (e.g. no additional code) to react to changes in the data source for display. When the contacts are updated, the table updates immediately with no additional code in the view controller.

### A note on signing

This was initially implemented as an internal demo, so building from each tag will require updating signing locally.