# Advent of Code 2021

The following are my entries for the 2021 Advent of Code at [http://adventofcode.com](http://adventofcode.com). I tried to leverage this opportunity to dust off my old chops using langauges like Ruby and hone in my current skill set learning new Swift skills such as async/await.

## Entries

### [Day 1](Day1/)
When I started the Advent and saw the challenges, Ruby immediately came to mind. Well, actually Perl came to mind, but _then_ Ruby came to mind. It was fun to dust off these chops but hanging out in a type safe language for so long has Ruby feeling pretty cringey.

### [Day 2](Day2/)
I remembered that you can use Swift for shell scripts. It bugged me that most Swift solutions online for streaming the contents of a file involved reading in the entire file and splitting it on `\n`. 

Initially I solved the first problem using a mutable pointer to stream the contents in small chunks. Then my coworker enlightened me to the fact that async/await brought some new sugar for streaming the contents of a file. The The only problem is that it segfaults on files of more than 150 lines or so. Barring that catastrophic issue, you've gotta check out [this syntax](https://github.com/jereme/AdventOfCode2021/blob/eca965850453f73446bdcf86a85d2653f36b9f21/Day2/problem2.swift#L118-L123).

### [Day 3](Day3/)
I wasn't as happy with the resulting code on this one because a lot of it is operationally inefficient.  Reiterating over the same arrays over and over and whatnot.  That being said, I tried to bring reducers into the picture to help solve problems and I was able to get through the solution.
