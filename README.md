
![BANNER](imgs/LiftingBuddyBanner.jpg)

## About

[App Store Link](https://itunes.apple.com/us/app/lifting-buddy-workout-tracker/id1328144255?ls=1&mt=8)

Lifting Buddy is an iOS application designed to help you keep track of your workout progress.

In this readme and app, "PGM" stands for Progression Method.

## Setup

To run this application using XCode, you will need to have CocoaPods installed.

1. [Recursively clone the repository](https://stackoverflow.com/questions/3796927/how-to-git-clone-including-submodules)
1. In the project directory, run the command "pod install".
1. Open the .xcworkspace file

## Road Map:

v1.0.0 Released on December 22nd, 2017

| Process                      | Progress (Estimation) | Notes                                          |
|------------------------------|-----------------------|------------------------------------------------|
| Exercise Creation            | 9/10                  | Add nice way to choose progression method unit |
| Exercise History Tracking    | 9/10                  | Need to implement table-based history viewing  |
| Workout Start Rework         | 0/10                  | Unsure of design                               |
| Optional exercise in workout | 0/10                  | Will require realm migration; Avoiding for now |
| PGM Max -> Best Conversion.  | 0/10                  | Will require realm migration; Avoiding for now |

##### Explanations
* <b>Exercise History Tracking</b> - I want the user to be able to edit their total history in an easy way. Using a tableview for this, and it will be located in the "Edit Exercise" View
* <b>Workout Start Rework</b> - I just think it looks ugly. Not sure how to rework it.
* <b>Optional exercise in workout</b> - The user should be able to set exercises as "optional" within a workout. However, I'm still not comfortable with performing realm migrations (the app tends to crash when I attempt to do so)
* <b>PGM Max -> Best Conversion</b> - Sometimes, the user wants the lowest possible value instead of the highest possible value (think assisted pullups, etc). To do so, I want progressionmethods to have a "max/min is best" option. This also requires pgms to undergo a realm migration.

## Known Bugs
No outstanding bugs at this time.

## Future plans
* Convert relevant UIViews into ViewControllers (good practice)<br>
   Update from 11/29 -- my shower thoughts said this wasn't a good idea. Reason being that containerviewcontrollers would require the frames to be set anyway, which is what I wanted to avoid<br>
* Add "Feature Poll", a poll that users can use to vote on for the next feature<br>
* Log in to sync and backup workouts

   
#### Special Thanks
Alex Bridgeman - For giving me the idea for this application. Alex also created the splash screen and launch screen!
   
