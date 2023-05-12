/*
 * Lazy implementation of sieve of Eratosthenes
 * https://en.wikipedia.org/wiki/Sieve_of_Eratosthenes
 * Inspired by Computerphile "Laziness in Python" video
 * https://www.youtube.com/watch?v=5jwV3zxXc8E
*/

// original nats implementation by professor Thorsten Altenkirch
IEnumerable<int> Nats(int n)
{
    yield return n;
    foreach (var next in Nats(n + 1))
        yield return next;
}

// recursion removed
IEnumerable<int> NatsWithoutRecursion(int n)
{
    while (true)
        yield return n++;
}

IEnumerable<int> Sieve(IEnumerable<int> s)
{
    var n = s.First();
    yield return n;
    foreach (var i in Sieve(s.Where(x => x % n != 0)))
        yield return i;
}

void PrintPrimes(int howMany, Func<int, IEnumerable<int>> natsFunc)
{
    int cnt = 1;
    var p = Sieve(natsFunc(2));
    foreach (var i in p.Take(howMany))
        Console.WriteLine($"Prime #{cnt++}: {i}");
}

// can calculate 793 primes on .NET 7, before throwing StackOverflow exception
// uses recursive natural numbers generator
PrintPrimes(howMany: 10, Nats);

// does not use recursion for Nats, calculates at least 4000 primes
PrintPrimes(howMany: 10000, natsFunc: NatsWithoutRecursion);