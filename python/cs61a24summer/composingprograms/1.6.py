# 迭代法
# update 用于更新到下一个 guess 的值
# close 用于判断是否需要停止迭代，也就是接受当前 guess
# guess 用于开启迭代的初始化值
def improve(update, close, guess=1):
    while not close(guess):
        guess = update(guess)
    return guess


# 迭代法计算黄金分割数
# x/1 = (1+x) / x
# 迭代算法： xn+1 = (1+xn) / xn = 1 + 1/xn
# 判定算法： x*x -（1+x）< 精度


# 牛顿迭代法
# 牛顿迭代法： xn+1 = xn - f(xn) / f'(xn)
# 开平方根： f(x) = x*x-a, f'(x) = 2x, xn+1 = xn - (xn^2-a)/(2*xn) = 1/2(xn + a/xn)
def newton_update(f, df):
    def update(x):
        return x - f(x) / df(x)

    return update

def find_zero(f, df):
    def close(x):
        return abs(f(x)) < 1e-20
    return improve(newton_update(f, df), close)

def square_root(a):
    def f(x):
        return x*x - a
    def df(x):
        return 2*x
    return find_zero(f, df)
