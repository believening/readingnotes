def find_digit(k):
    """Returns a function that returns the kth digit of x.

    >>> find_digit(2)(3456)
    5
    >>> find_digit(2)(5678)
    7
    >>> find_digit(1)(10)
    0
    >>> find_digit(4)(789)
    0
    """
    assert k > 0
    "*** YOUR CODE HERE ***"
    return lambda x: x // (pow(10, k - 1)) % 10


def match_k(k):
    """Returns a function that checks if digits k apart match.

    >>> match_k(2)(1010)
    True
    >>> match_k(2)(2010)
    False
    >>> match_k(1)(1010)
    False
    >>> match_k(1)(1)
    True
    >>> match_k(1)(2111111111111111)
    False
    >>> match_k(3)(123123)
    True
    >>> match_k(2)(123123)
    False
    """

    def check(x):
        while x // (10**k) > 0:
            if x // (10**k) != x % (10**k):
                return False
            x //= 10**k
        return True

    return check


def f_then_g(f, g, n):
    if n:
        f(n)
        g(n)


def inverse_cascade(n):
    grow = lambda n: f_then_g(grow, print, n // 10)
    shrink = lambda n: f_then_g(print, shrink, n // 10)

    grow(n)
    print(n)
    shrink(n)


def count_partitions(n, k):
    if n == 0:
        return 1
    if k == 0 or n < 0:
        return 0
    return count_partitions(n - k, k) + count_partitions(n, k - 1)


def multiply(m, n):
    if m == 1:
        return n
    if n == 1:
        return m
    return m + multiply(m, n - 1)


def swipe(n):
    """Print the digits of n, one per line, first backward then forward.

    >>> swipe(2837)
    7
    3
    8
    2
    8
    3
    7
    """
    if n < 10:
        print(n)
    else:
        print(n % 10)
        swipe(n // 10)
        print(n % 10)


def skip_factorial(n):
    """Return the product of positive integers n * (n - 2) * (n - 4) * ...

    >>> skip_factorial(5) # 5 * 3 * 1
    15
    >>> skip_factorial(8) # 8 * 6 * 4 * 2
    384
    """
    if n <= 2:
        return n
    else:
        return n * skip_factorial(n - 2)


def hailstone(n):
    """Print out the hailstone sequence starting at n,
    and return the number of elements in the sequence.
    >>> a = hailstone(10)
    10
    5
    16
    8
    4
    2
    1
    >>> a
    7
    >>> b = hailstone(1)
    1
    >>> b
    1
    """
    print(n)
    if n % 2 == 0:
        return even(n)
    else:
        return odd(n)


def even(n):
    return 1 + hailstone(n // 2)


def odd(n):
    if n == 1:
        return 1
    return 1 + hailstone(n * 3 + 1)


def count_stair_ways(n):
    """Returns the number of ways to climb up a flight of
    n stairs, moving either one step or two steps at a time.
    >>> count_stair_ways(1)
    1
    >>> count_stair_ways(2)
    2
    >>> count_stair_ways(4)
    5
    """
    "*** YOUR CODE HERE ***"
    if n == 0:
        return 1
    elif n < 0:
        return 0
    return count_stair_ways(n - 1) + count_stair_ways(n - 2)


def sevens(n, k):
    """Return the (clockwise) position of who says n among k players.

    >>> sevens(2, 5)
    2
    >>> sevens(6, 5)
    1
    >>> sevens(7, 5)
    2
    >>> sevens(8, 5)
    1
    >>> sevens(9, 5)
    5
    >>> sevens(18, 5)
    2
    """

    def f(i, who, direction):
        if i == n:
            return who
        # update the new inputs
        # - direction:
        if i % 7 == 0 or has_seven(i):
            direction = -direction
        # - who:
        who = (who + direction) % 5
        if who == 0:
            who = 5
        # - i:
        i += 1
        # recursive call
        return f(i, who, direction)

    return f(1, 1, 1)


def has_seven(n):
    if n == 0:
        return False
    elif n % 10 == 7:
        return True
    else:
        return has_seven(n // 10)
