# GoGodot Jam 4

## Option 1) Minimalism

A game with only two colors (black-white), low-bit pixel art.

Perhaps a puzzle with no text, only minimal elements and rules.

## Option 2) Literal

A puzzle game where, to win the level, you have to create the sentence "LESS" = "MORE"

## Option 3) Magic

You grow a recipe / spell over time.

The fewer ingredients / elements you use, however, the better.

*How?*

-   It's very easy to accidentally add more ingredients.

-   **The enemies throw extra ingredients towards you/your cauldron.** You have to stop them, before they overflow your cauldron.

-   You're never sure how *strong* your magic needs to be. Which might tempt you to add more than necessary, incurring penalties.

**The rules:**

-   You always accelerate. Can only turn left/right.

-   If you hit the cauldron with ingredients in your backpack, you add them.

    -   After adding, it takes X seconds to "cook" and finalize

    -   Might just make it disappear and reappear somewhere else some time later.

-   If you hit it empty, while cooked, you *take* the potion inside.

-   If the cauldron is filled *too much*, it explodes and you lose.

The *more* you turn, the *less* the cauldron can hold.

The *more* you add to the potion, the less powerful the result when you drink it.

**IDEA:** You can only keep *one ingredient type* in your backpack. Any others are destroyed upon touching them.

> **OR:** The game only *has* one ingredient type :p

There are "ingredients" for movement. (Like an arrow that turns you around, *without* counting as input/turning.)

The ingredients jump/bump *roughly* towards the cauldron at all times. Adding more automatically

Cannons/Enemies throw ingredients towards the cauldron.

## Option 4) Couch Co-op / Sports

Apply "less is more" in general game mechanics across the board. Points are given when *scoring* goals (or destroying enemies). The *number* of points depends ...

-   Fewer controls = more points

-   Fewer powerups = more points

-   Fewer inputs = more points

    -   For example, a racing game in which you want to finish with the *least* turning or accelerating

-   Fewer enemies on the field = more points

-   Fewer touches = more points

The **kick golf** game =>

-   Simple midgetgolf levels

-   However, the ball can be hit at all times (no need to wait until it's still). Players kick it by simply walking into it. (Or they hold their golf stick at the side.)

-   Fewer touches = more points when it goes into the hole.

*Multiplayer?* Simply multiple players on the field with their own balls. You can choose whether balls / players interact with each other.

Otherwise, it'd probably be a soccer or tennis-like game.

## Option 5) Management

You **start** with a huge store / city/ randomly generated location.

You have to reduce it back to 1 square (or 3x3/4x4), while keeping your money flow positive at all times.

> **"Less is Store"**

## Option 6) Arcade Game

Similar to the couch co-op / sports game. A semi-abstract, maybe platformer, game like the old arcades.

Would be perhaps easiest / most fun to make ... but how to incorporate the theme?

A platformer where you have to **die** as quickly as possible?

Less space = more points

Less light = more points

# Less is Store

Customers randomly walk in and will visit products + buy them.

It's your job to PREVENT THAT FROM HAPPENING.

The more money you make, the less well you do. (The fewer points you score?)

In general, you have to ...

-   Attack/stop/deflect people before they buy something. (It only matters if they get to a checkout, before that time you can allow them to stack up on items.)

-   You can destroy tiles. However, you can only do so if *nobody is around*, and it *takes a while* (so nobody needs to come close while it's happening).

You win if you manage to get your money down to zero OR to empty the whole store.

## Discarded/Future

**Client types**

-   **Clumsy:** will also destroy the whole *tile* when they grab something from it

-   **Big Guy:** will have a *huge* backpack. When it leaves, it also takes away from anybody within a certain radius.

**Polish**

-   **Progression**: Prevent the double "Space" instruction at game over?

**Sale:**

-   An **actual SALE**, which makes a certain item FREE?

**Map:**

-   Change the items of the store to more wasteful products?

    -   **YES, do this.** Then also *increase* the variety of products to 5.

-   More powerups/specialties

    -   Speed. (Speed *down* can be ignored by *dashing* through it?)

    -   *Teleport*.

    -   Or a conveyor belt.

**Game loop**

-   We *need* some faster way to move around, right? => Every side wall gets one teleport?

**Polish:**

-   Many sound effects don't work in HTML5 build?

-   

# Recipe Race 2D

Could just be a 2D version of the 3D game.

-   Top-down

-   Ingredients appear

-   One of them "adds" to the cauldron.

-   The other "removes" one thing inside.

-   You want to catch/destroy the adders and let the removers through.

-   Because your goal is still to prevent the cauldron from overflowing.

Could also be the simplified racing game.

-   You always turn left. Press the key to turn right.

-   The more you turn, the less speed / points / whatever you get.

-   And you simply have to finish the race (pass all gates??) as fast as possible?

# Recipe Race (To Do)

## 10 May

**Game:**

-   Implement mono-input version

    -   Check what other rules I might've left on/off, set them right

-   Finetune sizes of things

    -   Larger grab area for ingredients + drop-off at cauldron

-   Brainstorm the powers to get (and how to use them)

-   Prettier second tree model + a shrub/wall (with quad decoration?)

-   Finalize rules / mechanics for optimal fun

Might need to pivot

## 11 May

**Models:**

-   Witch on a broom

**Feedback:**

-   Particles & Tweens

    -   More feedback when ingredient goes rogue

    -   Maybe even indicate *where* it will go

    -   A tween for cauldron hide/show

-   Text feedback (on score change and such)

-   Nicer transitions between stages, to game over, etcetera

## 12 May

**Finishing:**

-   Background music + sound effects

-   Create my own **tutorial background** graphic + **UI** graphic

-   Some simple logo / splash screen / image and description

**Game:**

-   See if we can incorporate the theme as much as possible. And make it as fun/creative as possible.

## 13-15 (?) May

Extra time. Extra polishing, extra stages, an input screen to play *local multiplayer*.

**IDEA:** Only use *one* control => automatically turn left, only key is right. **=> PROBABLY THE RIGHT MOVE.**

**IDEA:** The ingredient that occurs *most often* counts. (In case of a tie, it picks randomly.)

**IDEA:** Multiple cauldrons + smaller cauldron

**IDEA:** Clearly add one ingredient, from the start, that is "poison" and you don't want to touch it?

**ISSUE:** If your cauldron is already too full to fit your backpack ... you can never lose it. *Use the powerups/action ingredients to solve that?*

**TODO:**

-   What *powers* can players get? Do we communicate them at the top? (Larger cauldron = better power, smaller cauldron = bad powers)

-   Finetune radius (when placing things in valid locations) + input tracker threshold

Optional/Later:

-   BUG: overflow check not working anymore??

-   BUG: Level wrapping for ingredients doesn't work? It does copy, but it doesn't properly wrap to other side (soon enough)

-   BUG: You can get *stuck* if you can't turn anywhere. How to prevent this?

    -   A slight drift towards the *right* to set you free, even if it takes a few seconds?

-   (Try the action/special ingredients. Though if it's a good game, it should work without that.)

-   Properly scale number of ingredients, how fast they move, etcetera over time
