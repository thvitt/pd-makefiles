## Presentation make include files

These are makefile snippets to produce slides with as little buerocracy as possible.

__Warning:__ This is probably not usable as-is for someone else than me, you’ll have to look at the files.


## Usage

- Symlink repo as, e.g., /usr/local/include/pd into one of GNU make’s include directories
* In your slides dir, name the slides `NN*-*.md`
* Have `md-images` from my teaching tools installed
- Write a simple Makefile, e.g.:

    ```Makefile
    include pd/slides.mak

    default : slides
    ```
