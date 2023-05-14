---
title: 'Less is Store'
tags: ["devlog", "technical devlog", "jam"]
date: 2023-05-13 14:00:00
emoji: "🛍️"
---

Welcome to the devlog for "Less is Store" (@TODO: link). This game was created for the GoGodot Jam (iteration 4).

Originally, I made an entirely different idea for this game jam. But my laptop is old and broken, and that idea was 3D ... so after a few days, it just gave up. It crashed all the time, out of nowhere. And even if it didn't, it was just too _slow_ and _laggy_ to stay motivated and productive.

So I hastily came up with this new idea: "Less is store". Which was 2D and _even simpler_, so it had to be fine.

## What's the idea?

The theme of the jam was "Less is More". When considering different genres, I stumbled upon the "tycoon" / "management" genre.

Usually, you start with _nothing_ (an empty plot of land, no money, etcetera) and have to build it into _something big_.

What if we reverse that?

You start with a big store and lots of money. You want to _empty_ the store (of machines/tables/whatever) and earn as _little_ money as possible.

That ... that was the whole idea.

## Step 1: a random shop

For this, I use a trick I learned some time ago (while experimenting with random generation for my board games).

* Start with an empty grid
* Assign each cell a random "weight"
* Ask a few imaginary entities to walk through this grid. (I use the built-in A* implementation of Godot. Very fast and simple to setup.)
* The path they walk is marked as "empty" (and contains nothing)
* Random cells _next_ to that path are turned into obstacles (such as tables within the store from which items can be bought)

Repeat this until (at least) X% of the whole grid is _filled_, and you're done.

Because the cells have random weights, the "pathfinding" algorithm will not necessarily pick the shortest path from one edge to another. It will deviate a bit, creating some corners and a more organic layout.

But because you mark the whole path as "must be empty", you are _sure_ that all areas of the store can be reached and have a pathway leading to it.

Implementation detail 1: I first generate the whole map, and only then _draw_ it on one go. Mixing code/structure and drawing/graphics is basically _never_ a good idea. Keeping it as two clearly separate steps prevents all sorts of nasty issues.

All the data about the cells is kept inside a `CellData` object. The visual representation is simply a node that adds some sprites/animations/extra logic, _and_ has a variable called `data` that holds the original object.

Nearly 100% of the code in the game modifies the `CellData` data structure in the background. After every modification, I call `sync_visuals_to_data` (a function I programmed that does what it says), and it updates the visual side.

Implementation detail 2: each cell has several layers which need to be _sorted_ correctly.

* BG = players/clients are always on top of this
* Floor = an overlay on the BG, still on the floor though
* Overlay = this one is actually depth sorted, and players/clients can stand "behind" or "in front" of this

That's why, after setting the cell's type, I transfer each layer to the right location. In the future, I'll probably need better names (and systems) for such layers. But hey, this was a quick game with simple graphics.

## Step 2: add a player

This isn't rocket science. The player is just a sprite with a body at the bottom. (Because of the perspective in such 2D games, the actual body that interacts with other stuff is only the _bottom_ half of the sprite.)

* When given input, it moves in that direction.
* When you press SPACE, it dashes: it applies a sudden (huge) force in your current direction, which is dampened every frame (multiplied by something like `0.99`), until you're back at normal speed again and regain control.

The cells also get a (static) body, of course. The other clients get a body, but this one does **not** interact with the player body.

Instead, I detect if you "hit" a client by checking if the `Area2D` overlaps it. Why? 

* The area can be _bigger_ than the actual player. Which feels better to play. (Otherwise you might have _near misses_ all the time, missing clients by a pixel, which just feels frustrating and unfair.)
* If their bodies also collide, that might happen _before_ the area registers it. Which leads to messy situations where the bodies are pushed apart by the physics engine, and now the area doesn't overlap anymore, and no hit is registered, which is a bug, ...

I can't create a walk animation to save my life. So I just use a very fast animation of two simple sprites :p And when you move towards the left, it flips horizontally (`flip_h = velocity.x < 0`).

## Step 3: adding clients

