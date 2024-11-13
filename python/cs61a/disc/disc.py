# --- disc 02
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


# --- disc 03
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


# --- disc 04
def paths(m, n):
    """Return the number of paths from one corner of an
    M by N grid to the opposite corner.

    >>> paths(2, 2)
    2
    >>> paths(5, 7)
    210
    >>> paths(117, 1)
    1
    >>> paths(1, 157)
    1
    """
    "*** YOUR CODE HERE ***"
    # solutions:
    #
    # if m == 1 or n == 1:
    #     return 1
    # return paths(m - 1, n) + paths(m, n - 1)

    def helper(i, j):
        if i == m and j == n:
            return 1
        if i > m or j > n:
            return 0
        return helper(i + 1, j) + helper(i, j + 1)

    return helper(1, 1)


def even_weighted_comprehension(s):
    """
    >>> x = [1, 2, 3, 4, 5, 6]
    >>> even_weighted_loop(x)
    [0, 6, 20]
    """
    "*** YOUR CODE HERE ***"
    return [s[i] * i for i in range(0, len(s), 2)]


def tree(root_label, branches=[]):
    for branch in branches:
        assert is_tree(branch)
    return [root_label] + list(branches)


def label(tree):
    return tree[0]


def branches(tree):
    return tree[1:]


def is_tree(tree):
    if type(tree) != list or len(tree) < 1:
        return False
    for branch in branches(tree):
        if not is_tree(branch):
            return False
    return True


def is_leaf(tree):
    return not branches(tree)


def print_tree(tree):
    def print_tree_help(t, indent, level):
        print(indent * level + str(label(t)))
        if is_leaf(t):
            return
        for branch in branches(t):
            print_tree_help(branch, indent, level + 1)

    print_tree_help(tree, "  ", 0)


def has_path(t, p):
    """Return whether tree t has a path from the root with labels p.

    >>> t2 = tree(5, [tree(6), tree(7)])
    >>> t1 = tree(3, [tree(4), t2])
    >>> has_path(t1, [5, 6])        # This path is not from the root of t1
    False
    >>> has_path(t2, [5, 6])        # This path is from the root of t2
    True
    >>> has_path(t1, [3, 5])        # This path does not go to a leaf, but that's ok
    True
    >>> has_path(t1, [3, 5, 6])     # This path goes to a leaf
    True
    >>> has_path(t1, [3, 4, 5, 6])  # There is no path with these labels
    False
    """
    if p == [label(t)]:  # when len(p) is 1
        return True
    elif label(t) != p[0]:
        return False
    # return any([has_path(b, p[1:]) for b in branches(t)])
    for b in branches(t):
        if has_path(b, p[1:]):
            return True
    return False


def find_path(t, x):
    """
    >>> t2 = tree(5, [tree(6), tree(7)])
    >>> t1 = tree(3, [tree(4), t2])
    >>> find_path(t1, 5)
    [3, 5]
    >>> find_path(t1, 4)
    [3, 4]
    >>> find_path(t1, 6)
    [3, 5, 6]
    >>> find_path(t2, 6)
    [5, 6]
    >>> print(find_path(t1, 2))
    None
    """
    if label(t) == x:
        return [x]
    for branch in branches(t):
        path = find_path(branch, x)
        if path:
            return [label(t)] + path
    return None


def sprout_leaves(t, leaves):
    """Sprout new leaves containing the labels in leaves at each leaf of
    the original tree t and return the resulting tree.

    >>> t1 = tree(1, [tree(2), tree(3)])
    >>> print_tree(t1)
    1
      2
      3
    >>> new1 = sprout_leaves(t1, [4, 5])
    >>> print_tree(new1)
    1
      2
        4
        5
      3
        4
        5

    >>> t2 = tree(1, [tree(2, [tree(3)])])
    >>> print_tree(t2)
    1
      2
        3
    >>> new2 = sprout_leaves(t2, [6, 1, 2])
    >>> print_tree(new2)
    1
      2
        3
          6
          1
          2
    """
    "*** YOUR CODE HERE ***"
    if is_leaf(t):
        return tree(label(t), [tree(x) for x in leaves])
    return tree(label(t), [sprout_leaves(branch, leaves) for branch in branches(t)])
