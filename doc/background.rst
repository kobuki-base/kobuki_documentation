Background
==========

.. _introduction-section:

Introduction
------------

.. note:: Behaviour trees are a decision making engine often used in the gaming industry.

Others include hierarchical finite state machines, task networks, and scripting
engines, all of which have various pros and cons. Behaviour trees sit somewhere in the middle
of these allowing you a good blend of purposeful planning towards goals with enough reactivity
to shift in the presence of important events. They are also wonderfully simple to compose.

There's much information already covering behaviour trees. Rather than regurgitating
it here, dig through some of these first. A good starter is
`AI GameDev - Behaviour Trees`_ (free signup and login) which puts behaviour trees in context
alongside other techniques. A simpler read is Patrick Goebel's `Behaviour Trees For Robotics`_.
Other readings are listed at the bottom of this page.

Some standout features of behaviour trees that makes them very attractive:

* **Ticking** - the ability to :term:`tick` allows for work between executions without multi-threading
* **Priority Handling** - switching mechansims that allow higher priority interruptions is very natural
* **Simplicity** - very few core components, making it easy for designers to work with it
* **Dynamic** - change the graph on the fly, between ticks or from parent behaviours themselves

.. _readings-section:

Readings
--------

* `AI GameDev - Behaviour Trees`_ - from a gaming expert, good big picture view
* `Youtube - Second Generation of Behaviour Trees`_ - from a gaming expert, in depth c++ walkthrough (on github).
* `Behaviour trees for robotics`_ - by pirobot, a clear intro on its usefulness for robots.
* `A Curious Course on Coroutines and Concurrency`_ - generators and coroutines in python.
* `Behaviour Trees in Robotics and AI`_ - a rather verbose, but chock full with examples and comparisons with other approaches.

.. _Owyl: https://github.com/eykd/owyl
.. _AI GameDev - Behaviour Trees: http://aigamedev.com/insider/presentation/behavior-trees/
.. _Youtube - Second Generation of Behaviour Trees: https://www.youtube.com/watch?v=n4aREFb3SsU
.. _Behaviour Trees For Robotics: http://www.pirobot.org/blog/0030/
.. _A Curious Course on Coroutines and Concurrency: http://www.dabeaz.com/coroutines/Coroutines.pdf
.. _Behaviour Designer: https://forum.unity3d.com/threads/behavior-designer-behavior-trees-for-everyone.227497/
.. _Behaviour Trees in Robotics and AI: https://arxiv.org/pdf/1709.00084.pdf

