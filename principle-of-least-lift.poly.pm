#lang pollen

◊title{The principle of least lift}
◊subtitle{Lessons learnt from prototyping in Haskell}

◊new-thought{Always separate effectful code from pure code.} I suggest we expand
this advice to all ◊first-use{lifted} types – like ◊code{MachineT}, for example.

I was prototyping a monitoring interface for some builds. It needed (1) to trawl
through a directory full of log files, parsing names and contents for
information about the build, and (2) display that information in the form of a
webpage.

My mistake was to place too much of my code in the ◊code{MachineT} monad. I
spent a lot of time trying to figure out how to compose all my component
◊code{MachineT}s – splitting input, combining output, etc. etc.

What I forgot is that I only needed to use machines if I need to do effectful
streaming in constant memory – streaming from a file, for instance. Even
effectful computations needn't be lifted into a machine; the Kleisli arrow would
work better.

◊code{(<=<) :: Monad m => (b -> m c) -> (a -> m b) -> a -> m c}

Now that I put as much of my code in ◊emph{pure} functions, splitting and
recombining input is a piece of cake – I can even throw in the arrow combinators, ◊code{>>>}, @