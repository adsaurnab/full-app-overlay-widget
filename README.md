# Flutter App Overlay

This app is for a list of overlay items which come and goes with animation above the whole mobile application. 

## Features:

- list item has a close button and a string details which shows max 2 lines, where the close button removes the item from overlay list.
- only shows 3 as default item which can be changed by passing value to parameter ('showItemsNumber').
- there is a clear all button which comes when overlay items is more than 'showItemsNumber'.
- current version supports right to left slide animation when data is added and bottom to top size transition when removing an item.
- overlayKey is a default key for the OverlayAnimationWidget with which you can add and remove and clear items from overlay list, and also you can access any function within the OverlayAnimationWidget.
- OverlayBaseClassWidget is the main widget to go within the builder.
- ** currently design modification parameters are not provided, which will be added in the future **.
- custom align of the overlay can be passed through parameters. e.g:  stickTopLeft, stickTopRight, stickBottomLeft, stickBottomRight [ default is stickTopRight ]
- animation for all alignment is same.


## Usage

- First create a builder in main MaterialApp or other similar MaterialApp
```dart
builder: (context, child) {
    return OverlayBaseClassWidget(
        overlayWidth: 250,
        /// number of items to be shown
        // showItemsNumber: 20,
        /// default is top right alignment
        /// stick to bottom left 
        // stickBottomLeft: true,
        /// stick to top left 
        // stickTopLeft: true,
        /// stick to bottom right 
        // stickBottomRight: true,
        child: child,
    );
},
```

- to add data to overlay widgets - "" the data is the data to be added to the overlay list which should be a string ""
```dart
  overlayKey.currentState?.add( data );
```

- to remove data to overlay widgets - "" the index is the index of removed item ""
```dart
  overlayKey.currentState?.remove(index);
```

- currently only string is supported for overlay items.