I've already created the pathfinding code for generating the map (step 1). The clients merely have to reuse that, but add some extra behavior on top.

In short, they're just one big **state machine**, with these states.

* WALKING
* GRABBING
* STUNNED
* ARRIVING / LEAVING

Whenever we switch to a new state, I execute any logic I need.

* Walking? Pick a random table and find the path towards it. (If our backpack is full, go towards checkout instead.)
* Grabbing? Add an item from a nearby table. Stand still for a bit. Then switch back to walking.
* Stunned? Stand still for a bit. Then switch back to walking.
* Arriving / Leaving? To make this look much better, I play some animations. While doing so, I don't want the clients to interact with _anything_ (as that would mess them up), so these states are basically "do-and-react-to-nothing".

The "stand still for a bit" is handled by a simple `Timer` node, which fires once with a semi-random duration.

When I have a path for walking, I give it to a `PathWalker` module I wrote. It simply moves along the path at a certain speed, then checks when we're done.

{{% remark %}}
I don't follow the _path_ per se. That would look robotic, with all the clients only walking through the exact _center_ of each tile. Instead, I randomly offset those points so they land on other parts of the cell, creating a more random and organic path towards the destination.
{{% /remark %}}

I expressly decided **not** to save the exact table or item we're going towards. Because ... it might be gone by the time we get there. (Remember, one goal is to clean out the store, which means the player needs to be able to destroy the tiles.) Instead, they just walk towards a destination. Something is there? Grab it (go to GRABBING). Nothing is there? Go to WALKING again, with a different destination.

## Step 4: finishing the mechanics

If you could always dash ... then there would be no point to it. It's faster than walking. So let's just slam that spacebar all the time! Never stop!

Additionally, a common issue with these kinds of games is that you can "camp" the location where your "enemies" arrive or leave.

To solve both issues, I decided to make dash a _powerup_ you have to grab.

* Each dash powerup adds +1 dash power.
* This is clearly _visible_ and _intuitive_. (More so than, for example, a dash bar that "automatically refills". That's more of a hidden mechanic that players will miss.)
* It forces you to constantly move around and move away. (And to be smart about the routes you take.)
* But it also allows you to "save up" on dash power, then use more of it at once for one big "attack".

It felt like a very easy addition that solved almost all issues with the idea that were left.

In fact, I didn't see anything else that needed solving. My only minor issues were ...

* Moving around; it felt like we needed teleports or some _faster_ way to get to the other side of the store. At the same time, however ... the whole challenge of the game is to position well and take smart routes. 
* Repetitiveness; such a simple game with simple rules, will obviously lead to doing a lot of the same thing.

But, in practice, these fell away. If the stages continue at the right pace, there's always something new to challenge you. The store is big enough (and the layout random enough) to get new situations all the time. 

During development (over the course of a few days) I kept making the **player faster**, because it just felt much better and more exciting. That solved the "teleport" issue as well.

## Step 5: Teaching / Progression

I've learned that creating the tutorial for your game is something you do _as quickly as possible_.

* It shows you how complicated the idea is. (And if too complicated, you must simplify right now.)
* It must be done anyway, no matter what happens.
* If you leave it until the last second, you'll probably speed through it and provide a very bad tutorial. Which means your game might be awesome ... but nobody knows, because nobody understands.

I've also learned, after creating many games, that giving all information / rules beforehand is _never the way to go_. Even if you make it "interactive"---like "now move towards the arrow" and "press A to do X now"---that doesn't really work.

Instead, you must break all your rules and mechanics into small, bite-sized chunks. Then you feed them to the player _one at a time_, _over time_.

As such, I broke the game into "stages".

* When a new stage starts, it shows a very simple tutorial image with one new rule or idea being added.
* Then the stage lasts for a fixed duration (30 seconds, or 60 seconds)
* After which the next stage starts

The first stage? You can only _move_. Clients leave just by touching them.

The next stage adds dashing. Later stages add cell removal, different client types, a higher number of clients at the same time, and so forth.

This takes more work, at first. I have to map this out, build the system for stages, and create many more graphics and configurations.

But ... once you have that, it's a vastly superior system to anything else (so I've learned). I quickly asked others to test the game, didn't have to explain _anything_ beforehand, and they had absolutely _no_ issue playing and understanding immediately. 

