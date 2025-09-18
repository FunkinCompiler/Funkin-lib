# How to patch

This is a small note for whoever needs to go this deep.
This small script patches some parts of official source to make it more usable.

## How to patch code
1. Copy the new code from *official* ``source/funkin`` to the ``funkin`` directory.
2. review ``hmm.json`` file and make necessary changes with the ``official version``
2. ``cd`` to this directory in the terminal
3. Run ``haxe -main CodePatcher --interp ``

That's about it.

If you need to update any other parts: Please make sure to put ``ComponentBuilder.hx`` into ``haxe/ui/ComponentBuilder.hx`` as well (if not present)