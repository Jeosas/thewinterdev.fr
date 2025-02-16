+++
title = "About software testing"
description = "A take on how to make your test work for you, not against you."
# updated =

[taxonomies]
tags = [ "software", "programming", "testing" ]

[extra]
hero_file = "about-software-testing.jpg"
hero_caption = ""
+++

Testing is an essential part of a product's life cycle. It is a way to guarantee that your code is doing what you want it to and will keep doing it in the future as your codebase grows.
There are as many ways to test a program as there are developers, but history taught us some lessons on how to and how not to test software.
And if you are not willing to listen to what decades of software development have to tell us, you will, one way or another, learn it the hard way during your programming life.

I was like you in the beginning, thinking that I could somehow not listen to this advice and find a testing style of my own. But after years of getting bit left and right, I ended up researching, learning, and putting into practice those lessons from our elders.
The ones I'll present here are my guiding principles, the few lessons that, if applied, will avoid most foot guns and save you hours as your project grows.

## How tests become your enemy

We hear everywhere that the first phase of testing is [unit testing](https://en.wikipedia.org/wiki/Unit_testing) and that it is the phase that should contain most tests, as they are fast and cheap, and they are tests that should check at the function/class level.
While this is true, taking this definition to the letter tends to lead to testing every single function and class.

_"Excellent!"_ you tell yourself, _"This way I'll for sure have no bugs and 100% coverage!"_

And by doing so, you fell into the first **pitfall: testing code implementation over code behavior**.

When writing a test, **you are writing a contract about how your code should behave**. But by testing every single function, sure, you are ensuring that your code behaves the way it should, but you also test **how the code should be written** (and in most cases, how the code _has_ been written).
While this could be desired in some cases, usually it will come back to bite you later.

Here is an example: Your codebase evolves, and now you have to refactor some functions or classes. You move/rename/merge/change some functions, and now your tests fail. You rewrite those tests to match your new implementation.

How are you sure the new tests are equivalent to the previous ones? How do you know you didn't break anything?

This is **why testing behavior regardless of the implementation is better**, as you won't (in most cases) need to change your tests when refactoring code, saving you time (not having to re-write them) and peace of mind (knowing that the new code behaves the same way the previous one did).

On the topic of not testing implementation, another very powerful tool that can bite you hard in the long run is [mocks](https://en.wikipedia.org/wiki/Mock_object).

Mocking is a fast and easy way to test code that depends on heavy computations, third-party services, and the like. It makes tests faster and testing environments lighter.
Basically, you replace a function with an object that will record each call to it (how many times it was called, with which values) and return a hard-coded value that the function _should_ return without it actually running.

**While mocks are useful, they hide a plethora of mines: they hide changes in behavior in the underlying function and... test implementations**.
While it is okay to mock third-party services (like API calls), and while it is acceptable to mock services like databases if you are careful, it is way too easy to mock objects, and this can go out of hand. QUIKLY trust me. _I've seen things that cannot be unseen..._ 0_0

Well, let's talk about making tests work for you instead of against you.

## Think of your tests as much as your code.

Writing tests is more often than not seen as a chore by developers and a waste of time and money from stakeholders. If tests have their use, a developer is paid to create features, not tests.

Let me tell you: this is the biggest footgun that developers and stakeholders alike make, and here is what I have to say about it:

> Tests are not a prison, its a contract

A contract that is given by stakeholders saying that **as long as you fulfill its terms, you are free to do things the way you want as a developer**.

> Spending time working on your tests is worth. every. cent.

Spending time making your tests robust (and by robust, I don't mean testing every function but thinking your tests to be as flexible and reliable as possible) will save so much time, money, and headaches because **a bug caught during the test phase is way quicker to fix than the same one occurring during production months down the road**.

## Tests: the maxims

- Test behavior, not implementation.
- Mocks are a code smell; try finding an [alternative](https://martinfowler.com/bliki/TestDouble.html) as hard as you can.
- Functions should be as [pure](https://en.wikipedia.org/wiki/Pure_function) as possible, and side effects should be handled in isolation.

## The way to enlightenment

_"Alright, this sounds good and all, but how do I come to make tests work for me?"_ I hear you say in the back.

Here are some tools and techniques to add to your arsenal.

### Test Driven Development

You may have heard about [Test Driven Development](https://martinfowler.com/bliki/TestDrivenDevelopment.html) (TDD), and you might have tried it in the past. I may seem cumbersome at first, but I can assure you that it will greatly improve your tests' quality.

Let's play the honest classic scenario:

- You take a feature to implement (exited, lots of energy).
- You write code that takes care of the feature (exited, lots of energy).
- You write your tests (chore, you do this quickly).

And in the meantime, your tests are inspired by the implementation you just wrote (thus testing implementation over behavior), and the test cases are inspired by the ones you imagined while writing code (most likely forgetting some of them).
Furthermore, you finished implementing your feature, and your code seems to work. What is your incentive to write good tests now? You are just eager to move on to the next feature!

Now, let's redo this scenario but with TDD:

- You take a feature to implement (exited, lots of energy).
- You write tests corresponding to the feature's contract (as fun as you make it, still a lot of energy).
- You write code that takes care of making the tests you wrote pass (exited, energy is getting low, but as soon as tests are green, you are done - but not before that).

Now we have tests that are only based on the feature definition (contract) and completely unaware of the - not yet existing - implementation.
We start coding only when our tests are done (i.e. failing) so that when our feature is finished (i.e. tests are green), we know for sure that 1. our feature works as intended and 2. it is sufficiently tested so that it keeps working in the future.

**TDD helps you focus on tests that are aligned with the stakeholders' expectations and that are as implementation agnostic as possible**.

You are free to practice hardcore TDD (red/green/refactor) in increments as small as you like, but the good thing is you don't _have_ to. Don't get me wrong, you should by all means try TDD; use it for a while to get the gist of it and see if it suits you, but keeping in mind the teachings of TDD while not necessarily applying it to the letter could be enough for you to be a happy tester!

### Test Doubles

We've seen that mocking isn't that great of a solution for testing. An alternative is using **test doubles**. Basically, **the goal is to create a Fake object that will behave like the real one** but be easier to set up and control.

A very classic example: instead of having to spin up a database, execute migrations, seed it with test data, and wipe it after each test to avoid pollution between them, you could use an in-memory _Fake_ database that behaves exactly like the real one to use in your test. For each test, you create the _Fake_ database and add needed data to the array, then run your tests and delete the fake database at the end.

You might be in luck, and the library you are using provides some _Fakes_ to use in your tests; otherwise, you might need to build them yourself. This implies a little overhead cost to build the _Fake_ and write some tests to ensure that the _Fake_ behaves the same way the real implementation does at all times, but in the long run this little time spent will save you a lot when writing your tests.

### Compiled languages

When using scripting languages like Javascript or Python, your tests need to be extra careful about [duck typing](https://en.wikipedia.org/wiki/Duck_typing).
Some tools, like mypy in the case of Python, help with that by performing static code analysis that greatly improves code reliability, but there still are some shortcomings (e.g. mypy ignores exception handling).

Using a strongly typed compiled language can help you with your testing since **part of what needs to be tested is handled by the compiler**, and an error caught at compile time is way cheaper to handle than one happening at runtime!
