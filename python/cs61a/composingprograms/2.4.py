# Propagating Constraints
#
# more：https://en.wikipedia.org/wiki/Constraint_programming
#
# --- 本节
# 约束：不同的约束描述了不同数量的变量之间必须满足的关系，比如，加法约束要求三个变量 a、b、c 之间满足 a+b=c；常量约束标明一个常量值。
#      约束只描述关系，不维护变量和变量的值，约束器对外暴露的是等同于参与约束的变量的数目的接口，以便于对接其他约束器。
# 连接器：连接器用于连接约束器，当一个连接器参与构建不同约束时，视为将这些约束器连接起来。连接器维护变量和变量的值，约束器可以通过连接器设置和获取变量的值。

from operator import mul, truediv, add, sub


def inform_all_except(source, message, constraints):
    """Inform all constraints of the message, except source."""
    for c in constraints:
        if c != source:
            c[message]()


def connector(name=None):
    """A connector between constraints."""
    informant = None
    constraints = []

    def set_value(source, value):
        nonlocal informant
        val = connector["val"]
        if val is None:
            informant, connector["val"] = source, value
            if name is not None:
                print(name, "=", value)
            inform_all_except(source, "new_val", constraints)
        else:
            if val != value:
                print("Contradiction detected:", val, "vs", value)

    def forget_value(source):
        nonlocal informant
        if informant == source:
            informant, connector["val"] = None, None
            if name is not None:
                print(name, "is forgotten")
            inform_all_except(source, "forget", constraints)

    connector = {
        "val": None,
        "set_val": set_value,
        "forget": forget_value,
        "has_val": lambda: connector["val"] is not None,
        "connect": lambda source: constraints.append(source),
    }
    return connector


def constant(connector, value):
    """The constraint that connector = value."""
    constraint = {}
    connector["set_val"](constraint, value)
    return constraint

def make_ternary_constraint(a, b, c, ab, ca, cb):
    """The constraint that ab(a,b)=c and ca(c,a)=b and cb(c,b) = a."""

    def new_value():
        av, bv, cv = [connector["has_val"]() for connector in (a, b, c)]
        if av and bv:
            c["set_val"](constraint, ab(a["val"], b["val"]))
        elif av and cv:
            b["set_val"](constraint, ca(c["val"], a["val"]))
        elif bv and cv:
            a["set_val"](constraint, cb(c["val"], b["val"]))

    def forget_value():
        for connector in (a, b, c):
            connector["forget"](constraint)

    constraint = {"new_val": new_value, "forget": forget_value}
    for connector in (a, b, c):
        connector["connect"](constraint)
    return constraint


def adder(a, b, c):
    """The constraint that a + b = c."""
    return make_ternary_constraint(a, b, c, add, sub, sub)


def multiplier(a, b, c):
    """The constraint that a * b = c."""
    return make_ternary_constraint(a, b, c, mul, truediv, truediv)


# 温度互转器，celsius 和 fahrenheit
#
#           +------+     +------+   v   +------+
# celsius---|a     |  u  |    a |-------|a     |
#           |  * c |-----|c *   |       |  + c |---fahrenheit
#         +-|b     |     |    b |-+   +-|b     |
#       w | +------+     +------+ |x y| +------+
#         |                       |   |
#         9                       5   32
#
def converter(celsius, fahrenheit):
    """Connect c to f with constraints to convert from Celsius to Fahrenheit."""
    u, v, w, x, y = [connector() for _ in range(5)]
    multiplier(celsius, w, u)
    multiplier(v, x, u)
    adder(v, y, fahrenheit)
    constant(w, 9)
    constant(x, 5)
    constant(y, 32)
