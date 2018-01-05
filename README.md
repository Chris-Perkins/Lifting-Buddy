
![BANNER](imgs/LiftingBuddyBanner.jpg)

## About

  View Summaries             |  Graph Progress              | Edit Easily
:---------------------------:|:----------------------------:|:----------------------------:
![Summary](imgs/Summary.jpg) | ![Graph](imgs/Graph.jpg)     | ![Edit](imgs/Edit.jpg)


<b>Lifting Buddy is an iOS application designed to help you keep track of your workout progress.</b>

In this readme and app, "PGM" stands for Progression Method.

[App Store Link](https://itunes.apple.com/us/app/lifting-buddy-workout-tracker/id1328144255?ls=1&mt=8)

## Setup

To run this application using XCode, you will need to have CocoaPods installed.

1. [Recursively clone the repository](https://stackoverflow.com/questions/3796927/how-to-git-clone-including-submodules)
1. In the project directory, run the command "pod install".
1. Open the .xcworkspace file

## Road Map:

The below roadmap is not in "order of implementation"; I generally work on what I want to.

  Process                    | Step | Notes
:---------------------------:|:----:|:-------------------------------------------------------:
Exercise Creation | 9/10 | Add nice way to choose progression method unit
Workout Tab Cell Rework | 0/10 | Add label for completed count + days of the week sched
Workout Start Rework | 0/10 | Unsure of design
Optional exercise in workout | 0/10 | Will require realm migration; Avoiding for now
PGM Max -> Best Conversion | 0/10 | Will require realm migration; Avoiding for now
Label title rework | 0/10 | Current title label colors are ugly, but unsure of fix
Last session comparison graph | 0/10 | Will display graph in summary view most likely.
Color Themes | 0/10 | Should be easy to implement using UserDefaults
Literal -> Localized Strings | 0/10 | Good for speedy implementation and clean code.

##### Explanations
* <b>Workout Start Rework</b> - I just think it looks ugly. Not sure how to rework it.
* <b>Workout Tab Cell Rework</b> - Current implementation is pretty mundane. Going to make each view more useful.
* <b>Optional exercise in workout</b> - The user should be able to set exercises as "optional" within a workout. However, I'm still not comfortable with performing realm migrations (the app tends to crash when I attempt to do so)
* <b>PGM Max -> Best Conversion</b> - Sometimes, the user wants the lowest possible value instead of the highest possible value (think assisted pullups, etc). To do so, I want progressionmethods to have a "max/min is best" option. This also requires pgms to undergo a realm migration.
* <b>Label title rework</b> - I feel like the title labels are pretty ugly. I plan on replacing the app text of "Lifting Buddy" to be more telling (e.g. change "Lifting Buddy" title label text to "Create Workout". Unsure of this design at the moment. I would prefer to just find a color scheme that works and works well.
* <b>Last session comparison graph</b> - Would be neat to graph the previous session's results compared to current session results. Would likely be implemented in the summary view as a button.
* <b>Color Themes</b> - Thought of as a future plan, then recommended again by a user. Based on current app, this shouldn't be too hard to change.
* <b>Literal -> Localized Strings</b> - This would help if the app were ever translated and would also help reduce app size

## Known Bugs
* HIGH
	* No high priority bugs at this time 
* MEDIUM
	* No medium priority bugs at this time
* LOW [Can workaround]
	* No low priority bugs at this time

## Future plans
* Convert relevant UIViews into ViewControllers (good practice)<br>
   Update from 11/29 -- my shower thoughts said this wasn't a good idea. Reason being that containerviewcontrollers would require the frames to be set anyway, which is what I wanted to avoid<br>
* Add "Feature Poll", a poll that users can use to vote on for the next feature<br>
* Log in to sync and backup workouts

   
#### Special Thanks
Alex Bridgeman - For giving me the idea for this application. Alex also created the splash screen and launch screen!
   