Once you reach the last stage, quite a lot is going on. Multiple controls, different clients, some more mechanics/rules. But that's no issue at all, because people learned them in bite-sized doses delivered once every 60 seconds.

{{% remark %}}
As said, this system also handles general "progression". When you start the game for the first time, you don't want more than 1 or 2 clients in the store. That would be overwhelming and way too difficult. Their numbers only ramp up as you get to later stages.
{{% /remark %}}

Combining all that, we get something like the video below.

@TODO: first video I posted on twitter.

## Step 6: polish and finishing

Polishing means ...

* Adding sound effects
* Adding animations
* Adding particles
* Adding textual feedback
* Fixing minor annoyances or issues

Nothing special to mention here. It's a part of game dev I find rather boring, but learned to do anyway, because it's that important. I also don't think all the special effects work together as well as they could in this game---but hey, I had no more time to spend on this project!

I created a few spritesheets for different clients. (And some differences between them, such as the kid that runs _fast_ but has a _tiny backpack_.)

I added a timer that counts how long you survived. Felt like an obvious addition. (Otherwise it just says "game over", no matter how well you did, no matter what happened in your game.)

I added a "sale" mechanic. It's a special tile that can appear in the store, and shows that a certain ingredient is now worth _more_. (As such, you DON'T want people to buy that.)

Why? Because there was no point to having different items right now. Each was worth the exact same amount of points. There were no other defining characteristics. With the sale---or rather, the "reverse sale"---you now have one or two items for which you want to watch out.

I wrote down more ideas I could add.

* Conveyor belts (or teleports, at later stages) to help you move around
* Other powerups, such as speed up/speed down
* More client types
* More applications for dashing, especially a "radius" ability. (Instead of only destroying cells/clients you pass through, do so in a circular radius around you. This would allow easily reaching people at the other side of the aisle, which would take a looong time to reach by walking.)

Maybe I had time to add them, maybe not. But I was a bit tired and wanted to make more progress on my actual main project, so I left it at that.

Below are two more progress videos. (From day 2 and day 3)

@TODO: videos day 2 and day 3

## Conclusion

The only "issue" that came from my playtesting, was that the _dash_ powerups were a bit hard to pick up. That was simply a matter of their collision shape being too small, so I made it more than twice as large.

There were some technical issues with sound effects not playing in the HTML5 build of the game. That's probably due to using Godot 4.0 which has ... "unpredictable" HTML5 support. I didn't feel like wasting time investigating that further, pretty certain I'd hit a wall (and just hear "wait a few months and it will be fixed").

And that's the whole devlog!

As I said, I only had about 3 or 4 days for this. I also hadn't used Godot in a year, and certainly not the latest and greatest 4.0 version, which is why I kept the idea very minimal. And I'm happy most of it just worked out first try, because I wouldn't have had time to fix any serious roadblocks :p

I really feel like Godot is hitting its stride now. The 4.0 version is _amazing_ in terms of improvements, features, engine size ( = how fast it loads, how small it is), reliability. Creating this game for the jam ... has given me back some motivation to make a game again. To make a _serious_ game, which I can release professionally, with the current state of Godot Engine.

Yes, there are still some major bugs or missing parts. (The developers are aware and they're coming in 4.1 or 4.2.) Last minute, I had to completely redo all my Audio code because some feature just _did not work at all_ and almost no information about that was available. (For those interested: at the moment, you can't set the AudioPlayer `stream` property through code, it just won't work on most exported platforms.)

Similarly, I had to convert all my `GPUParticles` to `CPUParticles` last minute. A conversion that went only 95% smoothly. Godot still has some clear roadblocks, but once those are gone, this is an engine I can see myself using for more and bigger games in the future. 

I might create and publish my other idea for the jam at some later stage. It was similarly tiny, but I suspect it might work just as well. (The basic mechanics are similar, as they were obviously both conceived for the same jam.)

Until the next devlog,

Pandaqi