# bleplaybacksample
A sample code to demonstrate how to start the playback over Bluetooth Low Energy communication.

BLEPeripheralApp - iOS app which represents a generic BLE hardware device (i.e headphones)
BLECentralApp - iOS app represents the audio playback application

Setup:
- Install BLEPeripheralApp on one of the iOS devices
- Install BLECentralApp on another iOS device
- Launch both applications
- Press "start service" in BLEPeripheralApp in order to start advertising GATT BLE service with GATT charactestic, make sure the state switches to "Advertising"
- Press "connect to peripheral" in BLECentralApp in order to connect to advertised GATT BLE service in BLEPeripheralApp
- Make sure that state is set to "Connected" for both applications
- Now you can trigger "Start normal playback", "Start mixin playback", "Stop playback" in BLEPeripheralApp
- In the end, press "stop service" in BLEPeripheralApp
