---
title: "Recipe Race"
---

Welcome to the devlog for "Recipe Race" (@TODO: update to actual, better title). This game was created for the GoGodot Jam (iteration 4).

I didn't have as much time as usual, which means this devlog will be quite short and I went for a rather "safe" idea. Nevertheless, let's talk about some interesting parts of the design process!

## What's the idea?

The theme was **Less is More**. A theme I've literally seen numerous times before (in Game Jams), and I don't even do that many jams. At the same time, some themes just work better than others, and it's ... fine?

I wrote down about six different ideas. (Different levels of complexity, different genres or applications of the theme.)

Two ideas both revolved around people racing around an arena. 

> You always accelerate and can only _turn_. The less you turn / provide input, however, the better.

As such, I wanted to try that idea first. 

## Developing it further

I, somehow, really wanted to do something with collecting flowers and creating recipes. That quickly turned into something with witches in a forest, and a big cauldron.

To be honest, this jam was a _mess_. After years of making games, I am able to quickly figure out they key components (input, objective, game loop) and work towards a clear goal.

Usually.

Due to my lack of time, I just had to _start_ with a bunch of half-baked ideas.

* The forest is filled with ingredients.
* Fly into ingredients to grab them.
* There's a big cauldron. Throw the ingredients in there (by touching it).
* But remember the theme: _less is more_. Instead of filling the cauldron, you actually want to _empty_ it?

To apply the theme, I saw only one clear objective:

> You _lose_ if your cauldron overflows because it is _too full_!

Pretty simple and intuitive. You want to keep ingredients _out_ of your cauldron.

But ... that means there is some force, some enemy, trying to get them _into_ your cauldron. I do not have the skill to create proper 3D models of enemies, including animations and texturing in just a few days :p

Which means we go for the "indie solution": 

* The _ingredients_ themselves can turn "rogue" and start jumping towards your cauldron.
* This means I only have to animate a jump, a squashy animation, and perhaps add some eyes to a tomato.

Alright, we're moving towards a game. But we're not really there yet.

## Throwing sand against a wall

I've learned to structure a project in such a way that I have this global _config_ object that allows me to toggle any rule/mechanic ideas on or off at a dime.

As such, I spent a few hours implementing _everything_ I could think of. And then I tried them out, played with them in different combinations, until I had a clearer picture.

At the same time, I already started making the tutorial/explanation for the game. That's a _great_ test for the simplicity of your game. It revealed to me that I was, as always, thinking too far ahead and adding too many mechanics already.

I couldn't explain the "full" game in one or two simple drawings. I needed 4.

This gave me an idea to solve multiple issues at once:

* Play happens in "stages". If you survive long enough, you go to the next stage.
* Whenever that transition happens, a new tutorial box pops up to explain some _new_ rule that appears.
* Your **objective** is to survive as long as possible and get the **highest score** possible.

Alright, we now have 4 stages, each adding one tiny simple rule.

* **Stage 1** => you can turn with key X and Y. Prevent your cauldron from overflowing (ingredients try to jump into it)
* **Stage 2** => the _more_ you turn, the _smaller_ your cauldron gets. (And thus easier to overflow.)
* **Stage 3** => walk into the cauldron to drink its potion. (What happens then? NO IDEA.)
* **Stage 4** => now you have a backpack. Walk into ingredients to pick them up, walk into the cauldron to drop them in there.

The biggest question, the one that haunted me for a few days, is _what to do with the theme and the "potions"_?

At first, I wanted to add actual recipes. Perhaps at the top of the screen, with the other UI. For example, one that says "tomato + tomato + carrot = SOMETHING".

That was way too complicated. It would eat up space. It would overwhelm players. It would be near _impossible_ to achieve: only one rogue ingredient has to jump in, and all your recipes have become impossible.

The theme of the jam is "less is more". Let's try the stupidly simple things:

* There _is_ only one ingredient. (But then what's the point of the whole witch theme and all?)
* Or recipes go based on _size_ alone. (But then what's the point of adding multiple different ingredients?)

I had no clue how to do this. I only knew that, at least for the first few stages, I'd only need _one_ ingredient type. It was more important to finish all the other parts of the game loop. To "close" the game loop, so to speak.

## Making tiny decisions all the time

If we can only turn ... the edges of the level are annoying. Let's add **level wrapping**. (And also add it for _ingredients_, using the same code module.)

If we add ingredients by touching the cauldron, but also drink the potion from it in the same move, we obviously run into issues. (The code will infinitely cycle both actions.) Let's add some delay:

* Either the potion needs to "cook" a few seconds before it's ready
* Or the cauldron simply disappears and reappears somewhere else a few seconds later

The more I tested the game, the more I became certain that I needed _one_ more thing. The game _could_ work, but just something was missing.

Then I hit an unsolvable situation, with the current mechanics / rules.

* If you have a lot in your backpack ...
* But your cauldron doesn't have enough space for all of it ...
* You can never get rid of your backpack anymore! Doing so would overflow the cauldron, and there's _no_ other way to empty/change your backpack.

@TODO: Lala

