# School Project Storage

I am keeping some of my more interesting school projects here.
Each folder is an independant project.
Does not include large projects or group projects.

Almost all of these were only tested/used on Linux.

# Programs by Language

## C

### MouseMaze
Reads in a maze from a txt file and determines if it can be solved.

## Processing

### Graphics/ShapesAndNormals
A project with many different settings for model, colour, and rotation.
Focuses on rendering shapes without using libraries, such as drawing
lines pixel-by-pixel using an algorithm, filling triangles with a scanline algorithm, and
different shading methods.
The code for rotation and the sphere were provided and I did not write those.

Controls can be found in DrawingModes.pde, and spacebar toggles rotation for triangles.

### Graphics/Transformations

Focus on applying transformations using raw matrices versus library functions to scale, rotate, etc.
Three modes: a test pattern, a pattern of drawings made with hierarchical rendering, and a field of 3D stars.

Controls can be found in DrawingModesA2.pde.

### Graphics/ShooterGame

A top-down shooter game that served as an exercise in camera perspectives, particle systems, and texturing.
Game can have its textures turned off, and camera can swap between orthographic and persepective without breaking the game.

Controls can be found in Modes.pde.

## Java

### LeftJoin
Program made to simulate an SQL style join on two given input files.
It was made without using any relevant library functions to work the data.

### FullJoin
A modified version of above to create a full join.

### EventDrivenCarDepot
An event simulation that makes a schedule for renting out cars and events.

## Python

### Distributed Computing/MultiThreadServer
A very basic webserver that uses multiple threads to handle input.
Also my very first time using javascript and html since they did not tell us anything in class.

### Distributed Computing/PeerNode
A peer node for a now defunct network that aimed to simulate a
modified version of the byzantine generals problem.

### Distributed Computing/WorkerQueue
A simple queue where clients can send 'jobs' to the server, which then doles them out to
workers.  The workers then send back to the server when the job is processed.

Jobs consist of a string, which are processed by workers at one word per second.