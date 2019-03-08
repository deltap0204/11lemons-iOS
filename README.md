# 11lemons: Installation Steps


1) Clone this repo.

2) Make sure that `cocoapods` is installed using command in the Terminal: `pod --version`. If not installed, use `sudo gem install cocoapods` command.

3) Open Terminal, go to the `lemonapp` dir. Run `pod install` command.

4) Open `lemonapp.xcworkspace` file.

5) By clicking Run button you should be able to run the app on the simulator.


# 11lemons: Creating TestFlight Build

1) Make sure, that there is an appropriate distribution provision profile and developer certificate.

2) Select the Target that should be build, on the General tab check `Build` and `Version` values. Every next build should have incremented build number (incrementing version is optional, but recommended).

3) Select the appropriale target and set device to `Generic iOS Device`.

4) Run Product - Archive. (After finishing the archiving process the Organizer window will appear)

5) Tap `Upload to App Store`.

6) Select `11LEMONS LLC` development team (if prompted).

7) Tap `Upload`. After a couple of minutes the process will be completed. And the build will appear after Apple internal review, which usually takes about one hour. 